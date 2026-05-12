# Theseus OS

> 日本語版は [theseus-os.ja.md](theseus-os.ja.md) をご覧ください。

---

## Overview

**Theseus OS** is a research operating system developed at Virginia Tech (later Rice University) under Kevin Boos and Leigh Stoller, beginning around 2017. It explores a novel OS structure called **intralingual design**: the kernel, drivers, and application code are all written in the same language (Rust), compiled into a single address space, and distinguished only by software-enforced isolation boundaries — not hardware privilege rings.

Theseus decomposes the OS into small, self-contained units called **cells**. Each cell is a Rust crate with clearly-defined state ownership boundaries. The key contribution is the elimination of **state spill** — the phenomenon where OS components hold references into each other's state in ways that create hidden coupling, making the OS hard to reason about, evolve, or partially update.

### Key Technical Properties

| Property | Detail |
|---|---|
| Architecture | Single-address-space OS; intralingual; cell-based |
| Primary language | Rust — type system enforces cell boundaries |
| Isolation mechanism | Type-level ownership, not hardware rings |
| Cell model | Each OS component = an isolated Rust crate with owned state |
| State management | No state spill; cells own their state exclusively |
| Live evolution | Cells can be swapped out and updated at runtime |
| IPC | Function calls within the single address space (type-safe) |
| Formal verification | None — relies on Rust's type system |
| AI focus | None — OS structure research |

### State Spill Problem

Traditional OS components hold mutable references to each other's internal data structures (e.g., a scheduler holding a pointer into a task struct that a memory manager also holds). This "state spill" across components makes it impossible to evolve or replace one component without understanding all others. Theseus eliminates this by using Rust's ownership rules to enforce that each cell owns its state exclusively.

---

## Similarities with Reikan

| Dimension | Theseus OS | Reikan |
|---|---|---|
| **Origin** | Not a fork of Linux; ground-up design | Not a fork of Linux, Windows, or macOS |
| **Primary language** | Rust — safety as a structural property | Reikan-lang with Rust for bootstrapping |
| **Safety philosophy** | Type system enforces isolation boundaries | Language design + formal proof enforces invariants |
| **Decomposition** | OS as a composition of isolated cells | OS as a composition of capability-isolated components |
| **State ownership** | Explicit ownership model via Rust | Explicit capability model for resource ownership |
| **Microkernel-like** | Minimal trusted core; most logic in cells | Verified microkernel; most logic in system services |
| **Live evolution** | Cells can be replaced at runtime | Policy-governed agent lifecycle management |
| **Observability** | Cell-level tracing and introspection | Uniform audit of all capability grants and model invocations |

---

## Differences from Reikan

| Dimension | Theseus OS | Reikan |
|---|---|---|
| **AI focus** | None — OS structure research | AI agents, LLM pipelines, model inference as first-class OS constructs |
| **Formal verification** | None — type safety only | Machine-checked proof of TCB is a design goal |
| **Capability security** | Not a capability-based security model | Full capability security — unforgeable authority tokens |
| **Hardware isolation** | Relies on Rust type system; no hardware privilege rings | Hardware-enforced privilege separation + language safety |
| **Heterogeneous compute** | No GPU/NPU scheduling | GPU, NPU, VRAM, accelerators as first-class scheduled resources |
| **Agent abstraction** | No agent concept | Agents with goals, memory, tool access, and lifetime as native objects |
| **Address space model** | Single address space (SASOS) — performance-focused | Separate address spaces with hardware isolation |
| **Scope** | Research prototype | Production-targeted architecture |
| **Development model** | Academic research group | AI-led development (LLMs as active contributors) |

---

## Points to Reference / Learn From

### 1. Intralingual OS Design
Theseus's key insight — that the OS and its applications can share one language and compiler, and that the type system can enforce isolation without hardware rings — is a powerful argument for building OS infrastructure in a carefully designed language. This supports Reikan's decision to design Reikan-lang as a language that can express both kernel primitives and agent-level logic.

### 2. State Spill Prevention
The concept of **state spill** — hidden coupling between OS components through shared mutable state — is a useful framing for Reikan's architecture. Reikan should design its capability manager, scheduler, and memory manager so that their internal state boundaries are explicit and enforced, whether through ownership types in Reikan-lang or through capability mediation.

### 3. Cell-Based Decomposition
Theseus's cell model (each OS component is a crate with strict state ownership) is a practical example of fine-grained OS decomposition. For Reikan, this suggests that individual subsystems (capability manager, scheduler, IPC, agent runtime) should be designed as isolated modules with formally-specified inter-module interfaces.

### 4. Live OS Evolution
Theseus supports replacing a running OS component (cell) without rebooting. This live-update property is interesting for Reikan's agent lifecycle model: agents should be able to update their tool libraries, model weights, or policy parameters without requiring a system restart.

### 5. Single-Address-Space Trade-offs
Theseus's SASOS design shows both the performance advantages (no TLB shootdowns, no syscall overhead for intra-OS calls) and the risks (a type-safety bug can corrupt the entire system) of collapsing hardware isolation. Reikan should evaluate these trade-offs explicitly, especially for the boundary between verified kernel code and system services.

---

## References

- Boos, K. et al. (2020). "Theseus: an Experiment in Operating System Structure and State Management." *OSDI 2020*. ([PDF](https://www.usenix.org/conference/osdi20/presentation/boos))
- [Theseus OS GitHub](https://github.com/theseus-os/Theseus)
- [Theseus OS documentation](https://theseus-os.github.io/Theseus/book/)
- [Kevin Boos's PhD thesis on Theseus](https://boos.systems/thesis)
