# kernel/

Source code for the Reikan kernel.

> **Language:** 日本語版は [README.ja.md](README.ja.md) をご覧ください。

---

## Status

**Phase 2 bootstrap — Rust placeholder.**

A minimal x86_64 kernel boot stub written in Rust is present under
`src/arch/x86_64/`.  It is a temporary implementation that will be replaced
by Reikan-lang once the language toolchain is mature (Phase 1).  The scope is
intentionally minimal: Multiboot2 boot + UTF-8 text output + clean halt.

---

## Directory Layout

```
kernel/
├── src/
│   ├── arch/
│   │   ├── mod.rs          # arch sub-module declaration
│   │   └── x86_64/
│   │       ├── boot.S      # Multiboot2 header + 32→64-bit mode switch
│   │       ├── vga.rs      # VGA text-mode (80×25) console
│   │       ├── serial.rs   # UART 16550 serial port (COM1) — full UTF-8
│   │       └── mod.rs      # arch/x86_64 module root, pulls in boot.S
│   └── main.rs             # kernel_main — entry from boot.S
├── .cargo/
│   └── config.toml         # x86_64-unknown-none target, linker flags
├── Cargo.toml              # Rust package (no_std, panic = abort)
└── linker.ld               # Linker script (load at 1 MiB)
```

---

## Building

### Prerequisites

```
rustup target add x86_64-unknown-none
```

### Compile

```bash
cd kernel
cargo build           # debug build
cargo build --release # release build (optimised for size)
```

The kernel ELF binary is output to
`target/x86_64-unknown-none/{debug,release}/reikan-kernel`.

### Create a bootable ISO (requires GRUB tools)

```bash
# Ubuntu / Debian:
sudo apt-get install grub-pc-bin grub-common xorriso mtools

bash ../scripts/build-iso.sh           # debug ISO
bash ../scripts/build-iso.sh --release # release ISO
```

The ISO is written to `../build/reikan-x86_64.iso`.

---

## Running in VirtualBox (Windows 11)

1. Create a new VM: **Type** Other, **Version** Other/Unknown (64-bit).
2. **Settings → Storage → IDE Controller → Optical Drive** → attach
   `build/reikan-x86_64.iso`.
3. *(Optional)* **Settings → Serial Ports → Port 1**: enable, connect to a
   raw file or named pipe to capture UTF-8 serial output (115200 8N1).
4. Start the VM.  You should see `Reikan kernel — x86_64 boot OK` on screen.

---

## Boot Sequence

```
GRUB2 loads ELF → finds Multiboot2 header at 1 MiB
  └─ _start (32-bit protected mode)
       ├─ verify Multiboot2 magic (0x36D76289)
       ├─ identity-map first 1 GiB with 2 MiB huge pages
       ├─ enable PAE + EFER.LME + paging → 64-bit long mode
       ├─ load 64-bit GDT, far-jump
       └─ kernel_main(mb2_magic: u32, mb2_info_ptr: u64)
            ├─ init UART COM1 (115200 8N1)
            ├─ print UTF-8 boot messages over serial
            ├─ print ASCII messages on VGA console
            └─ halt (cli + hlt loop)
```

---

## Planned Structure (future phases)

```
kernel/
├── src/
│   ├── boot/         # Architecture-specific boot and init code
│   ├── capability/   # Capability table and management
│   ├── mm/           # Physical and virtual memory management
│   ├── sched/        # Scheduler nucleus
│   ├── ipc/          # IPC primitives
│   ├── trap/         # Exception and interrupt handling
│   └── arch/         # ISA-specific code (aarch64/, x86_64/)
├── tests/            # Kernel unit and integration tests
└── proofs/           # Formal proof artifacts
```

See [docs/architecture-outline.md](../docs/architecture-outline.md) §9 for
the full kernel architecture design outline.
