//! UART 16550 serial port driver (COM1 = I/O port 0x3F8).
//!
//! Serial output is the preferred channel for **full UTF-8 text** because it
//! transmits raw bytes without any font/palette restrictions.
//!
//! In VirtualBox you can view the output by configuring the VM's serial port
//! as a named pipe or raw file.  The `grub-mkrescue`/QEMU workflow also prints
//! all bytes here, which makes serial indispensable for automated testing.
//!
//! Baud rate: 115200, 8N1 (8 data bits, no parity, 1 stop bit).

use core::fmt;

/// COM1 base I/O port.
pub const COM1: u16 = 0x3F8;

/// Write a byte to an x86 I/O port.
#[inline]
unsafe fn outb(port: u16, val: u8) {
    core::arch::asm!("out dx, al", in("dx") port, in("al") val, options(nomem, nostack, preserves_flags));
}

/// Read a byte from an x86 I/O port.
#[inline]
unsafe fn inb(port: u16) -> u8 {
    let val: u8;
    core::arch::asm!("in al, dx", out("al") val, in("dx") port, options(nomem, nostack, preserves_flags));
    val
}

/// Minimal UART 16550 driver.
pub struct Serial {
    base: u16,
}

impl Serial {
    /// Construct a driver for the given base port without initialising it yet.
    pub const fn new(base: u16) -> Self {
        Serial { base }
    }

    /// Initialise the UART: 115200 baud, 8N1, FIFOs enabled.
    ///
    /// # Safety
    /// Must only be called once, with a valid 16550-compatible UART at `base`.
    pub unsafe fn init(&self) {
        let b = self.base;
        outb(b + 1, 0x00); // Disable all interrupts
        outb(b + 3, 0x80); // Enable DLAB (baud-rate divisor latch)
        outb(b, 0x01); // Divisor low byte  (1 → 115200 baud)
        outb(b + 1, 0x00); // Divisor high byte
        outb(b + 3, 0x03); // 8 bits, no parity, 1 stop bit (clear DLAB)
        outb(b + 2, 0xC7); // Enable FIFO, clear, 14-byte threshold
        outb(b + 4, 0x0B); // IRQs enabled, RTS/DSR set
    }

    /// Return `true` when the transmit holding register is empty.
    fn is_tx_ready(&self) -> bool {
        unsafe { inb(self.base + 5) & 0x20 != 0 }
    }

    /// Block until the transmit register is empty, then send one byte.
    pub fn write_byte(&self, byte: u8) {
        while !self.is_tx_ready() {}
        unsafe { outb(self.base, byte) };
    }

    /// Write every byte of `s` to the UART, translating `\n` → `\r\n`.
    pub fn write_str(&self, s: &str) {
        for byte in s.bytes() {
            if byte == b'\n' {
                self.write_byte(b'\r');
            }
            self.write_byte(byte);
        }
    }
}

impl fmt::Write for Serial {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        Serial::write_str(self, s);
        Ok(())
    }
}
