# Redox OS

> 日本語版は [redox-os.ja.md](redox-os.ja.md) をご覧ください。

---

## Overview

**Redox OS** is an open-source, Unix-like operating system written entirely in **Rust**, developed by Jeremy Sousa and contributors since 2015. It is a microkernel-based OS designed from scratch — not a fork of Linux, GNU, or any existing Unix. Despite its microkernel structure, Redox provides a degree of POSIX compatibility to run existing software such as Bash, GCC, and SDL2.

Redox's central thesis is that Rust's ownership model and type system are the right tools for building a safe operating system: memory safety enforced at the language level, rather than through formal proof. It is notable for its **URL-scheme-based resource model**, where virtually everything — files, network sockets, hardware devices — is addressed as a URL handled by user-space "scheme providers."

### Key Technical Properties

| Property | Detail |
|---|---|
| Kernel | Redox microkernel — minimal, written in Rust |
| Primary language | Rust |
| IPC | File-descriptor-like scheme interface |
| Resource model | URL schemes (`file:`, `tcp:`, `display:`, `orbital:`, etc.) |
| Security model | Scheme-based isolation; namespaces; partial capability model |
| POSIX compatibility | Partial (via relibc — Redox's own C standard library) |
| Formal verification | None — relies on Rust's type safety |
| AI focus | None — general desktop/embedded OS |
| GUI | Orbital — a minimal Wayland-inspired compositor |

---

## Similarities with Reikan

| Dimension | Redox OS | Reikan |
|---|---|---|
| **Origin** | Not a fork of Linux or any Unix | Not a fork of Linux, Windows, or macOS |
| **Architecture** | Microkernel — minimal kernel, services in user space | Verified microkernel + system services layer |
| **Primary language** | Rust — memory safety as a core property | Reikan-lang with Rust for bootstrapping |
| **Safety philosophy** | Memory safety enforced at language level | Safety enforced by both language and formal proof |
| **Scheme model** | URL-based resource addressing (universal interface) | Object store with capability-mediated access |
| **Microkernel discipline** | Drivers and services in user space | Drivers and services above the verified kernel |
| **Rust ecosystem** | Full Rust ecosystem integration | Rust usable for system service layer |

---

## Differences from Reikan

| Dimension | Redox OS | Reikan |
|---|---|---|
| **POSIX compatibility** | Partial POSIX via relibc — a design compromise | No POSIX by design; compatibility as a future opt-in layer |
| **AI focus** | General desktop OS; no AI-specific abstractions | AI agents, model inference, LLM pipelines as first-class OS constructs |
| **Formal verification** | None — relies solely on Rust's type checker | Machine-checked formal proof of TCB is a design goal |
| **Capability model** | Scheme namespacing; not full capability security | Full capability-based security with unforgeable authority tokens |
| **Heterogeneous compute** | No GPU/NPU scheduling | GPU, NPU, VRAM, and accelerators as first-class scheduled resources |
| **Agent abstraction** | No agent concept | Agents with goals, memory, tools, and lifetime as native kernel objects |
| **Observability** | Standard Unix-style logging | Every capability grant and model invocation is an auditable event |
| **Development model** | Traditional open-source community | AI-led development (LLMs as active contributors) |
| **GUI stack** | Orbital compositor | AI-native shell, workspace graph, and conversational control |

---

## Points to Reference / Learn From

### 1. Rust for OS Implementation
Redox is the most complete demonstration that Rust can be used end-to-end for an OS kernel and its system services. The practical challenges encountered — `unsafe` blocks in kernel code, FFI boundaries, hardware-specific intrinsics, and interrupt handlers — are directly relevant to Reikan's use of Rust for its bootstrap layer and system services.

### 2. URL-Scheme Resource Model
Redox's scheme model is a clean generalization of the Unix "everything is a file" philosophy: instead of a filesystem hierarchy, resources are addressed by URL scheme, and any user-space service can register as a scheme provider. This is a simpler and more composable interface than POSIX file descriptors. Reikan could explore an analogous abstraction at the agent/object store interface layer.

### 3. Microkernel Service Isolation
Redox demonstrates that network drivers, display drivers, and storage drivers can all live in user space under a microkernel without prohibitive performance overhead. This is evidence that Reikan's microkernel architecture is practical, not just theoretically desirable.

### 4. `relibc` — Lessons in Compatibility Layer Design
Redox's development of a clean-room C standard library (relibc) to enable POSIX compatibility without kernel modifications is a useful lesson: compatibility layers can be implemented entirely in user space, keeping the kernel free of legacy constraints. Reikan should note that POSIX compatibility, if ever needed, can be added as a user-space layer without kernel compromise.

### 5. Community-Driven Rust OS Development
Redox's decade-long development history as an open-source, community-driven project is a useful reference for Reikan's contribution model — in particular, managing a complex Rust codebase with many contributors over time.

---

## References

- [Redox OS official website](https://www.redox-os.org/)
- [Redox OS book](https://doc.redox-os.org/book/)
- [Redox OS GitLab](https://gitlab.redox-os.org/redox-os/redox)
- [Redox OS microkernel source](https://gitlab.redox-os.org/redox-os/kernel)
- [relibc](https://gitlab.redox-os.org/redox-os/relibc)
