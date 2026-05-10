# lang/

This directory will contain the Reikan systems language: compiler frontend, intermediate representations, verifier, and ISA backends.

## Language Overview

Reikan uses a new high-level systems language designed from first principles for:
- Formal verifiability (linear types, affine types, algebraic effects, capability types, region types)
- AI-led development (stable AST, unambiguous grammar, LLM-friendly normalization)
- Systems programming (zero-cost abstractions, predictable destruction, unsafe island model)

The language is structured in three layers:
- **L0**: Formal specification language (OS constitution — not compiled to machine code)
- **L1**: Systems implementation language (kernel, drivers, runtime)
- **L2**: Agent and application description language (high-level, declarative) — **reikan-lang**

## reikan-lang (L2 Application Language)

**reikan-lang** is the L2 application/agent language. It is a statically-typed, zero-dependency language with strict canonical syntax and a six-layer file architecture (`.spec`, `.type`, `.logic`, `.res`, `.obs`, `.test`).

See **[spec/reikan-lang/](spec/reikan-lang/)** for the full language proposal:

| Document | Description |
|---|---|
| [spec/reikan-lang/overview.md](spec/reikan-lang/overview.md) | Goals, design principles, file-layer architecture |
| [spec/reikan-lang/grammar-v0.1.md](spec/reikan-lang/grammar-v0.1.md) | Formal PEG grammar specification |
| [spec/reikan-lang/ast-nodes.md](spec/reikan-lang/ast-nodes.md) | AST node definitions |
| [spec/reikan-lang/type-system-v0.1.md](spec/reikan-lang/type-system-v0.1.md) | Type system rules |
| [spec/reikan-lang/formatter-v0.1.md](spec/reikan-lang/formatter-v0.1.md) | Canonical formatter specification |
| [spec/reikan-lang/samples/](spec/reikan-lang/samples/) | Example programs (domain, CLI, HTTP server) |

## Planned Structure

```
lang/
├── spec/                    # Language specification documents
│   └── reikan-lang/         # reikan-lang (L2) proposal documents and samples
├── frontend/                # Parser, AST, name resolution, type inference
├── ir/                      # Intermediate representations (Normalized IR, Verification IR, Low-level IR)
├── verifier/                # Proof obligation checker and invariant verifier
├── backend/                 # ISA backends (aarch64/, x86_64/, gpu/)
├── stdlib/                  # Standard library
└── tests/                   # Language and compiler tests
```

## Status

No language implementation exists yet. Language design begins in Phase 1.

The reikan-lang specification documents in `spec/reikan-lang/` are pre-specification proposals (v0.1 draft).

See [docs/architecture-outline.md](../docs/architecture-outline.md) §6–§7 for the language design outline.
