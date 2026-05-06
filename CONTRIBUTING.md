# Contributing to Reikan (黎環)

> 日本語版は [CONTRIBUTING.ja.md](CONTRIBUTING.ja.md) をご覧ください。

Thank you for your interest in contributing to **黎環 / Reikan** — an AI-First operating system project.

---

## Project Phase

**Reikan is currently in the architecture-definition phase (Phase 0).**

There is no kernel code, compiler, or runtime to run yet. The primary work at this stage is:

- Establishing and refining the design philosophy and security model.
- Drafting formal specifications and architecture documents.
- Defining the properties of the new systems language.
- Producing Architecture Decision Records (ADRs) and Request for Comments (RFCs).
- Reviewing prior art and research relevant to capability-based OS design, formal verification, and AI-native system interfaces.

---

## Contribution Priorities

At this stage, the following contribution types are most valuable:

### 1. Design Proposals and ADRs

If you have a concrete proposal for how Reikan should handle a particular design question (e.g., how capability delegation should work, what the memory object model should look like, how the scheduler should reason about heterogeneous resources), write it up as an **Architecture Decision Record (ADR)** in `docs/adr/`.

Format:
- **Title**: Short imperative description (e.g., "Use linear types for capability ownership")
- **Status**: Proposed / Accepted / Superseded
- **Context**: What problem does this address?
- **Decision**: What are we deciding to do?
- **Consequences**: What are the trade-offs?

### 2. Specification Drafts

Formal or semi-formal specification drafts belong in `spec/`. These may be mathematical definitions, state machine descriptions, type system rules, or capability calculus fragments. Prefer precision over completeness at this stage.

### 3. Research Summaries

Summaries of relevant prior work (seL4, Fuchsia/Zircon, Redox OS, Dafny, Lean 4, Iris, Linear Haskell, Vale, etc.) are welcomed under `research/`. These help ground design decisions in the broader literature.

### 4. Documentation Improvements

Improvements to `docs/`, clarifications to the architecture outline, or additions to the design document are always welcome.

---

## Development Philosophy

### Safety, Verifiability, and Architectural Clarity Come First

Rapid code generation is explicitly *not* a goal. Reikan is designed to be formally verifiable, capability-isolated, and auditable. A contribution that is thoughtful, well-reasoned, and slower to arrive is preferable to a fast but poorly-considered one.

### AI-Led Development Model

Reikan is designed from the ground up to support an **AI-led development workflow**:

- LLMs (such as GitHub Copilot) are expected to be active contributors to design and implementation.
- Human contributors act primarily as **reviewers, principle-setters, and decision authorities** on safety boundaries.
- All AI-generated contributions should be clearly attributed and pass the same review bar as human-authored contributions.

Humans retain final authority over:
- Root-of-trust decisions
- Cryptographic primitive adoption
- Security policy defaults
- Hardware privilege transitions
- Irreversible or destructive actions

### Documentation-First

Before any implementation, there should be a specification. Before a specification, there should be a design rationale. Contributions that skip these steps will be asked to add them.

### Invariants Over Code

When reviewing contributions, reviewers will focus on:
- Invariants and their preservation
- Capability propagation boundaries
- Resource lifecycle correctness
- Failure semantics
- Dependency boundaries

---

## Getting Started

1. Read [README.md](README.md) for an overview of the project vision and structure.
2. Read [docs/README.md](docs/README.md) for the documentation layout.
3. Read [docs/architecture-outline.md](docs/architecture-outline.md) for the full design document outline.
4. Browse open issues and discussions to find areas where input is needed.
5. Open an issue or discussion before writing a large proposal — early alignment saves time.

---

## Code of Conduct

This project is committed to a respectful and constructive environment. All contributors are expected to engage professionally and in good faith. Criticism should be directed at ideas, not people.

---

*黎環 — Contributions that last are built on clarity of thought.*
