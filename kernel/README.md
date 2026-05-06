# kernel/

This directory will contain the source code for the Reikan verified microkernel core.

## Planned Structure

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

## Status

No kernel code exists yet. Implementation will begin in Phase 3, after the boot chain (Phase 2) and the systems language (Phase 1) are sufficiently mature.

See [docs/architecture-outline.md](../docs/architecture-outline.md) §9 for the kernel architecture design outline.
