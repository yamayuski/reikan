# Reikan Documentation

This directory contains the design documents, architecture specifications, and reference materials for the **黎環 / Reikan** AI-First OS project.

---

## Documentation Structure

| Path | Contents |
|---|---|
| `docs/README.md` / `docs/README.ja.md` | This file — documentation index and organization guide |
| `docs/architecture-outline.md` / `.ja.md` | Full detailed design document outline (table of contents level) |
| `docs/adr/` | Architecture Decision Records (ADRs) |
| `docs/rfc/` | Requests for Comments on specific design questions |
| `docs/design/` | In-depth design documents for individual subsystems |

---

## How to Read This Documentation

If you are new to the project, start here:

1. **[README.md](../README.md)** — Project overview, vision, design principles, and roadmap. Japanese version: [README.ja.md](../README.ja.md)
2. **[architecture-outline.md](architecture-outline.md)** — The full design document outline. This is the canonical index of all design areas Reikan must address. Think of it as the table of contents for the entire architecture specification. Japanese version: [architecture-outline.ja.md](architecture-outline.ja.md)
3. **[CONTRIBUTING.md](../CONTRIBUTING.md)** — How to contribute: ADRs, RFCs, specs, and research. Japanese version: [CONTRIBUTING.ja.md](../CONTRIBUTING.ja.md)

---

## Language Policy

Documentation follows an **English First / Japanese Second** policy:

- English files (`*.md`) are the primary source.
- Japanese files (`*.ja.md`) provide equivalent content for the primary Japanese-speaking development team.
- Both versions should be updated together when content changes.

---

## Documentation Conventions

- **ADRs** capture a specific decision with its context and trade-offs. They are immutable once accepted (superseded ADRs link to their replacement).
- **RFCs** are open proposals soliciting feedback. They may be revised before acceptance.
- **Design documents** are living documents that evolve with the architecture.

---

## Current Status

The documentation is in early bootstrapping phase. The architecture outline represents the intended scope of the full specification. Individual design documents will be added as each phase of the project progresses.

---

*黎環 — Documentation is the architecture made legible.*
