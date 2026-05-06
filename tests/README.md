# tests/

This directory contains integration and conformance tests for the Reikan project.

## Test Philosophy

Reikan tests are designed to be:
- **Reproducible** — deterministic by default, with record/replay for non-deterministic paths
- **Failure-isolated** — each test operates within its own capability boundary
- **Specification-linked** — every test references the specification invariant it validates

## Planned Structure

```
tests/
├── conformance/    # API contract verification tests
├── integration/    # Cross-subsystem integration tests
├── simulation/     # Full-system simulated environment tests
├── fuzz/           # Fuzzing targets for security-critical paths
└── bench/          # Performance regression benchmarks
```

## Status

No tests exist yet. Test infrastructure will be established alongside the first kernel implementation (Phase 3).

See [docs/architecture-outline.md](../docs/architecture-outline.md) §25 for the testing design outline.
