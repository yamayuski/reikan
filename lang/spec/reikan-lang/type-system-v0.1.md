# reikan-lang Type System v0.1

This document specifies the type system of reikan-lang. The type system is nominal, static, and monomorphic by default. Generic types are supported with limited parametric polymorphism. There are no implicit conversions between types.

> **Status:** Draft v0.1
>
> Related: [Overview](overview.md) · [Grammar v0.1](grammar-v0.1.md) · [AST Nodes](ast-nodes.md)

---

## 1. Design Principles

### 1.1 Nominal Typing

Two named types are equal only if they have the same name, regardless of their underlying representation. This is the core mechanism that prevents domain confusion:

```
type UserAge = u8;
type TcpPort = u16;
```

`UserAge` and `TcpPort` are distinct types even though one is `u8` and the other is `u16`. A function that accepts `UserAge` will not accept a raw `u8` or a `TcpPort`.

### 1.2 No Implicit Conversions

There are no implicit numeric promotions, no implicit coercions, and no implicit interface implementations. Every conversion must be written explicitly using an associated function call:

```
let age: UserAge := UserAge::from(30);
```

### 1.3 Typed Literal Desugaring

Integer and string literals in `.logic` and `.test` files are accepted without explicit type suffix, but the type annotation on the binding is mandatory. The compiler desugars the literal to a `TypedLiteral` node annotated with the declared type, then validates that the literal value fits within the underlying representation:

```
let age: UserAge := 30;
// desugars to: let age: UserAge := UserAge::from_literal(30u8);
```

If the literal cannot be represented in the target type, the compiler emits `E2010: literal-out-of-range`.

### 1.4 Primitives are Restricted by Layer

| Layer | May declare primitive types? | May use named types? |
|---|---|---|
| `.type` | ✓ | ✓ |
| `.spec` | — | ✓ |
| `.logic` | ✗ (error E2001) | ✓ |
| `.res` | — (resource values only) | ✓ |
| `.obs` | — | ✓ |
| `.test` | ✗ (error E2001) | ✓ |

---

## 2. Primitive Types

Primitive types are only directly nameable in `.type` files. They are the atoms of the type system.

| Name | Description | Size |
|---|---|---|
| `u8` | Unsigned 8-bit integer | 1 byte |
| `u16` | Unsigned 16-bit integer | 2 bytes |
| `u32` | Unsigned 32-bit integer | 4 bytes |
| `u64` | Unsigned 64-bit integer | 8 bytes |
| `i8` | Signed 8-bit integer | 1 byte |
| `i16` | Signed 16-bit integer | 2 bytes |
| `i32` | Signed 32-bit integer | 4 bytes |
| `i64` | Signed 64-bit integer | 8 bytes |
| `f32` | IEEE 754 single-precision float | 4 bytes |
| `f64` | IEEE 754 double-precision float | 8 bytes |
| `bool` | Boolean | 1 byte |
| `str` | UTF-8 string slice (pointer + length) | 2 × pointer size |
| `usize` | Platform-sized unsigned integer | pointer size |
| `isize` | Platform-sized signed integer | pointer size |

All primitives have a **value semantics** by default (copy on assignment).

---

## 3. Named Types

### 3.1 Type Aliases (Newtype Wrappers)

```
type UserId = u64;
```

`UserId` is a distinct type from `u64`. It is represented identically at runtime (zero-cost wrapper), but the type system treats them as unrelated.

The underlying primitive is accessible only through explicit conversion:

```
let raw: u64 := user_id.into_inner();
let id: UserId := UserId::from(42u64);
```

Every type alias automatically receives the following associated functions:

| Function | Signature | Description |
|---|---|---|
| `from` | `(primitive) -> Self` | Construct from primitive |
| `into_inner` | `(self) -> primitive` | Extract primitive value |
| `from_literal` | `(primitive_literal) -> Self` | Used internally for literal desugaring |

### 3.2 Struct Types

```
type User struct {
    id:    UserId;
    name:  UserName;
    age:   UserAge;
    email: UserEmail;
}
```

Structs are product types. Fields are accessed with `.field_name`. Struct literals must specify all fields:

```
let user: User := User {
    id:    id,
    name:  name,
    age:   age,
    email: email,
};
```

There are no default field values. Partial initialization is a compile error.

Struct types have **value semantics** by default (deep copy on assignment). Borrowing is explicit using `&`.

### 3.3 Enum Types (Sum Types)

```
type UserError enum {
    NotFound;
    InvalidInput(message: UserMessage);
    StorageFailure;
}
```

Enum variants are in the namespace of their type: `UserError::NotFound`, `UserError::InvalidInput(msg)`.

Enum values must be exhaustively matched in `match` expressions:

```
match error {
    UserError::NotFound => { ... }
    UserError::InvalidInput(msg) => { ... }
    UserError::StorageFailure => { ... }
}
```

---

## 4. Generic Types

reikan-lang supports a limited set of built-in generic types. User-defined generics in v0.1 are restricted to one type parameter and only at the declaration site, not in expressions.

### 4.1 Built-in Generic Types

| Type | Description |
|---|---|
| `Result<T, E>` | Success (`Ok(T)`) or failure (`Err(E)`) |
| `Option<T>` | Present (`Some(T)`) or absent (`None`) |
| `[T]` | Slice of `T` |
| `[T; N]` | Fixed-size array of `T` with size `N` |

`Result` and `Option` are the primary error-handling and nullable types. There are no `null` values, no exceptions, and no panics in safe code.

### 4.2 Result<T, E>

```
type Result<T, E> enum {
    Ok(value: T);
    Err(error: E);
}
```

Key associated functions and methods (defined in `core.result`):

| Name | Signature | Description |
|---|---|---|
| `Ok` | `(T) -> Result<T, E>` | Wrap success value |
| `Err` | `(E) -> Result<T, E>` | Wrap error value |
| `is_ok` | `(&self) -> bool` | True if Ok |
| `is_err` | `(&self) -> bool` | True if Err |
| `unwrap` | `(self) -> T` | Panic if Err |
| `unwrap_or` | `(self, default: T) -> T` | Return default if Err |
| `map` | `(self, f: func(T) -> U) -> Result<U, E>` | Transform Ok value |

### 4.3 Option<T>

```
type Option<T> enum {
    Some(value: T);
    None;
}
```

The `?` suffix on a type expression is sugar for `Option<T>`:

```
type UserId? = Option<UserId>;  // sugar
```

The `?` suffix on an expression is the **error propagation operator** — it returns early with `Err`/`None` if the value is an error or absent:

```
let user: User := find_user(id)?;  // returns early if Err or None
```

---

## 5. Method Resolution

Methods are defined in `impl` blocks in `.type` files. When a method is called (`value.method_name(args)`), the compiler resolves it as follows:

1. Look up `value`'s type `T`.
2. Find an `impl T` block that declares `method_name`.
3. Check parameter types match.
4. Check `self` convention matches (owned vs. borrowed).

There is no trait dispatch in v0.1. Method names must be unique within a type's `impl` block.

Associated functions (called as `TypeName::func_name(args)`) are methods declared without a `self` parameter.

---

## 6. Type Checking Rules

### 6.1 Let Binding

```
let x: T := expr;
```

Rules:
- The declared type `T` must be a named type (in `.logic`/`.test` layers).
- The type of `expr` must be `T` (exactly — no implicit widening).
- If `expr` is a literal, typed literal desugaring applies.

### 6.2 Function Calls

```
func_name(arg1, arg2, ...)
```

Rules:
- Number of arguments must match number of parameters.
- Each argument's type must exactly match the declared parameter type.
- Return type is the declared return type of the function.

### 6.3 Method Calls

```
expr.method_name(arg1, arg2, ...)
```

Rules:
- `expr`'s type must have an `impl` block with `method_name`.
- If the method declares `self`, `expr` must be an owned value (consumed).
- If the method declares `&self`, `expr` may be borrowed.
- Argument types must match exactly.

### 6.4 Struct Literals

```
TypeName { field1: expr1, field2: expr2, ... }
```

Rules:
- All fields must be present.
- Each field's expression type must match the declared field type.
- No extra fields.

### 6.5 Enum Variants

```
TypeName::VariantName
TypeName::VariantName(expr1, expr2, ...)
```

Rules:
- `VariantName` must exist in the enum.
- Tuple payload count and types must match the variant declaration.

### 6.6 Match Expressions

```
match expr { ... }
```

Rules:
- Arms must be exhaustive (cover all variants of the matched type).
- Each arm's pattern type must be compatible with `expr`'s type.
- The `_` wildcard arm, if present, must be the last arm.

### 6.7 if / else

```
if cond { ... } else { ... }
```

Rules:
- `cond` must have type `bool` (not a named type aliased over `bool` — `bool` is the condition type).
- The two branches must have the same type if the `if` is used as an expression.

### 6.8 Arithmetic Operators

Arithmetic operators (`+`, `-`, `*`, `/`, `%`) are **only defined for primitive numeric types** in the built-in set. Named type aliases do not inherit arithmetic operators by default. To support arithmetic on a named type, the `impl` block must define methods (e.g. `add`, `sub`):

```
impl UserAge {
    func add(self, other: UserAge) -> UserAge {
        return UserAge::from(self.into_inner() + other.into_inner());
    }
}
```

This ensures that `age + port` is a compile error (since `+` is not defined for `UserAge` with a `TcpPort` argument).

### 6.9 Comparison Operators

The comparison operators `==` and `!=` are defined for any type that is `Eq` (the type either derives equality by structure, or implements it in an `impl` block). `<`, `<=`, `>`, `>=` require `Ord`.

Primitives are `Eq` and `Ord` by default. Named types that wrap primitives inherit `Eq` by default; `Ord` must be explicitly declared:

```
impl UserId {
    @[derives(Eq, Ord)]
    // compiler generates Eq and Ord from the underlying u64
}
```

---

## 7. Borrowing Model (v0.1 Subset)

In v0.1, the borrowing model is simplified:

- Values are **owned** by default.
- `&T` is a **shared borrow** (read-only).
- There are no mutable borrows or lifetimes in the user-facing syntax in v0.1 (they exist in the underlying representation).
- Functions that take `&self` do not consume the receiver.
- Functions that take `self` consume the receiver.

Ownership transfer is explicit:

```
let a: User := make_user();
let b: User := a;    // a is consumed, b now owns the value
// a is no longer accessible
```

---

## 8. Observability Layer Type Rules

The `.obs` layer may only reference:
- Named types from imported `.type` files.
- Function names from imported `.logic` files.

It may **not** introduce new types or call functions. Metric expressions (`wall_time(func)`, `heap_bytes(func)`) are not function calls; they are compile-time intrinsics that produce read-only probes. The type of a `watch` metric is `u64` (time in nanoseconds, byte counts) or `f64` (rates, percentages) at the observability runtime level. These types do not appear in the `.obs` source.

---

## 9. Error Codes Reference

| Code | Name | Description |
|---|---|---|
| `E1001` | `declaration-in-wrong-layer` | Declaration kind not allowed in this layer |
| `E1002` | `import-from-disallowed-layer` | Importing a module layer not permitted by this layer |
| `E2001` | `primitive-in-logic-layer` | Primitive type used in `.logic` or `.test` file |
| `E2002` | `type-mismatch` | Expression type does not match expected type |
| `E2003` | `missing-field` | Struct literal missing one or more fields |
| `E2004` | `extra-field` | Struct literal has unknown field |
| `E2005` | `non-exhaustive-match` | Match does not cover all variants |
| `E2006` | `undefined-name` | Identifier not in scope |
| `E2007` | `undefined-method` | Method not found on type |
| `E2008` | `arity-mismatch` | Wrong number of arguments |
| `E2009` | `missing-return` | Function body does not return in all paths |
| `E2010` | `literal-out-of-range` | Literal value does not fit in target type |
| `E2011` | `operator-not-defined` | Operator not defined for type |
| `E2012` | `move-after-use` | Owned value used after being consumed |
