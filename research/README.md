# research/

> 日本語版は [README.ja.md](README.ja.md) をご覧ください。

This directory contains research notes, literature summaries, and prior art reviews relevant to the Reikan project.

## Prior Art Summaries

The following products have been surveyed. Each entry provides a summary, similarities and differences with Reikan, and points to reference.

### Operating Systems

| Product | Description | Files |
|---|---|---|
| [Fuchsia OS](fuchsia/) | Google's capability-based microkernel OS (non-POSIX, non-Linux) | [fuchsia.md](fuchsia/fuchsia.md) · [fuchsia.ja.md](fuchsia/fuchsia.ja.md) |
| [seL4](sel4/) | Formally verified capability-based microkernel | [sel4.md](sel4/sel4.md) · [sel4.ja.md](sel4/sel4.ja.md) |
| [Redox OS](redox-os/) | Rust-based microkernel OS (non-Linux, partial POSIX) | [redox-os.md](redox-os/redox-os.md) · [redox-os.ja.md](redox-os/redox-os.ja.md) |
| [Theseus OS](theseus-os/) | Intralingual, cell-based research OS (Rust, single address space) | [theseus-os.md](theseus-os/theseus-os.md) · [theseus-os.ja.md](theseus-os/theseus-os.ja.md) |
| [AIOS](aios/) | LLM Agent Operating System — agent-centric OS layer (research) | [aios.md](aios/aios.md) · [aios.ja.md](aios/aios.ja.md) |
| [Cross-Platform Resource Isolation](cross-platform-isolation/) | Feasibility of Docker-class isolation on Linux/Windows/macOS for a hosted Reikan runtime | [cross-platform-isolation.md](cross-platform-isolation/cross-platform-isolation.md) · [cross-platform-isolation.ja.md](cross-platform-isolation/cross-platform-isolation.ja.md) |

### Programming Languages

| Product | Description | Files |
|---|---|---|
| [Mojo](mojo/) | AI-first systems language by Modular (Python superset, MLIR-based) | [mojo.md](mojo/mojo.md) · [mojo.ja.md](mojo/mojo.ja.md) |

---

## Relevant Areas (Pending Summaries)

The following areas are identified as relevant to Reikan but do not yet have dedicated summaries. Contributions are welcomed — see [CONTRIBUTING.md](../CONTRIBUTING.md).

- **Capability-based operating systems** — L4, EROS, Capsicum
- **Formal verification of OS kernels** — CertiKOS, CompCert
- **Type systems for systems programming** — Linear Haskell, Vale, Cyclone
- **Algebraic effects and effect systems** — Koka, Eff, Frank
- **AI systems and inference infrastructure** — vLLM, TensorRT, Triton, XLA
- **Heterogeneous compute abstractions** — SYCL, OneAPI, HSA, Metal
- **Distributed capability systems** — SPKI/SDSI, CapTP, Agoric
- **Formal specification languages** — TLA+, Alloy, Dafny, Lean 4, Coq, Iris
