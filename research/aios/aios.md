# AIOS — LLM Agent Operating System

> 日本語版は [aios.ja.md](aios.ja.md) をご覧ください。

---

## Overview

**AIOS** (LLM Agent Operating System) is a research project and prototype from Rutgers University (Mei, Xu, et al., 2024). It proposes an OS-level abstraction layer specifically designed to host multiple concurrent LLM agents, addressing the challenge that LLM agents have fundamentally different resource requirements from traditional applications: they consume large amounts of VRAM for model weights, require long-running context windows, invoke external tools, and need fine-grained scheduling of both inference compute and I/O.

AIOS is built **on top of** an existing OS (Linux), adding an agent-centric kernel module layer rather than replacing the host OS. Despite this layered approach, its design space — agent scheduling, memory management for agents, tool invocation management, and access control — directly overlaps with Reikan's AI-First OS mandate.

### Key Technical Properties

| Property | Detail |
|---|---|
| Architecture | Agent OS layer on top of Linux |
| Primary language | Python |
| Agent abstraction | LLM agents with goals, context, tool access, and lifecycle |
| Scheduling | Agent scheduler: interleaves multiple LLM agent executions |
| Memory management | Context window management; model weight caching |
| Tool management | Tool registry; tool invocation dispatch; sandboxing |
| Access control | Per-agent tool and resource permissions |
| Storage | Agent state persistence; knowledge retrieval |
| Formal verification | None |
| AI focus | Central — agents and LLM inference are the primary construct |

### Core AIOS Components

| Component | Function |
|---|---|
| **Agent Scheduler** | Interleaves execution of multiple LLM agents; handles waiting states during long LLM calls |
| **Context Manager** | Manages agent context windows; handles context persistence and restoration |
| **Memory Manager** | Manages short-term (working) and long-term (storage) memory for agents |
| **Tool Manager** | Registers and dispatches external tool invocations; manages tool permissions |
| **Access Manager** | Per-agent permission model for tools and storage |
| **LLM System Call** | Defines a stable API between agents and the AIOS kernel |

---

## Similarities with Reikan

| Dimension | AIOS | Reikan |
|---|---|---|
| **Primary design axis** | LLM agents as the primary unit of computation | AI agents as first-class OS citizens |
| **Agent lifecycle** | Agents have goals, context, memory, and tool access managed by the system | Agents with goals, memory, tools, and lifetime as native kernel objects |
| **Agent scheduler** | Dedicated scheduler for LLM agents | Heterogeneous scheduler with AI inference as a first-class workload |
| **Memory abstraction** | Agent-specific memory management (context, KV cache, persistent memory) | Memory object model designed around agent and model workloads |
| **Tool invocation** | Managed tool dispatch with permission control | Capability-mediated tool and resource access |
| **Access control** | Per-agent permission model | Capability-based security — authority is explicit and per-agent |
| **LLM-specific scheduling** | Handles long inference calls, waiting states, context switching | Inference-aware scheduling of heterogeneous resources |
| **Agent API** | LLM System Call API | Agent OS API (context, tool invocation, semantic query, attestation) |

---

## Differences from Reikan

| Dimension | AIOS | Reikan |
|---|---|---|
| **Architecture depth** | Layer on top of Linux — not a new OS | Ground-up OS design; no host OS substrate |
| **Kernel security** | Inherits Linux's security model; no capability-based kernel | Full capability-based kernel with formal security properties |
| **Formal verification** | None | Machine-checked proof of TCB |
| **Heterogeneous compute** | Relies on Linux GPU drivers; no native accelerator scheduling | GPU, NPU, VRAM as first-class scheduled resources in the kernel |
| **Language** | Python — high-level; not a systems language | Reikan-lang — systems-level language for kernel and agents |
| **Observability** | Standard logging; not uniform audit | Every capability grant and model invocation is an auditable event |
| **Capability security** | POSIX permissions inherited from Linux | Unforgeable capability tokens; no ambient authority |
| **Hardware isolation** | Process/container isolation via Linux | Hardware-enforced capability isolation |
| **Scope** | Research prototype | Production-targeted architecture |
| **Boot model** | Runs on existing Linux installation | Bare-metal boot chain |

---

## Points to Reference / Learn From

### 1. Agent OS API Design
AIOS's "LLM System Call" interface is a concrete attempt to define a stable API between LLM agents and the OS layer. The verbs it defines — model inference, context save/restore, tool dispatch, memory query — are a useful first draft for Reikan's Agent OS API design (Section 21 of the architecture outline). Reikan should evaluate which of AIOS's calls translate directly and which need to be redesigned around capability tokens.

### 2. Agent Scheduling Semantics
AIOS's agent scheduler handles a challenge unique to LLM workloads: inference calls are long-running and non-interruptible at the token level. The scheduler interleaves agent execution around these long waiting states (waiting for LLM response, waiting for tool response). This is a direct specification input for Reikan's heterogeneous scheduler: it must handle both microsecond-granularity hardware scheduling and second-granularity agent execution interleaving.

### 3. Context Window as a Managed Resource
AIOS treats the LLM **context window** as a scarce, managed resource — not just a heap allocation. Context windows are saved, restored, and managed across multiple agents. This motivates Reikan's "Context" as a first-class kernel object: the kernel must track context window allocations across VRAM and DRAM, handle context migration, and enforce per-agent context limits.

### 4. Tool Permission Model
AIOS's per-agent tool permission model (which agent can call which tools, and with what limits) is a direct precedent for Reikan's capability-based tool access model. The key Reikan improvement: instead of a flat permission list, tool access should be mediated by unforgeable capability tokens, making it auditable and formally composable.

### 5. Agent Memory Taxonomy
AIOS distinguishes between short-term (in-context), working (temporary external), and long-term (persistent) memory for agents. This taxonomy is a useful starting point for Reikan's memory object model, which must handle VRAM (hot model activations), DRAM (agent working state), and storage (persistent knowledge) as distinct resource classes with different scheduling and migration properties.

---

## References

- Mei, K., Li, Z., Wang, S., et al. (2024). "AIOS: LLM Agent Operating System." arXiv:2403.16971. ([arXiv](https://arxiv.org/abs/2403.16971))
- [AIOS GitHub](https://github.com/agiresearch/AIOS)
- Ge, Y., Ren, Y., Hua, W., et al. (2023). "OpenAGI: When LLM Meets Domain Experts." *NeurIPS 2023*.
