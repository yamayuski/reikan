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
- **L2**: Agent and application description language (high-level, declarative)

## Planned Structure

```
lang/
├── spec/         # Language specification documents
├── frontend/     # Parser, AST, name resolution, type inference
├── ir/           # Intermediate representations (Normalized IR, Verification IR, Low-level IR)
├── verifier/     # Proof obligation checker and invariant verifier
├── backend/      # ISA backends (aarch64/, x86_64/, gpu/)
├── stdlib/       # Standard library
└── tests/        # Language and compiler tests
```

## Status

No language implementation exists yet. Language design begins in Phase 1.

See [docs/architecture-outline.md](../docs/architecture-outline.md) §6–§7 for the language design outline.
