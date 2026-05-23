# Supply Chain Package Management — Design

> **Status:** Draft — Phase 0 (Architecture Definition)
>
> Japanese version: [supply-chain-package-management.ja.md](supply-chain-package-management.ja.md)
>
> This document defines the built-in defensive dependency management workflow for `reikan add`, including source integrity pinning, side-effect declaration/approval, and transitive policy enforcement.

---

## 1. Scope and Goals

This design introduces a built-in supply chain management model where users can add external libraries with:

```bash
reikan add https://github.com/<owner>/<repo>.git
```

The system must:

1. Reject suspicious libraries automatically when code contains `eval` or intentionally mangled/obfuscated code.
2. Treat all library side effects as forbidden by default.
3. Require explicit side-effect declaration in library metadata JSON.
4. Ask the user for consent during `reikan add` when side effects are requested.
5. Enforce transitive requirements across all dependencies (the full dependency chain must be approved).
6. Pin source identity with immutable commit IDs in metadata.
7. Avoid a user-facing `dependencies` vs `devDependencies` split by relying on build-time AST tree-shaking.

---

## 2. Trust and Source Identity Model

Each published library must provide metadata containing:

- Canonical source repository URL.
- Immutable source commit ID (or equivalent content-addressed identifier).
- Declared side-effect requirements.

The commit ID is part of the trust root for reproducibility and policy evaluation. If source and metadata identity cannot be matched, dependency addition is rejected.

---

## 3. Metadata Contract (Draft)

```json
{
  "name": "sample-lib",
  "version": "0.1.0",
  "source": {
    "repo": "https://github.com/yamayuski/sample-lib.git",
    "commit": "3f2e7b8c..."
  },
  "sideEffects": [
    {
      "kind": "network",
      "reason": "Fetches remote model metadata at runtime"
    }
  ],
  "dependencies": [
    {
      "repo": "https://github.com/example/child-lib.git",
      "commit": "7af9e1d2..."
    }
  ]
}
```

Notes:

- `sideEffects` is mandatory. Empty array means no side effects.
- Undeclared side effects are policy violations.
- Dependency entries are pinned to immutable commits.

---

## 4. `reikan add` Security Flow

1. Resolve package source and metadata.
2. Verify metadata/source identity pin (`repo` + `commit`).
3. Run static guardrail scan on the package source:
   - Reject on `eval`.
   - Reject on strong obfuscation/mangled code patterns.
4. Recursively resolve transitive dependencies and repeat checks.
5. Aggregate all side-effect requests from the full dependency graph.
6. Prompt user with explicit approval question:
   - "This library (and its dependencies) requests the following side effects. Allow?"
7. Add dependency only if all requested side effects are approved.
8. Persist lock + approval policy for reproducible builds.

If any package in the chain fails scan/identity/policy checks, the whole add operation fails atomically.

---

## 5. Side-Effect Policy Semantics

- Default policy: deny-all side effects.
- Side effects are granted by explicit user approval.
- Approval is evaluated over the complete dependency closure, not only direct dependencies.
- Runtime behavior must not exceed approved declarations.

---

## 6. Dependency Classification Policy

Unlike ecosystems such as npm, Reikan does not require users to classify dependencies as runtime (`dependencies`) or debug-time (`devDependencies`).

Reikan builds perform AST-based tree-shaking and drop unused dependencies from build artifacts. Therefore, dependency declaration is single-track, and artifact inclusion is decided by actual semantic usage at build time.

---

## 7. Security Properties (Target)

- **No silent side effects:** all side effects are declared and consented.
- **No unpinned source drift:** commit-level identity pinning is mandatory.
- **No suspicious code import:** `eval`/obfuscation blocks are enforced at add time.
- **No partial-chain trust bypass:** transitive requirements are always evaluated.

---

## 8. Open Design Questions

1. Obfuscation detector threshold and false-positive handling policy.
2. Side-effect taxonomy standardization (network/file/process/FFI/etc.).
3. Approval scope granularity (per-project, per-dependency, per-version, per-commit).
4. Policy update workflow when transitive dependency side effects change between versions.
