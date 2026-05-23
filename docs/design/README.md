# docs/design/

This directory contains in-depth design documents for individual Reikan subsystems.

Design documents are living documents that evolve with the architecture. They expand on the high-level outline in [architecture-outline.md](../architecture-outline.md) with detailed decisions, data structures, algorithms, and rationale.

## Documents

| Document | Description |
|---|---|
| [security-autonomous-defense.md](security-autonomous-defense.md) | Charter and architecture for the AI-driven Autonomous Vulnerability Defense System (AVDS), supply chain security, and kernel-level proactive defense. Japanese version: [security-autonomous-defense.ja.md](security-autonomous-defense.ja.md) |
| [supply-chain-package-management.md](supply-chain-package-management.md) | Design for the built-in defensive dependency workflow (`reikan add`), side-effect declarations, transitive approval chain, and source pinning model. Japanese version: [supply-chain-package-management.ja.md](supply-chain-package-management.ja.md) |

## Planned Documents

Documents will be added here as each phase of the project progresses. Expected documents include:

- `capability-model.md` — Detailed capability type system and implementation
- `memory-objects.md` — Memory object hierarchy and management
- `language-type-system.md` — Systems language type theory
- `kernel-ipc.md` — IPC mechanism design
- `scheduler-design.md` — Heterogeneous resource scheduling algorithm
- `object-store.md` — Knowledge object store design
- `model-runtime.md` — AI model execution pipeline

## Status

Design documents are being added as Phase 0 (architecture definition) progresses.
