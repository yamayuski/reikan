# reikan-lang Samples

This directory contains example reikan-lang source files demonstrating the six-layer file architecture. Each example is self-contained and shows how the different layers interact.

> **Note:** These are documentation samples only. No compiler exists yet.
> See [../overview.md](../overview.md) for the full language design.

---

## domain/ — User Domain Model

A complete small domain module showing all six file layers:

| File | Layer | Contents |
|---|---|---|
| [domain/user.spec](domain/user.spec) | Specification | `UserRepository` and `UserService` contracts with pre/postconditions |
| [domain/user.type](domain/user.type) | Type | `UserId`, `UserName`, `UserAge`, `User`, `UserError` types |
| [domain/user.logic](domain/user.logic) | Logic | `createUser`, `findUser`, `updateUser`, `deleteUser` functions |
| [domain/user.res](domain/user.res) | Resource | Postgres and Redis bindings, capability profile |
| [domain/user.obs](domain/user.obs) | Observability | Latency metrics, error rate, request probes (read-only) |
| [domain/user.test](domain/user.test) | Test | Unit tests and benchmarks for all logic functions |

---

## cli/ — CLI Tool

A command-line tool demonstrating argument parsing and dispatch:

| File | Layer | Contents |
|---|---|---|
| [cli/cli.type](cli/cli.type) | Type | `Command`, `CliResult`, `ExitCode` types |
| [cli/cli.logic](cli/cli.logic) | Logic | `parseArgs`, `dispatch`, `main` functions |
| [cli/cli.res](cli/cli.res) | Resource | Minimal single-threaded capability profile |
| [cli/cli.test](cli/cli.test) | Test | Tests for all command variants and dispatch paths |

---

## http-server/ — HTTP Server

An HTTP server demonstrating routing, request handling, and observability:

| File | Layer | Contents |
|---|---|---|
| [http-server/server.type](http-server/server.type) | Type | `HttpRequest`, `HttpResponse`, `ServerConfig`, `RouteError` types |
| [http-server/server.logic](http-server/server.logic) | Logic | Router, route handlers, connection lifecycle functions |
| [http-server/server.res](http-server/server.res) | Resource | HTTP server capability profile, configuration binding |
| [http-server/server.obs](http-server/server.obs) | Observability | Request latency, throughput, error rate, route-level metrics, request probes |
| [http-server/server.test](http-server/server.test) | Test | Tests for each route handler and the router dispatch |

---

## Key Patterns Illustrated

### Named Types Only in Logic

All `let` bindings in `.logic` and `.test` files use named types:

```
// ✓ correct
let age: UserAge := UserAge::from(30);
let port: TcpPort := TcpPort::from(8080);

// ✗ compile error: primitive in logic layer
let age: u8 := 30;
let port: u16 := 8080;
```

### Typed Literal Desugaring

Integer/string literals in `.logic` and `.test` are contextually desugared:

```
let name: UserName := UserName::from("Alice");
let age: UserAge := UserAge::from(30);  // desugars to UserAge::from_literal(30u8)
```

### Resource Injection (not import)

`.logic` files never `import` `.res` files. Resource handles are injected by the runtime:

```
// In user.logic — resource resolved via context, not import
let repo: UserRepository := core.context.resolve(UserRepository);
```

### Observability Does Not Modify Logic

`.obs` files reference functions by name for probe attachment points. The compiler inserts probe stubs without altering the logic's control flow or return values:

```
// In user.obs — no side-effects on createUser
probe UserCreateProbe on createUser {
    capture: [name, age, result.is_ok()];
    sample_rate: 0.01;
    when:        always;
}
```
