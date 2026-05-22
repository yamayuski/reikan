//! x86_64 architecture support: boot stub, VGA console, and serial port.
//!
//! The `boot.S` assembly file is pulled in via `global_asm!` so it is
//! assembled as part of this crate rather than as a separate object.

pub mod serial;
pub mod vga;

use core::arch::global_asm;

// Include the 32-bit/64-bit boot assembly.  The file contains:
//   - The Multiboot2 header in `.section .multiboot2`
//   - The 32-bit `_start` entry point with page-table setup
//   - The 64-bit `long_mode_start` trampoline that calls `kernel_main`
global_asm!(include_str!("boot.S"), options(att_syntax));
