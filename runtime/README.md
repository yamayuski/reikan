# runtime/

This directory will contain the Reikan system services layer (non-TCB), including the high-performance runtime components that run above the verified microkernel core.

## Planned Components

- `runtime/object-store/` — Content-addressed, versioned knowledge object store
- `runtime/model/` — Model runtime (loading, scheduling, inference pipeline)
- `runtime/policy/` — Policy engine and capability enforcement
- `runtime/device/` — Device manager and driver host
- `runtime/network/` — Network stack and distributed mesh
- `runtime/search/` — Lexical, semantic, structural, and provenance search
- `runtime/observability/` — Audit log, tracing, and metrics infrastructure
- `runtime/compositor/` — UI compositor (Phase 8)

## Status

No runtime code exists yet. Implementation will begin in Phase 4.

See [docs/architecture-outline.md](../docs/architecture-outline.md) §17–§20 for relevant design outlines.
