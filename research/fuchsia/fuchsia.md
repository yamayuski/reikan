# Fuchsia OS

> 日本語版は [fuchsia.ja.md](fuchsia.ja.md) をご覧ください。

---

## Overview

**Fuchsia** is a general-purpose, open-source operating system developed by Google. Unlike Android or Chrome OS, Fuchsia is built from scratch around the **Zircon** microkernel — it does not derive from Linux, POSIX, or any BSD lineage. It has been in development since approximately 2016 and began shipping on Nest Hub smart-display devices in 2021.

Fuchsia's primary goals are:

- A **capability-based security model** where all resource access is mediated through unforgeable kernel handles.
- A **component framework** that treats software components as the fundamental unit of composition, isolation, and deployment.
- Support for multiple hardware targets ranging from embedded devices to workstations.
- A clean break from legacy POSIX assumptions, though a POSIX compatibility layer exists as an opt-in.

### Key Technical Properties

| Property | Detail |
|---|---|
| Kernel | Zircon — capability-based microkernel |
| Primary languages | C++, Rust |
| IPC | Zircon channels (message-passing with handle transfer) |
| Component model | Component Framework v2 (CF2) — declarative manifests, capability routing |
| Interface definition | FIDL (Fuchsia Interface Definition Language) |
| Build system | GN + Ninja |
| Security model | Capability handles; no ambient authority; sealed packages |
| Formal verification | Partial (some kernel invariants; not machine-checked proof of full kernel) |
| AI focus | None — general-purpose workloads |

---

## Similarities with Reikan

| Dimension | Fuchsia | Reikan |
|---|---|---|
| **Kernel lineage** | Non-POSIX, non-Linux, ground-up design | Non-POSIX, non-Linux, ground-up design |
| **Security model** | Capability-based; no ambient authority | Capability-centric; no ambient authority |
| **Architecture** | Microkernel (Zircon) + system services above | Verified microkernel + system services layer |
| **Component model** | Components as first-class runtime units | Agents as first-class OS citizens |
| **IPC** | Channel-based with capability handles | Capability-mediated IPC |
| **Legacy break** | No POSIX obligation by design | No POSIX, no Win32, no ELF obligation |
| **Rust adoption** | Rust is a first-class language alongside C++ | Reikan-lang is designed to be LLM-friendly and safe; Rust may be used for bootstrapping |
| **Interface definition** | FIDL — typed, versioned IDL | Reikan will need its own interface layer |

---

## Differences from Reikan

| Dimension | Fuchsia | Reikan |
|---|---|---|
| **AI focus** | General-purpose; no AI-specific abstractions | AI agents, model inference, and LLM pipelines are first-class OS constructs |
| **Formal verification** | Partial; not machine-checked proof of full kernel | Full formal verification of TCB is a design goal |
| **Primary language** | C++ and Rust (existing languages) | Reikan-lang — a new language designed for LLM authorship and formal reasoning |
| **Heterogeneous compute** | Limited native GPU/NPU scheduling | GPU, NPU, VRAM, and accelerator resources as first-class scheduled entities |
| **Observability** | Component event logging; not uniformly auditable | Every capability grant, model invocation, and policy override is an auditable event |
| **Target workload** | Embedded → desktop; general applications | AI inference, autonomous agents, knowledge-intensive computation |
| **Development model** | Traditional engineering team | AI-led development (LLMs as active contributors) |
| **Agent abstraction** | No agent concept | Agents with goals, memory, tool access, and lifetime are native kernel objects |

---

## Points to Reference / Learn From

### 1. Capability Handle Model (Zircon)
Zircon's kernel object handles with explicit rights are one of the clearest production implementations of capability security. The handle transfer semantics across IPC channels, the notion of sealed rights, and the policy of **no ambient authority** should be studied when designing Reikan's capability table and delegation rules.

### 2. FIDL — Fuchsia Interface Definition Language
FIDL provides typed, versioned, transport-agnostic interface contracts between components. It generates bindings in multiple languages and enforces wire-compatibility rules. Reikan will need an equivalent IDL layer for inter-agent and inter-component contracts; FIDL's evolution model (API vs ABI compatibility) is worth studying.

### 3. Component Framework v2 (CF2)
CF2 separates component **topology** (who can offer what to whom) from component **instantiation**. Capability routing is declared in component manifests, not hardcoded. This clean separation between policy and mechanism is directly relevant to Reikan's capability manager design.

### 4. Sealed Package Model
Fuchsia packages are content-addressed and sealed at build time. Combined with capability routing, this constrains what any component can access. A similar sealed artifact model may be appropriate for Reikan's agent deployment.

### 5. Driver Framework (DFv2)
Fuchsia's modern driver framework models drivers as components with declared capabilities rather than privileged kernel modules. This is a useful reference for Reikan's hardware abstraction layer design.

---

## References

- [Fuchsia OS official documentation](https://fuchsia.dev/)
- [Zircon Kernel Concepts](https://fuchsia.dev/fuchsia-src/concepts/kernel)
- [Capability-based security in Fuchsia](https://fuchsia.dev/fuchsia-src/concepts/security/capability-based-security)
- [FIDL overview](https://fuchsia.dev/fuchsia-src/development/languages/fidl/overview)
- [Component Framework v2](https://fuchsia.dev/fuchsia-src/concepts/components/v2)
- Fuchsia source: [https://fuchsia.googlesource.com/](https://fuchsia.googlesource.com/)
