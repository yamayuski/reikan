# reikan-lang Grammar Specification v0.1

This document specifies the formal grammar of reikan-lang using PEG (Parsing Expression Grammar) notation.

> **Status:** Draft v0.1
>
> Related: [Overview](overview.md) · [AST Nodes](ast-nodes.md) · [Type System v0.1](type-system-v0.1.md)

---

## 1. Notation

This grammar uses the following PEG notation:

| Notation | Meaning |
|---|---|
| `'x'` | Literal string `x` |
| `[abc]` | Character class: one of `a`, `b`, `c` |
| `[a-z]` | Character range |
| `e?` | Optional (zero or one) |
| `e*` | Zero or more |
| `e+` | One or more |
| `e1 e2` | Sequence |
| `e1 / e2` | Ordered choice (try `e1`, else `e2`) |
| `!e` | Negative lookahead (not followed by `e`) |
| `&e` | Positive lookahead (followed by `e`) |
| `(e)` | Grouping |
| `/* comment */` | Commentary — not part of the grammar |

Whitespace and comments between tokens are consumed implicitly wherever `_` appears in a rule, or between any two tokens not explicitly adjacent. The grammar is whitespace-insensitive except inside string literals.

---

## 2. Top-Level Structure

Each reikan-lang source file must begin with a **module header** that declares its layer and fully-qualified module path.

```peg
SourceFile
    = ModuleHeader ImportSection Declaration* EOF

ModuleHeader
    = LayerKeyword 'module' QualifiedIdent ';'

LayerKeyword
    = 'spec' / 'type' / 'logic' / 'resource' / 'observe' / 'test'

ImportSection
    = ImportDecl*

ImportDecl
    = 'import' QualifiedIdent ('as' Ident)? ';'
```

The `LayerKeyword` determines which `Declaration` kinds are permitted in the file (see §7 for per-layer rules).

---

## 3. Identifiers and Literals

### 3.1 Identifiers

```peg
Ident
    = [a-zA-Z_] [a-zA-Z0-9_]*

QualifiedIdent
    = Ident ('.' Ident)*

/* Type names must be UpperCamelCase */
TypeIdent
    = [A-Z] [a-zA-Z0-9]*

/* Value names must be lowerCamelCase */
ValueIdent
    = [a-z] [a-zA-Z0-9_]*
```

The formatter enforces casing rules as build errors. Module paths use dotted lowercase identifiers.

### 3.2 Literals

```peg
Literal
    = IntLiteral
    / FloatLiteral
    / BoolLiteral
    / StringLiteral

IntLiteral
    = DecLiteral / HexLiteral / BinLiteral

DecLiteral
    = [0-9] ([0-9] / '_')* IntSuffix?

HexLiteral
    = '0x' [0-9a-fA-F] ([0-9a-fA-F] / '_')* IntSuffix?

BinLiteral
    = '0b' [01] ([01] / '_')* IntSuffix?

IntSuffix
    = 'u8' / 'u16' / 'u32' / 'u64'
    / 'i8' / 'i16' / 'i32' / 'i64'

FloatLiteral
    = [0-9]+ '.' [0-9]+ FloatSuffix?

FloatSuffix
    = 'f32' / 'f64'

BoolLiteral
    = 'true' / 'false'

StringLiteral
    = '"' StringChar* '"'

StringChar
    = !'"' !'\\' .
    / '\\' EscapeSeq

EscapeSeq
    = '"' / '\\' / 'n' / 'r' / 't' / '0'
    / 'u{' [0-9a-fA-F]+ '}'
```

In `.logic` and `.test` files, literals used as initializers are **contextually desugared** to the target named type at the AST level. The type annotation on the binding is mandatory; the compiler uses it to validate the conversion.

---

## 4. Type Expressions

```peg
TypeExpr
    = TypeIdent TypeArgs?           /* Named type, e.g. User, Result<User, UserError> */
    / '[' TypeExpr ']'             /* Slice, e.g. [User] */
    / '[' TypeExpr ';' IntLiteral ']'  /* Fixed-size array */
    / '?' TypeExpr                 /* Option<T> sugar */
    / '(' TypeExpr (',' TypeExpr)* ')'  /* Tuple */
    / '(' ')'                      /* Unit */

TypeArgs
    = '<' TypeExpr (',' TypeExpr)* '>'
```

---

## 5. Declarations

### 5.1 `.spec` Layer Declarations

```peg
SpecDecl
    = ContractDecl
    / CapabilityDecl

ContractDecl
    = Annotation* 'contract' TypeIdent '{' ContractMember* '}'

ContractMember
    = Annotation* ValueIdent '(' ParamList? ')' '->' TypeExpr ';'

CapabilityDecl
    = 'capability' TypeIdent '{' CapabilityField* '}'

CapabilityField
    = ValueIdent ':' CapabilityValue ';'

CapabilityValue
    = Ident ('(' Ident (',' Ident)* ')')? /* named capability attribute */
```

### 5.2 `.type` Layer Declarations

```peg
TypeDecl
    = TypeAliasDecl
    / TypeStructDecl
    / TypeEnumDecl
    / ImplDecl

TypeAliasDecl
    = 'type' TypeIdent '=' PrimitiveType ';'

PrimitiveType
    = 'u8' / 'u16' / 'u32' / 'u64'
    / 'i8' / 'i16' / 'i32' / 'i64'
    / 'f32' / 'f64'
    / 'bool'
    / 'str'
    / 'usize' / 'isize'

TypeStructDecl
    = 'type' TypeIdent 'struct' '{' StructField* '}'

StructField
    = ValueIdent ':' TypeExpr ';'

TypeEnumDecl
    = 'type' TypeIdent 'enum' '{' EnumVariant* '}'

EnumVariant
    = TypeIdent (EnumTuplePayload / EnumStructPayload)? ';'

EnumTuplePayload
    = '(' TypeExpr (',' TypeExpr)* ')'

EnumStructPayload
    = '{' StructField* '}'

ImplDecl
    = 'impl' TypeIdent '{' ImplMethod* '}'

ImplMethod
    = Annotation* 'func' ValueIdent '(' SelfParam? ParamList? ')' '->' TypeExpr Block
    / Annotation* 'func' ValueIdent '(' SelfParam? ParamList? ')' '->' TypeExpr ';'
                                    /* abstract — fulfilled by impl elsewhere */

SelfParam
    = 'self' ','?
    / '&' 'self' ','?
```

### 5.3 `.logic` Layer Declarations

```peg
LogicDecl
    = FuncDecl

FuncDecl
    = Annotation* 'func' ValueIdent '(' ParamList? ')' '->' TypeExpr Block

ParamList
    = Param (',' Param)* ','?

Param
    = ValueIdent ':' TypeExpr
```

### 5.4 `.res` Layer Declarations

```peg
ResourceDecl
    = ProfileDecl
    / BindDecl

ProfileDecl
    = 'profile' TypeIdent '{' ProfileField* '}'

ProfileField
    = ValueIdent ':' ResourceValue ';'

ResourceValue
    = SizeValue / DurationValue / BoolLiteral / IntLiteral / Ident

SizeValue
    = [0-9]+ ('b' / 'kb' / 'mb' / 'gb' / 'tb')

DurationValue
    = [0-9]+ ('ns' / 'us' / 'ms' / 's' / 'm' / 'h')

BindDecl
    = 'bind' Ident TypeIdent '{' BindField* '}'

BindField
    = ValueIdent ':' ResourceValue ';'
```

### 5.5 `.obs` Layer Declarations

```peg
ObsDecl
    = WatchDecl
    / ProbeDecl

WatchDecl
    = 'watch' TypeIdent '{' WatchMetric* '}'

WatchMetric
    = ValueIdent ':' MetricExpr ('at' MetricModifier)? ';'

MetricExpr
    = MetricFunc '(' QualifiedIdent ')'
    / MetricExpr '/' MetricExpr

MetricFunc
    = 'wall_time' / 'heap_bytes' / 'error_count' / 'call_count'
    / 'cpu_time' / 'alloc_count' / 'stack_depth'

MetricModifier
    = 'percentile' '(' IntLiteral ')'
    / 'rate' '(' DurationValue ')'
    / 'sum' / 'max' / 'min' / 'avg'

ProbeDecl
    = 'probe' TypeIdent 'on' QualifiedIdent '{' ProbeField* '}'

ProbeField
    = 'capture' ':' '[' CaptureExpr (',' CaptureExpr)* ']' ';'
    / 'sample_rate' ':' FloatLiteral ';'
    / 'when' ':' ProbeCondition ';'

CaptureExpr
    = ValueIdent ('.' ValueIdent)* ('.' '(' ')')?  /* field access or no-arg method call */

ProbeCondition
    = 'always' / 'on_error' / 'on_slow' '(' DurationValue ')'
```

### 5.6 `.test` Layer Declarations

```peg
TestDecl
    = TestCase
    / BenchCase

TestCase
    = 'test' StringLiteral Block

BenchCase
    = 'bench' StringLiteral Block
```

---

## 6. Statements and Expressions

### 6.1 Blocks and Statements

```peg
Block
    = '{' Statement* '}'

Statement
    = LetStmt
    / ReturnStmt
    / AssertStmt
    / ExprStmt
    / IfStmt
    / MatchStmt
    / LoopStmt
    / BreakStmt
    / ContinueStmt

LetStmt
    = 'let' ValueIdent ':' TypeExpr ':=' Expr ';'

ReturnStmt
    = 'return' Expr ';'

AssertStmt
    = 'assert' Expr ';'
    / 'assert' Expr ',' StringLiteral ';'

ExprStmt
    = Expr ';'

IfStmt
    = 'if' Expr Block ('else' 'if' Expr Block)* ('else' Block)?

MatchStmt
    = 'match' Expr '{' MatchArm+ '}'

MatchArm
    = Pattern '=>' (Block / (Expr ';'))

LoopStmt
    = 'loop' Block
    / 'while' Expr Block
    / 'for' ValueIdent 'in' Expr Block

BreakStmt
    = 'break' ';'

ContinueStmt
    = 'continue' ';'
```

### 6.2 Expressions

Expressions use explicit precedence rules with no ambiguity. There is no operator overloading for precedence; all arithmetic has equal precedence and must be parenthesized when mixed.

```peg
Expr
    = LogicalOrExpr

LogicalOrExpr
    = LogicalAndExpr ('||' LogicalAndExpr)*

LogicalAndExpr
    = EqualityExpr ('&&' EqualityExpr)*

EqualityExpr
    = RelationalExpr (('==' / '!=') RelationalExpr)?

RelationalExpr
    = AdditiveExpr (('<' / '<=' / '>' / '>=') AdditiveExpr)?

AdditiveExpr
    = MultiplicativeExpr (('+' / '-') MultiplicativeExpr)*

MultiplicativeExpr
    = UnaryExpr (('*' / '/' / '%') UnaryExpr)*

UnaryExpr
    = '!' UnaryExpr
    / '-' UnaryExpr
    / PostfixExpr

PostfixExpr
    = PrimaryExpr PostfixOp*

PostfixOp
    = '.' ValueIdent                       /* field access */
    / '.' ValueIdent '(' ArgList? ')'     /* method call */
    / '::' ValueIdent                      /* associated value access */
    / '::' ValueIdent '(' ArgList? ')'    /* associated function call */
    / '[' Expr ']'                         /* index */
    / '?'                                  /* error propagation */

PrimaryExpr
    = Literal
    / ValueIdent
    / TypeIdent '{' FieldInit* '}'        /* struct literal */
    / TypeIdent '::' TypeIdent             /* enum variant (no payload) */
    / TypeIdent '::' TypeIdent '(' ArgList ')' /* enum variant (tuple payload) */
    / '(' Expr ')'                         /* parenthesized */
    / Block                                /* block expression */

FieldInit
    = ValueIdent ':' Expr ','

ArgList
    = Expr (',' Expr)* ','?
```

### 6.3 Patterns

```peg
Pattern
    = '_'                              /* wildcard */
    / Literal                          /* literal pattern */
    / ValueIdent                       /* binding */
    / TypeIdent '::' TypeIdent         /* enum variant (no payload) */
    / TypeIdent '::' TypeIdent '(' Pattern (',' Pattern)* ')'  /* enum variant (tuple) */
    / TypeIdent '{' FieldPattern* '}'  /* struct pattern */
    / '?' Pattern                      /* Some pattern */
    / 'none'                           /* None pattern */

FieldPattern
    = ValueIdent ':' Pattern ','
    / ValueIdent ','                   /* shorthand: field name = binding name */
```

---

## 7. Annotations

```peg
Annotation
    = '@' '[' AnnotationBody ']'

AnnotationBody
    = Ident ('(' AnnotationArg (',' AnnotationArg)* ')')?

AnnotationArg
    = Ident '(' StringLiteral ')'   /* named string */
    / Ident '(' IntLiteral ')'      /* named int */
    / Ident                         /* flag */
    / StringLiteral                 /* positional string */
```

Standard annotations:

| Annotation | Applicable layers | Meaning |
|---|---|---|
| `@[requires(expr)]` | `.spec`, `.logic` | Precondition |
| `@[ensures(expr)]` | `.spec`, `.logic` | Postcondition |
| `@[effect(read name, write name)]` | `.spec`, `.logic` | Declared side-effects |
| `@[pure]` | `.logic` | No side-effects |
| `@[deprecated(message)]` | all | Marks declaration deprecated |
| `@[doc(text)]` | all | Documentation string |
| `@[test_only]` | `.type`, `.logic` | Visible only in test layer |

---

## 8. Comments

reikan-lang has two comment forms:

```peg
LineComment
    = '//' (!'\n' .)* '\n'

BlockComment
    = '/*' (!'*/' .)* '*/'
```

Comments are preserved in the CST (lossless syntax tree) for tooling. They do not appear in the AST used for semantic analysis.

**Formatting rule:** Line comments must be separated from preceding code by exactly one blank line, or appear on the same line as the code they annotate (trailing comment), with exactly two spaces before `//`. Block comments are not permitted inside expressions.

---

## 9. Per-Layer Declaration Restrictions

| Declaration kind | `.spec` | `.type` | `.logic` | `.res` | `.obs` | `.test` |
|---|---|---|---|---|---|---|
| `contract` | ✓ | — | — | — | — | — |
| `capability` | ✓ | — | — | — | — | — |
| `type … =` | — | ✓ | — | — | — | — |
| `type … struct` | — | ✓ | — | — | — | — |
| `type … enum` | — | ✓ | — | — | — | — |
| `impl` | — | ✓ | — | — | — | — |
| `func` | — | — | ✓ | — | — | — |
| `profile` | — | — | — | ✓ | — | — |
| `bind` | — | — | — | ✓ | — | — |
| `watch` | — | — | — | — | ✓ | — |
| `probe` | — | — | — | — | ✓ | — |
| `test` | — | — | — | — | — | ✓ |
| `bench` | — | — | — | — | — | ✓ |
| `import` (`.spec`) | ✓ | — | — | — | — | — |
| `import` (`.type`) | — | ✓ | — | — | — | — |
| `import` (`.logic`) | — | — | ✓ | — | — | — |
| `import` (`.res`) | — | — | — | ✓ | — | — |
| `import` (`.obs`) | — | — | — | — | ✓ | — |
| `import` (`.test`) | — | — | — | — | — | ✓ |

Any violation of these rules is a compile error with code `E1001: declaration-in-wrong-layer`.

---

## 10. Primitive Type Restriction in Logic Layer

In `.logic` and `.test` files, the parser **accepts** primitive type names syntactically but the type-checker immediately rejects them with error `E2001: primitive-in-logic-layer`. The fix-it suggests wrapping in a named type. This two-step approach (parse accepts, checker rejects) produces better error messages.

---

## 11. Reserved Keywords

The following identifiers are reserved and may not be used as `ValueIdent` or `TypeIdent`:

```
and         as          assert      bench       bind
bool        break       capability  contract    continue
else        enum        f32         f64         false
for         func        i8          i16         i32
i64         if          impl        import      in
isize       let         logic       loop        match
none        observe     profile     pure        resource
return      self        some        spec        str
struct      test        true        type        u8
u16         u32         u64         usize       watch
while
```
