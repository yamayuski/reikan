# reikan-lang Formatter Specification v0.1

The reikan-lang formatter (`reikan fmt`) is part of the standard toolchain. It enforces a single canonical format for all reikan-lang source files. **Any source file that is not in canonical format is rejected as a build error** (error code `F0001: non-canonical-format`). There is no configuration file; this specification is the configuration.

> **Status:** Draft v0.1
>
> Related: [Overview](overview.md) · [Grammar v0.1](grammar-v0.1.md)

---

## 1. Formatter Role and Scope

The formatter operates on the **CST** (Concrete Syntax Tree), which retains all tokens including whitespace and comments. It rewrites the whitespace and punctuation tokens to match the rules in this document, leaving semantic tokens unchanged.

Running `reikan fmt` in check mode (`reikan fmt --check`) exits with code `1` and a machine-readable diff if any file is not canonical. The build system (`reikan build`) implicitly runs `reikan fmt --check` before compilation.

---

## 2. Encoding and Line Endings

- Source files must be **UTF-8** encoded.
- Line endings must be **LF** (`\n`). CR (`\r`) and CRLF (`\r\n`) are rejected.
- Files must end with exactly **one newline** character.
- No trailing whitespace on any line.

---

## 3. Indentation

- Indentation unit: **4 spaces**.
- Tabs are forbidden everywhere.
- Each nesting level adds exactly one indentation unit.

Nesting levels are introduced by:
- `{` ... `}` blocks (logic, test, struct/enum bodies, impl bodies, contract bodies)
- Multi-line parameter lists and argument lists

---

## 4. Module Header

The module header occupies the first non-blank, non-comment line of the file:

```
<layer-keyword> module <qualified-path>;
```

- Exactly one space between `<layer-keyword>` and `module`.
- Exactly one space between `module` and `<qualified-path>`.
- Immediately followed by a semicolon.
- Followed by exactly **one blank line** before the first `import` (if any) or the first declaration (if no imports).

---

## 5. Import Section

- All `import` declarations appear immediately after the module header.
- Imports are sorted **lexicographically** by qualified path.
- No blank lines between imports.
- Exactly **one blank line** after the last import, before the first declaration.
- If there are no imports, no blank line is inserted after the module header before declarations.

```
import core.result;
import core.types;
import user.types;
```

Import aliases use exactly one space before and after `as`:

```
import some.long.module.path as short;
```

---

## 6. Declarations

Declarations are separated by **exactly one blank line**. No two consecutive blank lines are permitted anywhere in a file.

### 6.1 Type Alias

```
type UserAge = u8;
```

Always on a single line. No spaces inside the alias expression beyond the required single spaces.

### 6.2 Struct Declaration

```
type User struct {
    id:    UserId;
    name:  UserName;
    age:   UserAge;
    email: UserEmail;
}
```

- Opening `{` on the same line as `struct`, preceded by one space.
- Each field on its own line, indented by one level.
- Field names are left-aligned; the `:` is positioned immediately after the field name.
- One space after `:`, then the type.
- Field declarations end with `;`.
- **Column alignment** of `:` within a struct is **not** performed — colons follow immediately after field names without extra padding. (Exception: the formatter may align colons within a struct if doing so requires no more than 4 trailing spaces on any name. If alignment would require more padding, no alignment is applied.)
- Closing `}` on its own line, at the same indentation level as `type`.

### 6.3 Enum Declaration

```
type UserError enum {
    NotFound;
    InvalidInput(message: UserMessage);
    StorageFailure;
}
```

- Same brace rules as struct.
- Each variant on its own line, indented by one level.
- Variants with payload: payload immediately follows the variant name, no space before `(`.
- Variants end with `;`.

### 6.4 Impl Block

```
impl User {
    func from(id: UserId, name: UserName, age: UserAge, email: UserEmail) -> User {
        return User {
            id: id,
            name: name,
            age: age,
            email: email,
        };
    }
}
```

- Opening `{` on the same line as `impl TypeName`.
- Methods separated by exactly one blank line.
- Each method follows the function formatting rules below.

### 6.5 Contract Declaration

```
contract UserRepository {
    find(id: UserId) -> Result<User, UserError>;
    save(user: User) -> Result<Unit, UserError>;
    delete(id: UserId) -> Result<Unit, UserError>;
}
```

- Same brace rules as struct.
- Each member on its own line, indented by one level.
- Members end with `;`.

### 6.6 Function Declaration

Short function (fits on a single signature line, ≤ 100 characters):

```
func greet(name: UserName) -> Greeting {
    ...
}
```

Long function (signature exceeds 100 characters, or has more than 3 parameters):

```
func createUser(
    name:  UserName,
    age:   UserAge,
    email: UserEmail,
) -> Result<User, UserError> {
    ...
}
```

Rules for long-form:
- `func name(` on one line.
- Each parameter on its own line, indented by one level.
- Parameters end with `,` (including the last one — trailing comma is mandatory in multi-line lists).
- `)` and `->` and return type on one line, at the indentation level of `func`.
- `{` at the end of that line.

---

## 7. Statements

### 7.1 Let Binding

```
let name: TypeName := value;
```

- One space before and after `:=`.
- One space before and after `:`.
- Semicolon immediately after the value expression.

### 7.2 Return Statement

```
return value;
```

- `return` followed by one space, then the expression, then `;`.

### 7.3 Assert Statement

```
assert condition;
assert condition, "message";
```

- `assert` followed by one space, then the condition.
- Optional message: `,` followed by one space, then the string literal.

### 7.4 If Statement

```
if condition {
    ...
}
```

```
if condition {
    ...
} else {
    ...
}
```

```
if condition {
    ...
} else if other_condition {
    ...
} else {
    ...
}
```

- `if` followed by one space, then condition, then one space, then `{`.
- `} else` and `} else if` on the same line as the closing `}` of the previous branch.
- No parentheses around conditions.

### 7.5 Match Statement

```
match value {
    TypeName::VariantA => {
        ...
    }
    TypeName::VariantB(inner) => {
        ...
    }
    _ => {
        ...
    }
}
```

- Each arm on a new line at the indentation level of the arm list (one level inside `match`).
- `=>` surrounded by one space on each side.
- Single-statement arms that fit on one line may use the inline form:

```
match value {
    TypeName::VariantA => { return a; }
    TypeName::VariantB => { return b; }
}
```

### 7.6 Loop, While, For

```
loop {
    ...
}

while condition {
    ...
}

for item in collection {
    ...
}
```

---

## 8. Expressions

### 8.1 Binary Expressions

- One space before and after every binary operator.
- Mixed arithmetic operators must be parenthesized:

```
let result: Count := (a + b) * c;   // ok
let result: Count := a + b * c;     // error: mixed precedence without parens
```

### 8.2 Field Access and Method Calls

- No space between the receiver and `.`.
- No space between the method name and `(`.
- No space between argument list items except after `,`:

```
user.name
user.to_display()
createUser(name, age, email)
```

### 8.3 Struct Literals

Short (fits on one line, ≤ 100 characters):

```
let point: Point := Point { x: x_val, y: y_val };
```

Long (more than 2 fields, or line exceeds 100 characters):

```
let user: User := User {
    id: id,
    name: name,
    age: age,
    email: email,
};
```

- Each field on its own line, indented by one level.
- Fields end with `,` (trailing comma mandatory).
- Closing `}` at the indentation level of the expression.

### 8.4 Error Propagation

The `?` suffix appears immediately after the expression, no space:

```
let user: User := find_user(id)?;
```

---

## 9. Observability Declarations

### 9.1 Watch Block

```
watch UserMetrics {
    latency_p50: wall_time(createUser);
    latency_p99: wall_time(createUser) at percentile(99);
    error_rate:  error_count(createUser) / call_count(createUser);
}
```

### 9.2 Probe Block

```
probe UserCreateProbe on createUser {
    capture: [name, age, result.is_ok()];
    sample_rate: 0.01;
    when: always;
}
```

---

## 10. Resource Declarations

### 10.1 Profile Block

```
profile UserServiceProfile {
    memory: 128mb;
    cpu:    low_latency;
    no_swap: true;
}
```

### 10.2 Bind Block

```
bind postgres UserDb {
    pool_size:       10;
    max_connections: 50;
    timeout:         5s;
}
```

---

## 11. Test Declarations

```
test "description of the test case" {
    ...
}
```

- Test description is a string literal.
- One space between `test` and the string literal.
- Body block on the same line as the closing `"`.

---

## 12. Comments

### 12.1 Line Comments

```
// This is a line comment.
func foo() -> Unit {
    let x: Count := 0;  // trailing comment: two spaces before //
    return x;
}
```

- Standalone comment lines: the `//` is at the current indentation level, preceded by a blank line if between code blocks.
- Trailing comments: exactly two spaces before `//`, then one space after `//`.
- No trailing comments inside struct field lists or parameter lists.

### 12.2 Block Comments

Block comments (`/* ... */`) are permitted only at the top of a file (before the module header) and between top-level declarations. They are **not** permitted inside function bodies, expressions, or parameter lists.

---

## 13. Annotations

```
@[pure]
@[requires("id.into_inner() > 0")]
@[deprecated("use findById instead")]
func findUser(id: UserId) -> Result<User, UserError> {
    ...
}
```

- Each annotation on its own line, immediately before the annotated declaration.
- Multiple annotations are listed one per line in alphabetical order of annotation name.
- No blank lines between annotations and the declaration.

---

## 14. Line Length

- Soft limit: **80 characters** (the formatter will warn but not error).
- Hard limit: **120 characters** (the formatter will error with `F0002: line-too-long`).

The formatter automatically wraps:
- Function parameter lists (see §6.6)
- Struct literals (see §8.3)
- Argument lists exceeding the hard limit

---

## 15. File Structure Order

Within a file, declarations must appear in the following order:

1. Module header
2. Imports (sorted lexicographically)
3. *(one blank line)*
4. `capability` declarations (spec layer)
5. `contract` declarations (spec layer)
6. `type … =` declarations (type layer, sorted by name)
7. `type … struct` and `type … enum` declarations (type layer)
8. `impl` blocks (type layer, in the same order as the type they implement)
9. `func` declarations (logic layer, sorted by name)
10. `profile` declarations (resource layer)
11. `bind` declarations (resource layer, sorted by name)
12. `watch` declarations (observability layer)
13. `probe` declarations (observability layer)
14. `test` declarations (test layer)
15. `bench` declarations (test layer)

Within each category, declarations are sorted **alphabetically by name**. Deviations are error `F0003: declaration-out-of-order`.

---

## 16. Formatter Exit Codes

| Code | Meaning |
|---|---|
| `0` | All files are canonical (or were successfully reformatted in write mode) |
| `1` | One or more files are not canonical (check mode) |
| `2` | Formatter internal error |

In write mode (`reikan fmt`), the formatter rewrites files in place and exits `0`. In check mode (`reikan fmt --check`), it exits `1` and prints a machine-readable JSON diff for each non-canonical file.
