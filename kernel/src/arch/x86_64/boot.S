/* boot.S — Multiboot2 header and 32→64-bit mode switch for the Reikan kernel
 *
 * Execution flow:
 *   1. GRUB2 finds the Multiboot2 header, loads the 64-bit ELF at 1 MiB.
 *   2. GRUB enters 32-bit protected mode and jumps to _start.
 *   3. _start validates the magic, builds an identity page table (first 1 GiB),
 *      enables PAE, sets EFER.LME, enables paging, loads a minimal 64-bit GDT,
 *      and does a far jump into 64-bit long mode.
 *   4. long_mode_start sets segment registers, sets up the stack, and calls the
 *      Rust kernel_main(mb2_magic: u32, mb2_info_ptr: u64).
 *
 * All assembly is AT&T syntax (GNU Assembler).
 */

/* ── Multiboot2 header ──────────────────────────────────────────────────── */

.section .multiboot2, "a"
.align 8
mb2_header_start:
    .long   0xE85250D6                          /* magic                    */
    .long   0                                   /* architecture: i386       */
    .long   (mb2_header_end - mb2_header_start) /* header_length            */
    /* checksum: -(magic + arch + header_length) truncated to 32 bits */
    .long   (0 - 0xE85250D6 - 0 - (mb2_header_end - mb2_header_start))
    /* end tag */
    .word   0   /* type  */
    .word   0   /* flags */
    .long   8   /* size  */
mb2_header_end:

/* ── BSS — stack and page tables ────────────────────────────────────────── */

.section .bss, "aw", @nobits

/* 64 KiB stack, 16-byte aligned (System V AMD64 ABI requirement). */
.align 16
stack_bottom:
    .skip 65536
stack_top:

/* Scratch storage for Multiboot2 arguments across the mode switch. */
.align 8
mb2_saved_magic:
    .skip 4
.align 8
mb2_saved_info:
    .skip 8

/* Page tables: each must be 4 KiB aligned.
 * We identity-map the first 1 GiB using 2 MiB huge pages:
 *   PML4[0] → PDPT
 *   PDPT[0] → PD
 *   PD[0..511]: 512 × 2 MiB = 1 GiB                                       */
.align 4096
pml4_table:
    .skip 4096
pdpt_table:
    .skip 4096
pd_table:
    .skip 4096

/* ── Text section — 32-bit entry point ──────────────────────────────────── */

.section .text
.code32

.global _start
.type   _start, @function
_start:
    cli
    movl    $stack_top, %esp

    /* Save Multiboot2 arguments before we start touching registers. */
    movl    %eax, mb2_saved_magic
    movl    %ebx, mb2_saved_info

    /* Verify the Multiboot2 magic number (0x36d76289). */
    cmpl    $0x36D76289, %eax
    jne     .halt_no_multiboot

    /* ── Build identity page tables for the first 1 GiB ── */

    /* PML4[0] → pdpt_table (present + writable) */
    movl    $pdpt_table, %eax
    orl     $0x03, %eax
    movl    %eax, pml4_table
    movl    $0,   (pml4_table + 4)

    /* PDPT[0] → pd_table (present + writable) */
    movl    $pd_table, %eax
    orl     $0x03, %eax
    movl    %eax, pdpt_table
    movl    $0,  (pdpt_table + 4)

    /* Fill PD with 512 entries mapping 2 MiB huge pages (0 … 1 GiB). */
    xorl    %ecx, %ecx
.fill_pd:
    movl    %ecx, %eax
    shll    $21, %eax           /* physical address = i × 2 MiB */
    orl     $0x83, %eax         /* present + writable + huge-page */
    movl    %ecx, %edi
    shll    $3, %edi
    addl    $pd_table, %edi
    movl    %eax, (%edi)
    movl    $0,   4(%edi)       /* upper 32 bits — zero for first 1 GiB */
    incl    %ecx
    cmpl    $512, %ecx
    jl      .fill_pd

    /* ── Enter 64-bit long mode ── */

    /* Load PML4 into CR3. */
    movl    $pml4_table, %eax
    movl    %eax, %cr3

    /* Enable PAE (CR4 bit 5). */
    movl    %cr4, %eax
    orl     $(1 << 5), %eax
    movl    %eax, %cr4

    /* Set EFER.LME (MSR 0xC0000080, bit 8). */
    movl    $0xC0000080, %ecx
    rdmsr
    orl     $(1 << 8), %eax
    wrmsr

    /* Enable paging (CR0 bit 31) — this activates long mode compatibility. */
    movl    %cr0, %eax
    orl     $(1 << 31), %eax
    movl    %eax, %cr0

    /* Load the 64-bit GDT and far-jump to flush the instruction pipeline. */
    lgdt    gdt64_ptr
    ljmp    $0x08, $.long_mode_start

.halt_no_multiboot:
    cli
    hlt
    jmp     .halt_no_multiboot

/* ── 64-bit long-mode entry point ───────────────────────────────────────── */

.code64
.long_mode_start:
    /* Load data segment selector (index 2 × 8 = 0x10) into all data regs. */
    movw    $0x10, %ax
    movw    %ax, %ds
    movw    %ax, %es
    movw    %ax, %fs
    movw    %ax, %gs
    movw    %ax, %ss

    /* Re-establish a clean 64-bit stack and null frame pointer. */
    movq    $stack_top, %rsp
    xorq    %rbp, %rbp

    /* Pass Multiboot2 arguments to kernel_main via System V AMD64 ABI:
     *   RDI = mb2_magic  (u32, zero-extended)
     *   RSI = mb2_info   (u64 pointer)                                     */
    movl    mb2_saved_magic(%rip), %edi
    movq    mb2_saved_info(%rip), %rsi

    call    kernel_main

    /* kernel_main must never return; halt if it does. */
.halt:
    cli
    hlt
    jmp     .halt

/* ── Minimal 64-bit GDT ─────────────────────────────────────────────────── */

.section .rodata
.align 8
gdt64:
    .quad   0x0000000000000000   /* 0x00: null descriptor                   */
    .quad   0x00AF9A000000FFFF   /* 0x08: code — 64-bit, ring 0, exec/read  */
    .quad   0x00CF92000000FFFF   /* 0x10: data — ring 0, read/write         */
gdt64_end:

gdt64_ptr:
    .word   (gdt64_end - gdt64 - 1)   /* limit */
    .long   gdt64                      /* base (low 32 bits, enough at 1 MiB) */
    .long   0                          /* base (high 32 bits)                 */
