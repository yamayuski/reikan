# Mojo

> 日本語版は [mojo.ja.md](mojo.ja.md) をご覧ください。

---

## Overview

**Mojo** is a programming language designed by **Modular** (founded by Chris Lattner, creator of LLVM and Swift) and announced in 2023. Its stated goal is to be the systems language for AI: a superset of Python that can compile down to high-performance native code, target heterogeneous hardware (CPU, GPU, TPU, accelerators) through **MLIR**, and serve as the single language for both AI research (Python ergonomics) and AI systems programming (C-like performance).

Mojo introduces `struct` types with value semantics, an ownership model inspired by Rust, SIMD intrinsics, and progressive lowering through MLIR to hardware-specific backends. It is designed to eventually replace C/C++ in AI infrastructure (CUDA kernels, custom ops, runtime internals) while remaining interoperable with the Python ecosystem.

### Key Technical Properties

| Property | Detail |
|---|---|
| Paradigm | Multi-paradigm: imperative, OO, functional elements |
| Python compatibility | Superset of Python — valid Python is valid Mojo (with caveats) |
| Type system | Static types + dynamic Python types; `struct` with value semantics; ownership model |
| Compilation | AOT and JIT via MLIR → LLVM IR → native code |
| Hardware targeting | CPU (SIMD), GPU (via MLIR GPU dialect), accelerators |
| Memory model | Ownership + borrowing (inspired by Rust); SIMD-aware layouts |
| MLIR integration | First-class; Mojo is built on top of MLIR |
| Interoperability | Python interop; C/C++ FFI |
| Formal verification | None |
| AI focus | Central — designed for AI/ML workloads and infrastructure |
| Developer | Modular Inc. (proprietary + partial OSS) |

### MLIR Compilation Pipeline

```
Mojo source
     ↓
Mojo IR (high-level)
     ↓
MLIR dialects (affine, gpu, vector, tensor, etc.)
     ↓
LLVM IR
     ↓
Native machine code (CPU / GPU / accelerator)
```

---

## Similarities with Reikan

| Dimension | Mojo | Reikan |
|---|---|---|
| **Design goal** | Language purpose-built for AI workloads | AI-First OS with a purpose-built language (Reikan-lang) |
| **AI as primary concern** | AI/ML infrastructure as the reason the language exists | AI agents and inference are first-class OS constructs |
| **Heterogeneous compute** | Native targeting of CPU, GPU, and accelerators via MLIR | GPU, NPU, VRAM, and accelerators as first-class scheduled resources |
| **Ownership model** | Rust-inspired ownership for memory safety without GC | Reikan-lang targets memory safety and formal verifiability |
| **MLIR-based compilation** | Mojo compiles through MLIR for hardware portability | Reikan's compiler/IR should target MLIR or an equivalent progressive lowering pipeline |
| **Systems + AI in one language** | AI research ergonomics + systems programming performance | Reikan-lang is designed for both kernel-level systems code and agent-level logic |
| **Legacy rupture** | Python superset, but its systems layer abandons C/C++ assumptions | Reikan abandons POSIX, ELF, and C/C++ assumptions |
| **Performance focus** | Inference latency and throughput as explicit optimization targets | Inference latency and token throughput are primary non-functional requirements |

---

## Differences from Reikan

| Dimension | Mojo | Reikan |
|---|---|---|
| **Scope** | Programming language (user-space and ML infra) | OS + systems language |
| **OS primitives** | None — Mojo is a language, not an OS | Kernel, scheduler, capability manager, agent runtime |
| **Python superset** | Explicit Python superset commitment | No Python compatibility layer at language level |
| **Formal verification** | None — no proof-based correctness | Machine-checked formal proof of TCB |
| **Capability security** | No capability model | Full capability-based security |
| **Agent abstraction** | No agent OS concept | Agents with goals, memory, tools, and lifetime as native OS objects |
| **Observability** | Standard profiling and tracing tools | Every capability grant and model invocation is a uniform auditable event |
| **Ownership** | Proprietary language (Modular), partially OSS | Reikan is fully open |
| **LLM authorship** | Not specifically designed for LLM code generation | Reikan-lang is designed to be authored by both humans and LLMs |
| **Hardware isolation** | User-space language; relies on OS for isolation | Hardware-enforced capability isolation in the OS |

---

## Points to Reference / Learn From

### 1. MLIR as the Compilation Target
Mojo's architecture demonstrates that MLIR is a practical universal compilation substrate for a language that needs to target CPU, GPU, and specialized accelerators from a single source language. Reikan's compiler (for Reikan-lang) should seriously evaluate MLIR as the intermediate representation, rather than reinventing a heterogeneous lowering pipeline.

### 2. Progressive Lowering
Mojo uses MLIR's progressive lowering model: high-level semantic representations are gradually lowered to hardware-specific operations. This allows high-level AI code to map to CUDA kernels or Apple Neural Engine ops without loss of portability. Reikan-lang should adopt the same progressive lowering philosophy to support the heterogeneous compute abstraction.

### 3. Value Semantics for AI Data
Mojo's `struct` types have value semantics by default — a significant departure from Python's reference semantics. This enables efficient stack allocation and SIMD-aware data layouts for tensor types. Reikan-lang's type system should similarly favor value semantics for performance-critical agent state and model activation types.

### 4. Ownership Without Borrow Checker Friction
Mojo's ownership model aims to provide Rust's safety guarantees with less friction at the call site (fewer explicit lifetime annotations). Reikan-lang has an opportunity to go further: because formal verification is a design goal, the ownership model can be designed with proof-friendliness as a first-class concern, not just ergonomics.

### 5. One Language for Research and Systems
Mojo's bet — that a single language can serve both AI research (Python ergonomics) and systems programming (C performance) — validates Reikan's approach of designing Reikan-lang to serve both agent-level logic and kernel-level systems code. The lesson: the type system and ownership model must be designed to support both high-level abstractions and low-level control without different dialects.

### 6. Inference Latency as a First-Class Language Concern
Mojo makes inference throughput and latency explicit design axes: SIMD intrinsics, cache-friendly data layouts, and GPU kernel dispatch are first-class language features. Reikan should encode similar performance contracts into Reikan-lang's type system — particularly for the model runtime layer where VRAM bandwidth and inference latency are the dominant constraints.

---

## References

- [Mojo official documentation](https://docs.modular.com/mojo/)
- [Modular blog: Why we built Mojo](https://www.modular.com/blog/why-we-built-mojo)
- Lattner, C. et al. (2021). "MLIR: Scaling Compiler Infrastructure for Domain Specific Computation." *CGO 2021*.
- [Mojo GitHub (partial open source)](https://github.com/modularml/mojo)
- [MLIR documentation](https://mlir.llvm.org/)
