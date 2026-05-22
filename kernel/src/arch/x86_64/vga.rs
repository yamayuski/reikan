//! VGA text-mode console (80 × 25, mode 0x03).
//!
//! The VGA text buffer is mapped at physical address 0xB8000.  Each cell is a
//! 16-bit little-endian word: `[attribute, character]`.  The attribute byte
//! encodes foreground and background colours in the CGA 4+4 palette.
//!
//! This module outputs the printable ASCII subset of any UTF-8 string passed
//! to it; non-ASCII codepoints are silently skipped because the VGA font only
//! covers CP437 characters.  For full UTF-8 output use the [`serial`] module.
//!
//! [`serial`]: super::serial

use core::fmt;

const VGA_BUFFER: *mut u16 = 0xB8000 as *mut u16;
const VGA_WIDTH: usize = 80;
const VGA_HEIGHT: usize = 25;

/// CGA foreground/background colour codes.
#[allow(dead_code)]
#[repr(u8)]
pub enum Colour {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGrey = 7,
    DarkGrey = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    Pink = 13,
    Yellow = 14,
    White = 15,
}

/// Combine foreground and background colour into a VGA attribute byte.
#[inline]
const fn make_attr(fg: Colour, bg: Colour) -> u8 {
    (bg as u8) << 4 | (fg as u8)
}

/// VGA text-mode console with automatic scrolling.
pub struct Console {
    col: usize,
    row: usize,
    attr: u8,
}

impl Console {
    /// Create a new console using light-grey on black.
    pub const fn new() -> Self {
        Console {
            col: 0,
            row: 0,
            attr: make_attr(Colour::LightGrey, Colour::Black),
        }
    }

    /// Clear the screen and reset the cursor to the top-left.
    pub fn clear(&mut self) {
        let blank = self.cell(b' ');
        for i in 0..(VGA_WIDTH * VGA_HEIGHT) {
            unsafe { VGA_BUFFER.add(i).write_volatile(blank) };
        }
        self.col = 0;
        self.row = 0;
    }

    /// Write a single ASCII byte.  Non-printable bytes other than `\n` are
    /// replaced with a space.
    pub fn write_byte(&mut self, byte: u8) {
        match byte {
            b'\n' => self.newline(),
            byte => {
                let ch = if (0x20..0x7F).contains(&byte) { byte } else { b' ' };
                let cell = self.cell(ch);
                let offset = self.row * VGA_WIDTH + self.col;
                unsafe { VGA_BUFFER.add(offset).write_volatile(cell) };
                self.col += 1;
                if self.col >= VGA_WIDTH {
                    self.newline();
                }
            }
        }
    }

    /// Write a string, outputting only printable ASCII from the UTF-8 bytes.
    pub fn write_str(&mut self, s: &str) {
        for byte in s.bytes() {
            // Skip non-ASCII continuation/lead bytes; output the rest.
            if byte == b'\n' || (0x20..0x7F).contains(&byte) {
                self.write_byte(byte);
            }
        }
    }

    // ── Private helpers ──────────────────────────────────────────────────

    fn cell(&self, ch: u8) -> u16 {
        (self.attr as u16) << 8 | ch as u16
    }

    fn newline(&mut self) {
        self.col = 0;
        self.row += 1;
        if self.row >= VGA_HEIGHT {
            self.scroll();
        }
    }

    fn scroll(&mut self) {
        // Move each row one line up.
        for row in 1..VGA_HEIGHT {
            for col in 0..VGA_WIDTH {
                let src = row * VGA_WIDTH + col;
                let dst = (row - 1) * VGA_WIDTH + col;
                let cell = unsafe { VGA_BUFFER.add(src).read_volatile() };
                unsafe { VGA_BUFFER.add(dst).write_volatile(cell) };
            }
        }
        // Blank the last row.
        let blank = self.cell(b' ');
        let last = (VGA_HEIGHT - 1) * VGA_WIDTH;
        for col in 0..VGA_WIDTH {
            unsafe { VGA_BUFFER.add(last + col).write_volatile(blank) };
        }
        self.row = VGA_HEIGHT - 1;
    }
}

impl fmt::Write for Console {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        Console::write_str(self, s);
        Ok(())
    }
}
