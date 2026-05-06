# 黎環 / Reikan

> **AI-First OS — A Next-Generation Operating System**

---

## Overview

**黎環 (Reikan)** is an early-stage architecture and implementation project for an AI-First operating system — a ground-up redesign of what an OS can and should be in an era where AI agents, heterogeneous compute, and machine-to-machine coordination are first-class concerns.

The name 黎 (*rei*, "dawn / dark before dawn") and 環 (*kan*, "ring / cycle / exchange") together evoke a new cycle of computing: the moment before a new era breaks, where coordination, exchange, and transformation define the system's essence.

This is not a fork of Linux, Windows, or macOS. It carries no obligation to their application models, syscall interfaces, or design assumptions. It is built to answer a different question:

> *What does an operating system look like if AI agents, not human applications, are the primary unit of computation?*

---

## Project Vision

Reikan aims to be a **capability-centric, agent-native, formally verifiable operating system** designed from first principles for a world in which:

- AI agents are first-class OS citizens, with memory, goals, tools, and lifetimes managed by the kernel.
- Heterogeneous compute (CPU, GPU, NPU, TPU, DMA engines) is scheduled and orchestrated as a unified resource fabric.
- Safety, auditability, and verifiability take precedence over legacy compatibility.
- A new high-level systems language — designed for both human and LLM authorship — replaces C/C++ as the primary implementation language.
- Human and machine intelligence collaborate through a shared, inspectable, policy-governed execution environment.

---

## Design Principles

| Principle | Description |
|---|---|
| **AI-First** | Agents, models, and inference pipelines are native OS constructs, not user-space afterthoughts. |
| **Capability-Centric** | All authority is explicit, delegatable, and auditable. No ambient access. |
| **Verifiability** | The trusted computing base is small, formally specified, and amenable to machine-checked proof. |
| **Rupture from Legacy** | No POSIX, no Win32, no ELF assumptions. Compatibility is a future opt-in layer, not a constraint. |
| **Observability by Default** | Every capability grant, model invocation, memory migration, and policy override is an auditable event. |
| **Heterogeneous Resource Orchestration** | CPU, GPU, NPU, VRAM, DRAM, storage IOPS, and network queues are first-class scheduled resources. |
| **Human–Machine Harmony** | The OS serves both AI agents and human users through a shared, intent-centric interface model. |
| **AI-Led Development** | LLMs drive design and implementation; humans provide architectural review, safety boundaries, and final authority on irreversible decisions. |

---

## High-Level Architecture

Reikan is organized around a small, verified microkernel core and a high-performance system-services layer:

```
┌─────────────────────────────────────────────────────┐
│            Human UI / Agent Shell / Dev Env         │
├─────────────────────────────────────────────────────┤
│  Model Runtime │ Object Store │ Network Mesh │ ...  │
│              System Services Layer                  │
├─────────────────────────────────────────────────────┤
│   Capability Manager │ Scheduler │ VM Manager │ IPC │
│              Verified Microkernel Core              │
├─────────────────────────────────────────────────────┤
│   CPU  │  GPU  │  NPU/TPU  │  DMA  │  Storage      │
│              Hardware Resource Fabric               │
└─────────────────────────────────────────────────────┘
```

The primary abstractions are **agents**, **capabilities**, **contexts**, **memory objects**, **execution graphs**, and **model resources** — not processes, files, or threads.

---

## Roadmap (Phases)

| Phase | Focus | Status |
|---|---|---|
| **Phase 0** | Architecture constitution, threat model, design principles | 🔄 In progress |
| **Phase 1** | New systems language design (syntax, type system, IR, verifier) | 📋 Planned |
| **Phase 2** | Boot chain (bootloader, hardware init, page tables, console) | 📋 Planned |
| **Phase 3** | Minimum verified kernel (capability table, scheduler, IPC, VM) | 📋 Planned |
| **Phase 4** | Runtime and system services (object store, policy engine, drivers) | 📋 Planned |
| **Phase 5** | GPU/NPU execution fabric (command queues, unified memory, graph executor) | 📋 Planned |
| **Phase 6** | Agent OS APIs (context, tool invocation, semantic query, attestation) | 📋 Planned |
| **Phase 7** | Developer environment (AI-native shell, structural editor, trace viewer) | 📋 Planned |
| **Phase 8** | Human UI (compositor, workspace graph, conversational control) | 📋 Planned |
| **Phase 9** | Distributed mesh (node federation, remote capability delegation) | 📋 Planned |

---

## Repository Layout

```
reikan/
├── README.md               # This file
├── CONTRIBUTING.md         # How to contribute to Reikan
├── LICENSE                 # Project license
│
├── docs/                   # Design documents and architecture specs
│   ├── README.md           # Documentation index and organization guide
│   └── architecture-outline.md  # Full detailed design document outline
│
├── spec/                   # Formal specifications and invariants
│
├── kernel/                 # Verified microkernel source
│
├── runtime/                # System services and runtime layer
│
├── lang/                   # New systems language (compiler, IR, verifier)
│
├── tools/                  # Build tools, code generators, analysis utilities
│
├── research/               # Research notes, papers, and literature reviews
│
├── scripts/                # CI, build, and development scripts
│
├── tests/                  # Integration and conformance tests
│
├── assets/                 # Diagrams, logos, and visual assets
│
└── .github/                # GitHub templates and workflow configuration
```

---

## Current Status

**This project is in the architecture-definition phase (Phase 0).**

No kernel code, language compiler, or runtime implementation exists yet. Current work focuses on:

- Establishing the design philosophy, security model, and capability model.
- Drafting the architecture specification document.
- Defining contribution processes suited to an AI-led development workflow.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to get involved.

The most valuable contributions at this stage are:

- Design proposals and Architecture Decision Records (ADRs).
- Formal specification drafts.
- Research summaries on relevant prior work (seL4, Fuchsia, Redox, Dafny, Lean, etc.).
- Documentation improvements and outline expansions.

---

## License

See [LICENSE](LICENSE).

---

*黎環 — Dawn of a new cycle.*
