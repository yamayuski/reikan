/* linker.ld — Linker script for the Reikan x86_64 kernel
 *
 * GRUB2 loads a Multiboot2 ELF kernel at the physical address specified
 * here.  1 MiB (0x100000) is the conventional base address: it avoids
 * the low-memory BIOS/EBDA region while remaining inside the initial
 * identity-mapped 1 GiB window set up by boot.S.
 */

ENTRY(_start)

SECTIONS
{
    . = 1M;

    /* The Multiboot2 header must appear within the first 32 KiB of the
     * kernel image so GRUB can find it during the scan. */
    .multiboot2 : {
        KEEP(*(.multiboot2))
    }

    .text : ALIGN(4K) {
        *(.text .text.*)
    }

    .rodata : ALIGN(4K) {
        *(.rodata .rodata.*)
    }

    .data : ALIGN(4K) {
        *(.data .data.*)
    }

    .bss : ALIGN(4K) {
        *(COMMON)
        *(.bss .bss.*)
    }

    /DISCARD/ : {
        *(.eh_frame)
        *(.eh_frame_hdr)
        *(.note.GNU-stack)
        *(.note.gnu.property)
    }
}
