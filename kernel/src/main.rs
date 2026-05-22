//! Reikan kernel — x86_64 entry point.
//!
//! This file is the top-level Rust entry point for the kernel.  Control
//! arrives here from the assembly stub in `arch/x86_64/boot.S` after the CPU
//! has been placed into 64-bit long mode with a minimal identity-mapped page
//! table covering the first 1 GiB.
//!
//! Scope (matches issue requirements):
//!   - Boot successfully via GRUB2 / Multiboot2 on x86_64.
//!   - Print UTF-8 strings over the serial port (COM1) and ASCII strings on
//!     the VGA text console.
//!   - Halt cleanly.
//!
//! Everything else (capability model, scheduler, memory manager, …) is out of
//! scope for this bootstrap; it will be rewritten in Reikan-lang later.

#![no_std]
#![no_main]

mod arch;

use arch::x86_64::{
    serial::{Serial, COM1},
    vga::Console,
};

/// Kernel main — called from `boot.S` once the CPU is in 64-bit long mode.
///
/// # Arguments
/// * `mb2_magic`    — Multiboot2 bootloader magic (must be `0x36D76289`).
/// * `mb2_info_ptr` — Physical address of the Multiboot2 information structure.
#[no_mangle]
pub extern "C" fn kernel_main(mb2_magic: u32, mb2_info_ptr: u64) -> ! {
    // ── Serial console (full UTF-8) ──────────────────────────────────────
    let serial = Serial::new(COM1);
    unsafe { serial.init() };

    serial.write_str("黎環 / Reikan — kernel boot OK\n");
    serial.write_str("Architecture : x86_64\n");
    serial.write_str("Boot protocol: Multiboot2\n");

    if mb2_magic == 0x36D76289 {
        serial.write_str("Multiboot2   : magic OK\n");
    } else {
        serial.write_str("Multiboot2   : INVALID MAGIC — boot aborted\n");
        halt();
    }

    // Print the info-structure address so it's easy to inspect in a debugger.
    serial.write_str("MB2 info ptr : 0x");
    write_hex_u64(&serial, mb2_info_ptr);
    serial.write_str("\n");

    // ── VGA text console (ASCII) ─────────────────────────────────────────
    let mut vga = Console::new();
    vga.clear();
    vga.write_str("Reikan kernel — x86_64 boot OK\n");
    vga.write_str("Serial: COM1 115200 8N1\n");
    vga.write_str("Halted.\n");

    serial.write_str("Halted.\n");
    halt();
}

/// Spin forever with interrupts disabled.
fn halt() -> ! {
    loop {
        unsafe { core::arch::asm!("cli; hlt", options(nomem, nostack)) };
    }
}

/// Write a `u64` as zero-padded 16-digit hexadecimal to `serial`.
fn write_hex_u64(serial: &Serial, mut val: u64) {
    let mut buf = [b'0'; 16];
    for i in (0..16).rev() {
        let nibble = (val & 0xF) as u8;
        buf[i] = if nibble < 10 { b'0' + nibble } else { b'a' + nibble - 10 };
        val >>= 4;
    }
    // SAFETY: buf contains only valid ASCII hex digits.
    serial.write_str(unsafe { core::str::from_utf8_unchecked(&buf) });
}

/// Panic handler — required by `#![no_std]`.
///
/// We print the panic location over serial (best-effort) and halt.
#[panic_handler]
fn panic(info: &core::panic::PanicInfo) -> ! {
    // Reconstruct a serial handle — safe because we are single-threaded and
    // a panic is a terminal condition anyway.
    let serial = Serial::new(COM1);
    serial.write_str("\n!!! KERNEL PANIC !!!\n");
    if let Some(loc) = info.location() {
        serial.write_str(loc.file());
        serial.write_str(":");
        // Write line number without allocation.
        let mut line = loc.line();
        let mut digits = [b'0'; 10];
        let mut n = 9usize;
        if line == 0 {
            serial.write_byte(b'0');
        } else {
            while line > 0 {
                digits[n] = b'0' + (line % 10) as u8;
                line /= 10;
                n = n.saturating_sub(1);
            }
            serial.write_str(unsafe { core::str::from_utf8_unchecked(&digits[n + 1..]) });
        }
        serial.write_str("\n");
    }
    halt();
}
