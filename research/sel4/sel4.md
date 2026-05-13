# seL4 Microkernel

> 日本語版は [sel4.ja.md](sel4.ja.md) をご覧ください。

---

## Overview

**seL4** is a high-assurance microkernel developed by NICTA (now CSIRO's Data61) and the seL4 Foundation. It is the first operating-system kernel to receive a **machine-checked formal proof of functional correctness** — meaning that the kernel's C implementation provably matches a high-level abstract specification. Beyond correctness, seL4 has proofs of security enforcement (integrity and confidentiality) and, for some configurations, worst-case execution time bounds for real-time certification.

seL4 is designed for use in safety-critical and security-critical systems. It has been deployed in avionics, automotive, industrial control, and defense contexts. It is the reference point for what "formally verified" means in OS security research.

### Key Technical Properties

| Property | Detail |
|---|---|
| Kernel | Third-generation L4 microkernel |
| Primary language | C (kernel); Rust ports under development (ferrocene, microkit) |
| Proof assistant | Isabelle/HOL |
| Proofs | Functional correctness, integrity, confidentiality, WCET (partial) |
| Security model | Capability-based (seL4 capabilities = unforgeable authority tokens) |
| IPC | Synchronous endpoints with capability invocation |
| Objects | CNode, TCB, Endpoint, Notification, VSpace, Frame, Untyped, IRQHandler |
| Scheduling | MCS (Mixed-Criticality Systems) scheduler |
| Formal spec | Abstract spec in Isabelle/HOL; refined to executable spec; then to C |
| AI focus | None — safety-critical embedded and cyber-physical systems |

### Proof Chain

```
Abstract Specification (Isabelle/HOL)
        ↓ (refinement proof)
Executable Specification
        ↓ (C refinement proof)
C Implementation
        ↓ (verified compilation via CompCert, partially)
Machine Code
```

This layered proof chain is the gold standard for OS formal verification.

---

## Similarities with Reikan

| Dimension | seL4 | Reikan |
|---|---|---|
| **Kernel architecture** | Microkernel — minimal trusted computing base | Verified microkernel — minimal TCB |
| **Security model** | Capability-based; authority is explicit and unforgeable | Capability-centric; all authority explicit and delegatable |
| **Formal verification** | Machine-checked proof of correctness, integrity, confidentiality | Full formal verification of TCB is a stated design goal |
| **No ambient authority** | All resource access via capabilities; no bypass | Capability mediation with no ambient authority |
| **Proof tooling** | Isabelle/HOL | Lean 4, Coq, or Iris are candidates for Reikan |
| **Minimality** | Kernel does only what must be in kernel | Kernel does only what must be in kernel |
| **IPC design** | Capability-carrying IPC messages | Capability-mediated IPC |
| **Object model** | Untyped memory retyped into kernel objects | Memory object model with typed lifecycle |

---

## Differences from Reikan

| Dimension | seL4 | Reikan |
|---|---|---|
| **AI focus** | None — embedded safety-critical workloads | AI agents, LLM pipelines, and model inference are first-class OS constructs |
| **Language** | C with Isabelle/HOL proofs | Reikan-lang — a new language designed for formal reasoning and LLM authorship |
| **Heterogeneous compute** | No native GPU/NPU scheduling | GPU, NPU, VRAM, and accelerators are first-class scheduled resources |
| **Agent abstraction** | No agent concept | Agents with goals, memory, tool access, and lifetime are native kernel objects |
| **Observability** | Kernel audit is implicit in capability mediation, not event-streamed | Every capability grant, model invocation, and policy override is an auditable event |
| **Development model** | Traditional academic and industrial engineering | AI-led development (LLMs as active contributors) |
| **Target workload** | Real-time embedded, avionics, automotive | AI inference, autonomous agents, knowledge-intensive personal computing |
| **User-space model** | Thin user-space libraries; policy pushed to user | Rich system services layer above verified kernel |
| **POSIX** | POSIX compatibility layer exists (seL4-POSIX) | No POSIX layer by design |
| **Scale** | Very small kernel (~8,700 LOC) | Kernel scope TBD; minimality is a goal |

---

## Points to Reference / Learn From

### 1. The Refinement Proof Methodology
seL4's proof chain — Abstract Specification → Executable Specification → C Implementation — is the canonical example of how to formally verify a real OS kernel. Reikan should adopt a similar layered approach: write abstract specs in a proof assistant first, then refine to Reikan-lang, then machine-check the refinement.

### 2. Capability Object Model
seL4's small set of kernel objects (CNode, TCB, Endpoint, VSpace, Frame, Untyped, Notification) and the rules governing how capabilities are created, delegated, and revoked are a direct reference for Reikan's capability manager. Particularly: **Untyped memory** and the retype operation cleanly model memory lifecycle without runtime allocation ambiguity.

### 3. CNode — Capability Space Navigation
seL4's CNode model (a kernel-managed tree of capability slots, addressable by index paths) is a well-studied alternative to flat capability tables. The trade-offs between CNode-style hierarchical capability namespaces and flat tables are worth analyzing for Reikan.

### 4. MCS Scheduler
seL4's Mixed-Criticality Systems (MCS) extension separates scheduling policy (what runs when) from scheduling domain (which components have real-time guarantees). This separation of concerns is relevant to Reikan's heterogeneous scheduler, which must handle both low-latency AI inference and background batch jobs.

### 5. Minimal TCB Discipline
seL4 enforces a discipline that the kernel must do the minimum possible: no file systems, no networking, no device drivers in kernel. Everything else is in user space. This principle of **TCB minimality** is a design constraint Reikan should preserve — especially as the system services layer grows to include model runtimes and storage.

### 6. Proof Toolchain Lessons
The seL4 project produced extensive experience with proof engineering at scale: managing large Isabelle proof scripts, handling proof maintenance during kernel changes, and the cost of proof for new features. Reikan's formal verification strategy should learn from this experience — in particular, designing the kernel with proof cost in mind from the start.

---

## References

- [seL4 official documentation](https://docs.sel4.systems/)
- Klein, G. et al. (2009). "seL4: Formal Verification of an OS Kernel." *SOSP 2009*. ([PDF](https://sel4.systems/publications/2009/Klein_EHACDEEKNSTW_09.pdf))
- Heiser, G. & Elphinstone, K. (2016). "L4 Microkernels: The Lessons from 20 Years of Research and Deployment." *ACM TOCS 34(1)*.
- [seL4 GitHub](https://github.com/seL4/seL4)
- [seL4 Foundation](https://sel4.systems/)
- [seL4 Isabelle/HOL proofs](https://github.com/seL4/l4v)
