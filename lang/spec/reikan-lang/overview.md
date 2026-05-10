# reikan-lang — Language Overview

**reikan-lang** is the application-layer language of the 黎環 / Reikan project. It is a statically-typed, AI-Friendly, Human-Friendly systems language designed for the full spectrum of application development — from CLI tools and HTTP servers to data-intensive workloads — while remaining zero-dependency and self-contained.

> **Status:** Proposal / Pre-specification (v0.1)
>
> Related documents:
> - [Grammar v0.1](grammar-v0.1.md)
> - [AST Node Specification](ast-nodes.md)
> - [Type System v0.1](type-system-v0.1.md)
> - [Formatter Specification v0.1](formatter-v0.1.md)
> - [Samples](samples/)

---

## 1. Design Goals

### 1.1 Zero-Dependencies Mindset

reikan-lang and its toolchain depend on nothing outside the Reikan project itself. There is no libc, no LLVM, no external package registry required to build or run a reikan-lang program. The standard toolchain — formatter, linter, type-checker, compiler, test runner — ships as a single self-contained binary.

### 1.2 AI-Friendly and Human-Friendly

The language is designed to be unambiguously parsed and understood by both LLMs and human developers:

- **One canonical representation** — every semantically equivalent program has exactly one syntactic form. Style choices that do not affect semantics are forbidden.
- **No operator overloading** (except via well-known trait contracts).
- **No implicit conversions** between types.
- **No ternary operator, no implicit return, no shadowing by default**.
- **Prefix-keyed declarations** — the first keyword of any declaration uniquely determines its kind (e.g. `type`, `func`, `bind`, `watch`, `test`).
- **Structured, machine-readable diagnostics** — errors and warnings are emitted as JSON with spans and fix-its, enabling LLM-assisted correction.

### 1.3 Strict Canonical Syntax

The formatter is part of the standard toolchain and enforces a single canonical layout. Any source file that does not match the canonical format is treated as a **build error**. There is no formatter configuration file; the format is defined by this specification.

This means:
- Code reviews never debate style.
- LLM-generated code passes format checks without manual cleanup.
- Diffs are semantically minimal.

### 1.4 Layer Separation

A reikan-lang application is composed of up to six *file layers*. Each layer has a dedicated file extension and defines what can appear in that file. Mixing concerns across layers is a compile error.

| Extension | Layer | Purpose |
|---|---|---|
| `.spec` | Specification | Public contracts: named interfaces, capability requirements, pre/postconditions |
| `.type` | Type | Named types, type aliases, structs, enums — may reference primitive types |
| `.logic` | Logic | Pure application logic: functions, control flow, expressions |
| `.res` | Resource | Resource bindings, capability profiles, infrastructure declarations |
| `.obs` | Observability | Read-only inspection policies: metrics, probes, trace points |
| `.test` | Test | Test cases, property assertions, benchmark declarations |

The layer separation follows the spirit of the C header/implementation split, but is more rigorous: types are not scattered across implementation files, resource wiring is never embedded in logic, and observability is never a side-effect of logic code.

### 1.5 Primitives Disallowed in Application Logic

In `.logic` files, bare primitive types (`u8`, `u16`, `u32`, `u64`, `i8`, `i16`, `i32`, `i64`, `f32`, `f64`, `bool`, `str`) are **forbidden as declared types**. Every value must carry a named type defined in a `.type` file.

**Correct (in `.logic`):**
```
let age: UserAge := 30;
let port: TcpPort := 8080;
```

**Forbidden (in `.logic`):**
```
let age: u32 := 30;    // error: primitive type in logic layer
let port: u16 := 8080; // error: primitive type in logic layer
```

This ensures that domain semantics are always visible in logic code and that accidental misuse of values with the same underlying representation (e.g. passing an age where a port is expected) is caught at compile time.

Primitives are permitted in `.type` files (where aliases are defined) and in unsafe low-level layers (outside the scope of this document).

### 1.6 Observability as Read-Only Inspection

The `.obs` layer provides an eBPF-like "window" into a running program. Observability declarations attach to named functions or modules and describe what information is *visible* from outside. They do **not** alter the logic of the program. Observed values cannot be written to; probes cannot call functions; the logic layer cannot reference `.obs` declarations.

The runtime gives these probes dedicated read paths (e.g. shared memory rings, event streams) that never block the hot path.

### 1.7 Standard Toolchain as Part of the Runtime

The following tools ship as part of the standard reikan-lang distribution and require no separate installation:

| Tool | Command | Purpose |
|---|---|---|
| Formatter | `reikan fmt` | Canonically format source files; error if already non-canonical |
| Linter | `reikan lint` | Enforce layer rules, naming conventions, unused declarations |
| Type-checker | `reikan check` | Full type checking without emitting code |
| Compiler | `reikan build` | Compile to native executable |
| Test runner | `reikan test` | Run `.test` files, emit structured results |
| REPL | `reikan repl` | Interactive expression evaluation |

---

## 2. File Layer Detail

### 2.1 `.spec` — Specification Layer

A `.spec` file declares **what** a module does, not **how**. It contains:

- `contract` declarations: named sets of function signatures
- `capability` declarations: hardware or platform requirements
- Pre/postcondition annotations (`@requires`, `@ensures`, `@effect`)

`.spec` files are the public API surface of a module. They can be imported by any other layer. They contain no executable logic.

```
spec module user;

import core.result;
import user.types;

contract UserRepository {
    find(id: UserId) -> Result<User, UserError>;
    save(user: User) -> Result<Unit, UserError>;
    delete(id: UserId) -> Result<Unit, UserError>;
}
```

### 2.2 `.type` — Type Layer

A `.type` file declares **named types**. It is the only layer allowed to reference primitive types directly (to define aliases). It contains:

- `type <Name> = <primitive>` — type aliases (desugared to newtype wrappers)
- `type <Name> struct { … }` — named record types
- `type <Name> enum { … }` — named sum types
- Method implementations for named types (value-level operations)

```
type module user.types;

import core.types;

type UserId = u64;
type UserName = str;
type UserAge = u8;
type UserEmail = str;

type User struct {
    id: UserId;
    name: UserName;
    age: UserAge;
    email: UserEmail;
}

type UserError enum {
    NotFound;
    InvalidInput(message: str);
    StorageFailure;
}
```

### 2.3 `.logic` — Logic Layer

A `.logic` file declares **how** the application behaves. It contains:

- `func` declarations
- `let` bindings (named types only — no bare primitives)
- Control flow: `if`, `match`, `loop`, `return`
- Function calls

Typed literal desugaring: integer/string literals in `.logic` files are contextually desugared to the target named type. The compiler inserts the conversion implicitly at the AST level, but the source must always carry the type annotation.

```
logic module user.logic;

import user.types;
import user.spec;
import core.result;

func createUser(
    name: UserName,
    age: UserAge,
    email: UserEmail,
) -> Result<User, UserError> {
    let id: UserId := UserId::generate();
    let user: User := User {
        id: id,
        name: name,
        age: age,
        email: email,
    };
    return Ok(user);
}
```

### 2.4 `.res` — Resource Layer

A `.res` file declares **resource bindings** for the module: databases, caches, queues, file paths, capability profiles. Resource declarations are never imported by logic files directly; instead the runtime injects them as capability-typed handles through the dependency injection boundary.

```
resource module user.resources;

import user.types;

profile UserServiceProfile {
    memory: 128mb;
    cpu: low_latency;
    no_swap: true;
}

bind postgres UserDb {
    pool_size: 10;
    max_connections: 50;
    timeout: 5s;
}

bind redis UserCache {
    ttl: 3600s;
    max_entries: 100000;
}
```

### 2.5 `.obs` — Observability Layer

A `.obs` file declares **read-only inspection policies**. These are attached to functions or modules and expose metrics, event probes, and memory snapshots. The logic layer is never modified by `.obs` declarations; the compiler inserts minimal probe stubs that feed data into the observability runtime ring buffers.

```
observe module user.observability;

import user.types;
import user.logic;

watch UserMetrics {
    latency_p50: wall_time(createUser);
    latency_p99: wall_time(createUser) at percentile(99);
    error_rate: error_count(createUser) / call_count(createUser);
    heap_allocated: heap_bytes(createUser);
}

probe UserCreateProbe on createUser {
    capture: [name, age, result.is_ok()];
    sample_rate: 0.01;
    when: always;
}
```

### 2.6 `.test` — Test Layer

A `.test` file declares **test cases**, **property assertions**, and **benchmarks** for the module. Tests may import from `.type` and `.logic` layers but not from `.res` or `.obs`.

Typed literal desugaring applies in `.test` files in the same way it applies in `.logic` files.

```
test module user.tests;

import user.types;
import user.logic;
import core.result;

test "createUser returns Ok for valid input" {
    let name: UserName := UserName::from("Alice");
    let age: UserAge := UserAge::from(30);
    let email: UserEmail := UserEmail::from("alice@example.com");
    let result: Result<User, UserError> := createUser(name, age, email);
    assert result.is_ok();
    assert result.unwrap().name == name;
}
```

---

## 3. Key Principles Summary

| Principle | Rule |
|---|---|
| One form per meaning | Every construct has exactly one syntactic form. |
| No primitives in logic | Logic files may only use named types from `.type` files. |
| Layer isolation | Each file extension enforces its permitted content at compile time. |
| Canonical formatting | The formatter is normative; non-canonical source is a build error. |
| Observability is read-only | `.obs` declarations never mutate program state or control flow. |
| Resource declarations are separate | Database/cache/network configs live in `.res`, never in `.logic`. |
| Toolchain is the standard library | fmt, lint, check, build, test ship as one binary, zero extra deps. |

---

## 4. Relationship to Reikan OS Layers

reikan-lang targets the **L2 (application/agent) layer** of the Reikan architecture. It depends on the L1 runtime for task scheduling, memory management, and I/O. The capability system declared in `.res` files maps directly to the L1 resource manager's allocation model.

See [docs/architecture-outline.md](../../../docs/architecture-outline.md) §6–§7 for the broader architecture context.
