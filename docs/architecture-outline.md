# Reikan AI-First OS — Architecture Design Document Outline

> **Status:** Draft — Phase 0 (Architecture Definition)
>
> This document captures the full table-of-contents-level outline for the Reikan architecture specification. Individual sections will be expanded into their own design documents as the project matures.

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Design Philosophy](#2-design-philosophy)
3. [Requirements and Scope](#3-requirements-and-scope)
4. [Security Model](#4-security-model)
5. [Formal Verification Strategy](#5-formal-verification-strategy)
6. [Systems Language Specification](#6-systems-language-specification)
7. [Compiler, IR, and Toolchain](#7-compiler-ir-and-toolchain)
8. [Boot and Initialization](#8-boot-and-initialization)
9. [Kernel Architecture](#9-kernel-architecture)
10. [Memory Management](#10-memory-management)
11. [Capability Management](#11-capability-management)
12. [Execution Management](#12-execution-management)
13. [Inter-Process Communication (IPC)](#13-inter-process-communication-ipc)
14. [Scheduling](#14-scheduling)
15. [Device Drivers and Hardware Abstraction](#15-device-drivers-and-hardware-abstraction)
16. [Heterogeneous Compute](#16-heterogeneous-compute)
17. [Model Runtime](#17-model-runtime)
18. [Storage and Object Store](#18-storage-and-object-store)
19. [Search and Knowledge Retrieval](#19-search-and-knowledge-retrieval)
20. [Networking and Distributed Mesh](#20-networking-and-distributed-mesh)
21. [Agent OS APIs](#21-agent-os-apis)
22. [Human UI and Interaction Model](#22-human-ui-and-interaction-model)
23. [Developer Experience](#23-developer-experience)
24. [AI-Led Development Process](#24-ai-led-development-process)
25. [Testing and Conformance](#25-testing-and-conformance)
26. [Observability and Audit](#26-observability-and-audit)
27. [Reliability and Fault Tolerance](#27-reliability-and-fault-tolerance)
28. [Performance Model](#28-performance-model)
29. [Power and Thermal Management](#29-power-and-thermal-management)
30. [Portability and Hardware Targets](#30-portability-and-hardware-targets)
31. [Packaging and Updates](#31-packaging-and-updates)
32. [Governance and Decision Authority](#32-governance-and-decision-authority)
33. [Roadmap](#33-roadmap)
34. [Risks and Mitigations](#34-risks-and-mitigations)
35. [Appendices](#35-appendices)

---

## 1. Executive Summary

- 1.1 Project motivation and goals
- 1.2 What Reikan is and is not
- 1.3 Relationship to existing OS research (seL4, Fuchsia, Redox, etc.)
- 1.4 Key differentiators
- 1.5 Current phase and scope
- 1.6 How to read this document

---

## 2. Design Philosophy

- 2.1 Core thesis: AI agents as first-class OS citizens
- 2.2 Rupture from legacy application compatibility assumptions
- 2.3 Optimization targets
  - 2.3.1 Inference, search, and planning latency
  - 2.3.2 Token throughput across heterogeneous resources
  - 2.3.3 Auditability and reproducibility
  - 2.3.4 Agent-to-agent coordination efficiency
- 2.4 Primary abstractions
  - Agent, Capability, Context, Memory Object, Execution Graph, Model Resource, Policy Proof
- 2.5 What is explicitly abandoned
  - POSIX, Win32, ELF, fork/exec, pathname-centric I/O, syscall ABI, string-centric API
- 2.6 Design invariants (non-negotiable constraints)
- 2.7 Human–machine harmony: co-control principles

---

## 3. Requirements and Scope

- 3.1 Functional requirements
  - 3.1.1 Phase 0 (architecture definition)
  - 3.1.2 v0 target (minimum bootable OS with capability isolation and GPU scheduling)
  - 3.1.3 v1 target (agent OS API, object store, model runtime)
- 3.2 Non-functional requirements
  - Safety, verifiability, auditability, performance, portability
- 3.3 Explicit out-of-scope items
  - Legacy application compatibility (Phase 0–3)
  - Multi-node federation (Phase 0–4)
- 3.4 Hardware target scope
  - Initial target: aarch64
  - Secondary target: x86_64
  - Accelerator targets: NVIDIA GPU, AMD GPU, Apple Neural Engine, Qualcomm NPU
- 3.5 Use-case definition
  - AI research and inference workstation
  - Autonomous development environment
  - Knowledge-intensive personal computing

---

## 4. Security Model

- 4.1 Security philosophy: default-deny, least-privilege, explicit delegation
- 4.2 Threat model
  - 4.2.1 Classical OS threats (privilege escalation, memory corruption, side channels)
  - 4.2.2 AI-era threats
    - Prompt injection
    - Tool misuse by AI agents
    - Model weight exfiltration
    - Memory poisoning
    - Training data leakage
    - Policy drift
    - Self-modifying agent runaway
    - Covert channels (e.g., GPU timing side channels)
- 4.3 Capability model overview (see §11 for detail)
- 4.4 Trust boundaries and attestation
- 4.5 Confidential compute integration
- 4.6 AI-specific mitigations
  - Capability-separated tool access
  - Taint tracking for model outputs
  - Provenance graph for data lineage
  - Reversible execution checkpoints
  - Policy firewall for high-risk actions
  - Multi-authority approval for irreversible operations
- 4.7 Audit and accountability (see §26 for detail)
- 4.8 Root of trust and secure boot chain
- 4.9 Autonomous Vulnerability Defense System
  - 4.9.1 Design charter: defend before being attacked
  - 4.9.2 AI-driven real-time vulnerability intelligence ingestion (CVE feeds, SNS, security advisories)
  - 4.9.3 Automated threat triage and severity classification
  - 4.9.4 Autonomous mitigation generation and hot-patching pipeline
  - 4.9.5 Human-in-the-loop escalation for high-impact or irreversible mitigations
  - 4.9.6 Response time goal: vulnerability-to-mitigation faster than human reaction
  - 4.9.7 Mitigation confidence thresholds and rollback guarantees
- 4.10 Supply Chain Security
  - 4.10.1 Cryptographic provenance verification for all build inputs
  - 4.10.2 Reproducible and hermetic build pipeline
  - 4.10.3 Dependency integrity monitoring and continuous re-verification
  - 4.10.4 AI-assisted dependency risk scoring (typosquatting, maintainer compromise, hidden backdoors)
  - 4.10.5 Build environment attestation and isolation
  - 4.10.6 Runtime artifact verification at load time
- 4.11 Kernel-Level Proactive Defense
  - 4.11.1 Continuous kernel integrity monitoring (live invariant checking)
  - 4.11.2 Automated patch application for kernel CVEs without reboot where possible
  - 4.11.3 Exploit technique fingerprinting and preemptive hardening
  - 4.11.4 Speculative execution and side-channel isolation controls
  - 4.11.5 Kernel self-attestation and anomaly detection

---

## 5. Formal Verification Strategy

- 5.1 Verification goals and scope
- 5.2 Trusted computing base (TCB) definition and minimization
- 5.3 Specification language (L0: formal specification layer)
- 5.4 Proof assistant selection and rationale
- 5.5 Verified properties
  - Capability non-leakage
  - Memory safety invariants
  - Scheduler fairness and progress
  - IPC integrity
  - Policy soundness
- 5.6 Verification toolchain and workflow
- 5.7 Unsafe islands: identification, isolation, and proof obligations
- 5.8 Limits of verification and residual risk

---

## 6. Systems Language Specification

- 6.1 Language design goals
  - Human-readable, LLM-writable, formally grounded
- 6.2 Language layers
  - 6.2.1 L0: Formal specification language (OS constitution)
  - 6.2.2 L1: Systems implementation language (kernel, drivers, runtime)
  - 6.2.3 L2: Agent and application description language (high-level, declarative)
- 6.3 Type system
  - Linear types
  - Affine types
  - Algebraic effects
  - Typestate
  - Capability types
  - Region types
  - Lightweight dependent constraints
- 6.4 Execution model
  - Task graph (primary)
  - Actor model (auxiliary)
  - Zero-copy message passing
  - Predictable resource destruction
  - Compile-time specialization
- 6.5 Capability encoding in the type system
- 6.6 Concurrency and parallelism model
  - Structured concurrency
  - Data-race freedom by construction
- 6.7 Memory safety guarantees
- 6.8 Unsafe island model
  - Syntax and scope of unsafe blocks
  - Proof obligations at unsafe boundaries
- 6.9 Module and package system
- 6.10 Syntax design principles
  - Unambiguous grammar
  - Stable AST under formatting
  - Structured metadata and specification links in code
  - LLM-friendly normalization
- 6.11 Standard library philosophy
- 6.12 Foreign interface (hardware, MMIO, ISA intrinsics)

---

## 7. Compiler, IR, and Toolchain

- 7.1 Compilation pipeline overview
  - Frontend AST → Normalized IR → Verification IR → Low-level IR → ISA Backend
- 7.2 Frontend: parsing, name resolution, type inference
- 7.3 Intermediate representations
  - 7.3.1 Normalized IR (high-level, human+AI readable, stable diff)
  - 7.3.2 Verification IR (annotated with proof obligations)
  - 7.3.3 Low-level IR (machine-near, effect-explicit)
- 7.4 Verifier integration
- 7.5 Optimization strategy
  - Semantics-preserving optimization with machine-checked proofs
  - Fast path vs. verified path trade-offs
- 7.6 ISA backends
  - 7.6.1 aarch64
  - 7.6.2 x86_64
  - 7.6.3 GPU compute (PTX / AMDGPU IR / Metal / SPIR-V)
- 7.7 Build system and reproducibility
- 7.8 Linker and binary format
- 7.9 Development toolchain
  - Formatter, linter, documentation generator, test harness
- 7.10 AI-assisted code generation workflow and attribution

---

## 8. Boot and Initialization

- 8.1 Boot philosophy: minimal, verified, auditable
- 8.2 Firmware interface (UEFI / device tree)
- 8.3 Bootloader design
- 8.4 Early hardware initialization
  - CPU mode setup
  - MMU / page table initialization
  - Interrupt and exception setup
  - Clock and timer initialization
- 8.5 Early memory allocator
- 8.6 Serial console and early diagnostics
- 8.7 Kernel image verification and attestation
- 8.8 Handoff to the kernel
- 8.9 Kernel early initialization sequence
- 8.10 First capability table construction
- 8.11 First user-space service launch

---

## 9. Kernel Architecture

- 9.1 Kernel structure: verified microkernel core + system services layer
- 9.2 Trusted computing base boundaries
- 9.3 Microkernel core responsibilities
  - Address space management
  - Capability table management
  - Minimal scheduler nucleus
  - IPC
  - Interrupt and exception handling
  - Device isolation boundary enforcement
  - Timer and clock
- 9.4 System services layer (non-TCB)
  - GPU runtime, object store, model manager, network stack, UI compositor, policy engine, observability fabric
- 9.5 Kernel entry and exit paths
- 9.6 Kernel data structures and invariants
- 9.7 Kernel memory layout
- 9.8 Kernel self-protection mechanisms
- 9.9 Kernel upgrade and live patching model

---

## 10. Memory Management

- 10.1 Memory philosophy: hierarchy is a first-class OS concept
- 10.2 Memory object types
  - Hot token memory
  - Model weight memory
  - Persistent object memory
  - Vector / embedding memory
  - Shared context memory
  - Confidential memory
  - Stream memory
  - Checkpoint memory
- 10.3 Physical memory management
  - Region-based allocation
  - Large page and HBM support
- 10.4 Virtual memory and address spaces
  - Capability-controlled mappings
  - No ambient access to arbitrary addresses
- 10.5 Object handles vs. raw pointers
  - Region handle, object capability, typed slice, immutable snapshot, stream endpoint
- 10.6 VRAM and unified memory management
- 10.7 Memory migration and residency control
- 10.8 Persistence and checkpointing
- 10.9 Memory safety enforcement
- 10.10 Memory auditing and accounting

---

## 11. Capability Management

- 11.1 Capability model definition
- 11.2 Capability types
  - Memory capabilities
  - Execution capabilities
  - Device capabilities
  - Model resource capabilities
  - Communication capabilities
  - Administrative capabilities
- 11.3 Capability table structure and implementation
- 11.4 Capability creation, delegation, and revocation
- 11.5 Capability attenuation (restricting on delegation)
- 11.6 Capability propagation rules (static and dynamic)
- 11.7 Capability tokens and proof-carrying authority
- 11.8 Capability auditing
- 11.9 Interaction with the formal verification model

---

## 12. Execution Management

- 12.1 Execution units
  - Agent (long-lived, goal-bearing, memory-owning)
  - Task (short-lived computation)
  - Flow (DAG of tasks)
  - Session (context container for human–agent interaction)
  - Tool invocation
  - Watcher (reactive observer)
  - Policy guard
- 12.2 Agent lifecycle: creation, initialization, suspension, migration, termination
- 12.3 Task graph execution model
- 12.4 Context management and handoff
- 12.5 Failure isolation and containment
- 12.6 Agent state persistence and resume
- 12.7 Resource quotas and enforcement

---

## 13. Inter-Process Communication (IPC)

- 13.1 IPC philosophy: typed, capability-gated, zero-copy where possible
- 13.2 IPC primitives
  - Synchronous call
  - Asynchronous message
  - Shared memory region (capability-controlled)
  - Stream endpoint
  - Notification
- 13.3 Message format: schema-aware structured types (no raw strings)
- 13.4 IPC performance model and fast path
- 13.5 IPC and capability transfer
- 13.6 IPC auditing
- 13.7 Record/replay for deterministic testing

---

## 14. Scheduling

- 14.1 Scheduler philosophy: heterogeneous resource orchestration
- 14.2 Scheduled resources
  - CPU cores and SMT threads
  - GPU compute queues
  - NPU/TPU execution slots
  - DMA engines
  - Memory bandwidth
  - VRAM/HBM
  - Storage IOPS
  - NIC queues
  - Power/thermal budget
- 14.3 Scheduling units
  - Operator graphs
  - Kernel launch batches
  - Token decode loops
  - Retrieval requests
  - Prefetch plans
  - Memory migration actions
- 14.4 Scheduling layers
  - Layer 1: Real-time and safety constraints
  - Layer 2: Interactive optimization (human-facing inference and display)
  - Layer 3: Background optimization (indexing, training, compression, cache migration)
- 14.5 Token-based QoS
  - Tokens per second, joules per token, quality level, model priority
- 14.6 Fairness and starvation prevention
- 14.7 Scheduler formal properties

---

## 15. Device Drivers and Hardware Abstraction

- 15.1 Driver philosophy: AI-writable but not AI-breakable
- 15.2 Driver decomposition
  - Verified device core (TCB portion)
  - Device protocol layer (command description)
  - Policy/runtime layer (high-level control)
  - Vendor adaptation pack (hardware-specific differences)
- 15.3 Device description DSL
  - MMIO ranges, doorbells, ring buffers, descriptor formats, interrupt semantics, DMA constraints
- 15.4 Driver isolation and fault containment
- 15.5 Safe wrapper generation from device descriptions
- 15.6 Driver hot-reload and update model
- 15.7 Specific driver subsystems
  - Storage (NVMe, UFS)
  - Network (Ethernet, Wi-Fi, PCIe)
  - Display and compositor
  - Input devices
  - GPU/NPU (see §16)
  - Sensors and real-time peripherals

---

## 16. Heterogeneous Compute

- 16.1 Design goal: CPU, GPU, NPU, TPU as first-class unified resource fabric
- 16.2 Compute abstraction model
  - Unified command queue abstraction
  - Operator graph representation
  - Cross-device dependency tracking
- 16.3 Memory model for heterogeneous compute
  - Unified memory planning
  - Explicit vs. implicit migration
  - Cache residency control
- 16.4 Device-specific adaptation layers
  - 16.4.1 NVIDIA GPU (CUDA/PTX)
  - 16.4.2 AMD GPU (ROCm/AMDGPU)
  - 16.4.3 Apple GPU and Neural Engine (Metal)
  - 16.4.4 Qualcomm NPU
  - 16.4.5 Google TPU-like accelerators
- 16.5 Graph executor design
- 16.6 Kernel launch batching and fusion
- 16.7 Performance profiling and feedback loop

---

## 17. Model Runtime

- 17.1 Model runtime goals
- 17.2 Model object: definition, versioning, and capability
- 17.3 Model loading and weight management
- 17.4 Inference execution pipeline
  - Prefill, decode, speculative execution
- 17.5 KV cache management
- 17.6 Model scheduling and preemption
- 17.7 Multi-model execution and resource sharing
- 17.8 Model attestation and integrity verification
- 17.9 Confidential inference support
- 17.10 Model update and hot-swap
- 17.11 Model output trust policy (model outputs are untrusted by default)

---

## 18. Storage and Object Store

- 18.1 Storage philosophy: knowledge object store, not file system
- 18.2 Object types
  - Document object
  - Code object
  - Model object
  - Dataset shard
  - Embedding index
  - Execution trace
  - Session memory
  - Policy proof
- 18.3 Object properties
  - Content-addressed
  - Versioned
  - Typed and schema-rich
  - Lineage-tracked
  - Access-controlled via capabilities
  - Embeddable and searchable
- 18.4 Storage backend composition
  - Append-only event log
  - Content-addressed object store
  - Schema-rich structured store
  - Vector index
- 18.5 Persistence and durability guarantees
- 18.6 Garbage collection and reference counting
- 18.7 Legacy file system compatibility (future opt-in layer)

---

## 19. Search and Knowledge Retrieval

- 19.1 Search as an OS-native capability
- 19.2 Search modalities
  - Lexical search
  - Semantic / vector search
  - Structural search
  - Provenance search
- 19.3 Index management and update
- 19.4 Query API design
- 19.5 Retrieval-augmented agent patterns
- 19.6 Privacy and access control in search

---

## 20. Networking and Distributed Mesh

- 20.1 Network philosophy: distributed capability mesh, not sockets
- 20.2 Communication targets
  - Agent-to-agent
  - Model service invocation
  - Object replication
  - Capability delegation across nodes
  - Federated memory synchronization
  - Proof and attestation exchange
- 20.3 Communication principles
  - Mutually attested endpoints
  - Schema-first messaging
  - Backpressure by policy
  - Lineage-preserving replication
  - Encrypted by default
- 20.4 Node identity and discovery
- 20.5 Distributed scheduler coordination
- 20.6 Network stack design
- 20.7 Legacy socket compatibility (future opt-in layer)

---

## 21. Agent OS APIs

- 21.1 API philosophy: typed capability invocations, not syscall strings
- 21.2 Core API surface
  - `request_memory_region`
  - `invoke_model`
  - `fork_context`
  - `publish_object`
  - `subscribe_stream`
  - `create_tool_session`
  - `attest_execution`
  - `delegate_capability`
  - `bind_device_queue`
  - `query_knowledge`
  - `request_approval`
- 21.3 Context and session lifecycle API
- 21.4 Tool invocation and sandboxing API
- 21.5 Memory graph API
- 21.6 Semantic query API
- 21.7 Approval and attestation API
- 21.8 API versioning and stability policy
- 21.9 Agent introspection and self-description

---

## 22. Human UI and Interaction Model

- 22.1 UI philosophy: intent-centric, not application-window-centric
- 22.2 UI information surfaces
  - Current goals and tasks
  - Active context and session state
  - Running agents and their resource usage
  - Proposed actions awaiting approval
  - Trust boundaries
  - Execution cost and resource consumption
- 22.3 UI components
  - View (composable content units)
  - Command palette
  - Conversation pane (human–agent dialog)
  - Graph inspector (execution graph visualization)
  - Trace viewer (audit and timeline)
  - Approval surface (high-risk action confirmation)
  - Live resource and memory map
- 22.4 Compositor design
- 22.5 Input model
- 22.6 Accessibility considerations
- 22.7 UI capability isolation (sandboxed rendering)

---

## 23. Developer Experience

- 23.1 AI-native shell
  - Structural, not textual; goal-oriented, not command-string-oriented
- 23.2 Structural editor
  - AST-level editing with semantic awareness
- 23.3 Semantic debugger
  - State inspection via capability queries
  - Time-travel debugging via execution trace replay
- 23.4 Trace and observability explorer
- 23.5 Reproducible build system
- 23.6 Simulation and emulation harness
- 23.7 Testing infrastructure (see §25)
- 23.8 Package and dependency management
- 23.9 Documentation generation from code and specs

---

## 24. AI-Led Development Process

- 24.1 Development model overview
  - Human: principle-setting, safety boundary approval, final authority
  - AI: implementation generation, test generation, specification checking, optimization search
- 24.2 Development workflow
  1. Human declares constraints and goals
  2. AI generates multiple design candidates
  3. Static verification
  4. Simulation
  5. Differential testing
  6. Security policy check
  7. Human review
  8. Canary execution
  9. Formal artifact update
- 24.3 Code artifact requirements
  - Every artifact: specification, implementation, tests, invariants, change rationale, generation history, review history
- 24.4 Human authority boundaries (non-delegatable to AI)
  - Root of trust, crypto primitive adoption, security policy defaults, hardware privilege transitions, irreversible actions
- 24.5 AI contribution attribution and traceability
- 24.6 Knowledge graph as source of truth (beyond git DAG)
  - Spec links, dependency reasoning, semantic diff, generated-by chain

---

## 25. Testing and Conformance

- 25.1 Testing philosophy: verifiable, reproducible, failure-isolated
- 25.2 Test categories
  - Unit tests (component-level)
  - Integration tests (subsystem interaction)
  - Conformance tests (API contract verification)
  - Property-based tests (randomized invariant checking)
  - Fuzzing (security-critical paths)
  - Simulation tests (full-system emulated)
  - Hardware-in-the-loop tests
- 25.3 Deterministic test mode (record/replay)
- 25.4 AI-generated test coverage policy
- 25.5 Test infrastructure and CI design
- 25.6 Regression and bisection tooling

---

## 26. Observability and Audit

- 26.1 Observability philosophy: everything is inspectable
- 26.2 Auditable events (non-exhaustive)
  - Every capability grant and revocation
  - Every external action by an agent
  - Every model invocation and its outputs
  - Every memory migration
  - Every policy override or exception
  - Every IPC message crossing trust boundaries
- 26.3 Event log design
  - Append-only, content-addressed, tamper-evident
- 26.4 Tracing infrastructure
  - Distributed tracing across agents and nodes
  - Causal ordering
- 26.5 Metrics and telemetry
- 26.6 Audit query interface
- 26.7 Privacy and data minimization in audit logs
- 26.8 Compliance and regulatory considerations

---

## 27. Reliability and Fault Tolerance

- 27.1 Reliability philosophy: fail safely, fail loudly, fail locally
- 27.2 Fault isolation boundaries (aligned with capability boundaries)
- 27.3 Failure modes and recovery strategies
  - Agent failure (restart, migrate, or escalate)
  - Driver failure (isolation and replacement)
  - Model runtime failure (quarantine and fallback)
  - Kernel fault (verified core: halt; service layer: restart)
- 27.4 Checkpointing and rollback
- 27.5 Redundancy model (future: multi-node)
- 27.6 Watchdog and health monitoring

---

## 28. Performance Model

- 28.1 Performance philosophy: measure what matters for AI workloads
- 28.2 Key metrics
  - Tokens per second (end-to-end)
  - Time to first token
  - Joules per token
  - Memory bandwidth utilization
  - Scheduling overhead
  - IPC latency
- 28.3 Performance budget allocation by subsystem
- 28.4 Fast path vs. verified path design
- 28.5 Benchmarking methodology
- 28.6 Performance regression tracking

---

## 29. Power and Thermal Management

- 29.1 Power philosophy: joules per token as a first-class scheduling input
- 29.2 Power domains and device power states
- 29.3 Thermal monitoring and throttling
- 29.4 Power-aware scheduling
- 29.5 Energy accounting per agent/task
- 29.6 Mobile and edge deployment considerations

---

## 30. Portability and Hardware Targets

- 30.1 Portability philosophy: correct first, fast later, portable third
- 30.2 Hardware abstraction layer design
- 30.3 ISA port requirements and checklist
- 30.4 Planned targets
  - aarch64 (primary)
  - x86_64 (secondary)
  - RISC-V (future)
- 30.5 Accelerator portability model
- 30.6 Platform bring-up process

---

## 31. Packaging and Updates

- 31.1 Package philosophy: content-addressed, signed, capability-scoped
- 31.2 Package format
- 31.3 Update mechanism
  - Atomic, rollback-capable
  - Capability re-grant on update
- 31.4 Kernel and system service update model
- 31.5 Agent package distribution
- 31.6 Supply chain integrity

---

## 32. Governance and Decision Authority

- 32.1 Project governance structure
- 32.2 Decision types and authority levels
  - Architectural decisions (ADR process)
  - Security policy decisions (human-only)
  - API stability decisions
  - Hardware target decisions
- 32.3 RFC and ADR process
- 32.4 Code review requirements
- 32.5 AI contribution policy
- 32.6 Conflict resolution process

---

## 33. Roadmap

- 33.1 Phase 0: Architecture constitution (current)
- 33.2 Phase 1: Systems language MVP
- 33.3 Phase 2: Boot chain
- 33.4 Phase 3: Minimum verified kernel
- 33.5 Phase 4: Runtime and system services
- 33.6 Phase 5: GPU/NPU execution fabric
- 33.7 Phase 6: Agent OS APIs
- 33.8 Phase 7: Developer environment
- 33.9 Phase 8: Human UI
- 33.10 Phase 9: Distributed mesh
- 33.11 Milestone criteria and exit conditions per phase

---

## 34. Risks and Mitigations

- 34.1 Technical risks
  - Verification toolchain scalability
  - GPU/NPU abstraction layer divergence
  - AI-generated code consistency at scale
  - Performance vs. safety trade-offs
  - New language adoption and tooling maturity
- 34.2 Process risks
  - Scope creep
  - Loss of architectural coherence over time
  - Dependency on proprietary hardware interfaces
- 34.3 AI-specific risks
  - LLM hallucination in safety-critical code paths
  - Specification drift (implementation diverges from spec silently)
  - Over-reliance on AI review for security decisions
- 34.4 Risk register and monitoring process

---

## 35. Appendices

- A. Glossary of terms
- B. Comparison with prior OS designs
  - seL4, Fuchsia/Zircon, Redox, L4, Mach, Plan 9
- C. Relevant academic literature
  - Capability systems, formal verification, type theory, AI systems
- D. Hardware reference summary
  - aarch64 ABI, UEFI, ACPI, PCIe, NVMe, GPU command submission models
- E. Notation and formal grammar conventions
- F. Change log

---

*This document will be expanded into individual design documents as each phase of the project progresses.*

*黎環 — The outline is the first map of a new world.*
