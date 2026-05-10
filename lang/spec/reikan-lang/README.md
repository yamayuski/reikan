# reikan-lang

**reikan-lang** is the application-layer language of the 黎環 / Reikan project.

This directory contains the language proposal and pre-specification documents for reikan-lang v0.1.

> **Status:** Proposal / Pre-specification (v0.1) — No compiler exists yet.

---

## Documents

| File | Description |
|---|---|
| [overview.md](overview.md) | Goals, design principles, and file-layer architecture |
| [grammar-v0.1.md](grammar-v0.1.md) | Formal PEG grammar specification |
| [ast-nodes.md](ast-nodes.md) | AST node type definitions for all layers |
| [type-system-v0.1.md](type-system-v0.1.md) | Type system rules, primitives, named types, generics |
| [formatter-v0.1.md](formatter-v0.1.md) | Canonical formatter specification (normative) |

---

## Samples

The [`samples/`](samples/) directory contains example reikan-lang source files demonstrating the six file-layer architecture:

| Directory | Description |
|---|---|
| [`samples/domain/`](samples/domain/) | User domain model: `.spec`, `.type`, `.logic`, `.res`, `.obs`, `.test` |
| [`samples/cli/`](samples/cli/) | CLI tool: `.type`, `.logic`, `.res`, `.test` |
| [`samples/http-server/`](samples/http-server/) | HTTP server: `.type`, `.logic`, `.res`, `.obs`, `.test` |

### File Extensions

| Extension | Layer | Contains |
|---|---|---|
| `.spec` | Specification | `contract` and `capability` declarations |
| `.type` | Type | `type` aliases, structs, enums, `impl` blocks |
| `.logic` | Logic | `func` declarations and application logic |
| `.res` | Resource | `profile` and `bind` declarations |
| `.obs` | Observability | `watch` and `probe` declarations (read-only) |
| `.test` | Test | `test` and `bench` declarations |

---

## Key Design Points

- **Zero-dependencies**: no libc, no LLVM, toolchain is self-contained
- **Canonical syntax**: one representation per program — formatter deviations are build errors
- **No primitives in logic**: all values in `.logic` and `.test` must have named types defined in `.type`
- **Typed literal desugaring**: `let age: UserAge := 30;` desugars to `UserAge::from(30u8)` at the AST level
- **Observability is read-only**: `.obs` declarations never mutate state or control flow
- **Resources are separate**: database/cache/queue configurations live in `.res`, never in `.logic`

---

*See [overview.md](overview.md) for the full design rationale.*
