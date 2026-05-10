# reikan-lang AST Node Specification

This document specifies the canonical Abstract Syntax Tree (AST) node types for reikan-lang. The AST is produced from the lossless Concrete Syntax Tree (CST) by stripping whitespace and comments. Every AST node carries a `span` referencing its byte range in the source file.

> **Status:** Draft v0.1
>
> Related: [Overview](overview.md) · [Grammar v0.1](grammar-v0.1.md) · [Type System v0.1](type-system-v0.1.md)

---

## 1. Conventions

Nodes are described using a pseudo-struct notation:

```
NodeName {
    field: Type          // required field
    field?: Type         // optional field
    field: [Type]        // zero-or-more list
    field: Type | Type   // union of node types
    span: Span           // every node has this
}
```

`Span` is defined as:

```
Span {
    file:   string    // file path relative to module root
    start:  u64       // byte offset, inclusive
    end:    u64       // byte offset, exclusive
}
```

All identifiers in the AST are stored in resolved (interned) form. The CST retains the raw text.

---

## 2. Top-Level Nodes

### 2.1 SourceFile

```
SourceFile {
    span:    Span
    header:  ModuleHeader
    imports: [ImportDecl]
    decls:   [Declaration]
}
```

### 2.2 ModuleHeader

```
ModuleHeader {
    span:   Span
    layer:  LayerKind
    path:   QualifiedPath
}

LayerKind =
    | Spec
    | Type
    | Logic
    | Resource
    | Observe
    | Test
```

### 2.3 ImportDecl

```
ImportDecl {
    span:  Span
    path:  QualifiedPath
    alias?: Ident
}
```

### 2.4 QualifiedPath

```
QualifiedPath {
    span:     Span
    segments: [Ident]    // at least one
}
```

---

## 3. Spec Layer Nodes

### 3.1 ContractDecl

```
ContractDecl {
    span:        Span
    annotations: [Annotation]
    name:        TypeIdent
    members:     [ContractMember]
}
```

### 3.2 ContractMember

```
ContractMember {
    span:        Span
    annotations: [Annotation]
    name:        ValueIdent
    params:      [Param]
    return_ty:   TypeExpr
}
```

### 3.3 CapabilityDecl

```
CapabilityDecl {
    span:   Span
    name:   TypeIdent
    fields: [CapabilityField]
}

CapabilityField {
    span:  Span
    name:  ValueIdent
    value: CapabilityValue
}

CapabilityValue {
    span: Span
    name: Ident
    args: [Ident]
}
```

---

## 4. Type Layer Nodes

### 4.1 TypeAliasDecl

```
TypeAliasDecl {
    span:      Span
    name:      TypeIdent
    primitive: PrimitiveKind
}

PrimitiveKind =
    | U8 | U16 | U32 | U64
    | I8 | I16 | I32 | I64
    | F32 | F64
    | Bool
    | Str
    | Usize | Isize
```

Type aliases desugar to **newtype wrappers** in the type system. Two aliases over the same primitive are distinct types.

### 4.2 TypeStructDecl

```
TypeStructDecl {
    span:   Span
    name:   TypeIdent
    fields: [StructField]
}

StructField {
    span: Span
    name: ValueIdent
    ty:   TypeExpr
}
```

### 4.3 TypeEnumDecl

```
TypeEnumDecl {
    span:     Span
    name:     TypeIdent
    variants: [EnumVariant]
}

EnumVariant {
    span:    Span
    name:    TypeIdent
    payload: EnumPayload?
}

EnumPayload =
    | TuplePayload { fields: [TypeExpr] }
    | StructPayload { fields: [StructField] }
```

### 4.4 ImplDecl

```
ImplDecl {
    span:    Span
    ty:      TypeIdent
    methods: [ImplMethod]
}

ImplMethod {
    span:        Span
    annotations: [Annotation]
    name:        ValueIdent
    self_param:  SelfParam?
    params:      [Param]
    return_ty:   TypeExpr
    body:        Block?       // None = abstract method
}

SelfParam =
    | OwnedSelf    // 'self'
    | BorrowedSelf // '&self'
```

---

## 5. Logic Layer Nodes

### 5.1 FuncDecl

```
FuncDecl {
    span:        Span
    annotations: [Annotation]
    name:        ValueIdent
    params:      [Param]
    return_ty:   TypeExpr
    body:        Block
}

Param {
    span: Span
    name: ValueIdent
    ty:   TypeExpr
}
```

---

## 6. Resource Layer Nodes

### 6.1 ProfileDecl

```
ProfileDecl {
    span:   Span
    name:   TypeIdent
    fields: [ProfileField]
}

ProfileField {
    span:  Span
    name:  ValueIdent
    value: ResourceValue
}

ResourceValue =
    | SizeValue    { bytes: u64 }
    | DurationValue { nanos: u64 }
    | BoolValue    { value: bool }
    | IntValue     { value: i64 }
    | IdentValue   { name: Ident }
```

### 6.2 BindDecl

```
BindDecl {
    span:   Span
    driver: Ident
    name:   TypeIdent
    fields: [BindField]
}

BindField {
    span:  Span
    name:  ValueIdent
    value: ResourceValue
}
```

---

## 7. Observability Layer Nodes

### 7.1 WatchDecl

```
WatchDecl {
    span:    Span
    name:    TypeIdent
    metrics: [WatchMetric]
}

WatchMetric {
    span:     Span
    name:     ValueIdent
    expr:     MetricExpr
    modifier: MetricModifier?
}

MetricExpr =
    | SimpleMetric {
        func:   MetricFunc
        target: QualifiedPath
      }
    | DivMetric {
        numerator:   MetricExpr
        denominator: MetricExpr
      }

MetricFunc =
    | WallTime
    | HeapBytes
    | ErrorCount
    | CallCount
    | CpuTime
    | AllocCount
    | StackDepth

MetricModifier =
    | Percentile { value: u8 }
    | Rate       { window: u64 /* nanos */ }
    | Sum | Max | Min | Avg
```

### 7.2 ProbeDecl

```
ProbeDecl {
    span:        Span
    name:        TypeIdent
    target:      QualifiedPath
    captures:    [CaptureExpr]
    sample_rate: f64
    condition:   ProbeCondition
}

CaptureExpr {
    span:   Span
    path:   [ValueIdent]   // field access chain
    method: ValueIdent?    // optional trailing no-arg method call
}

ProbeCondition =
    | Always
    | OnError
    | OnSlow { threshold_nanos: u64 }
```

---

## 8. Test Layer Nodes

### 8.1 TestCase

```
TestCase {
    span:        Span
    description: string
    body:        Block
}
```

### 8.2 BenchCase

```
BenchCase {
    span:        Span
    description: string
    body:        Block
}
```

---

## 9. Statement Nodes

```
Statement =
    | LetStmt
    | ReturnStmt
    | AssertStmt
    | ExprStmt
    | IfStmt
    | MatchStmt
    | LoopStmt
    | WhileStmt
    | ForStmt
    | BreakStmt
    | ContinueStmt

LetStmt {
    span:    Span
    name:    ValueIdent
    ty:      TypeExpr
    value:   Expr
}

ReturnStmt {
    span:  Span
    value: Expr
}

AssertStmt {
    span:    Span
    cond:    Expr
    message: string?
}

ExprStmt {
    span: Span
    expr: Expr
}

IfStmt {
    span:        Span
    cond:        Expr
    then_block:  Block
    else_if_branches: [ElseIfBranch]
    else_block:  Block?
}

ElseIfBranch {
    span:  Span
    cond:  Expr
    block: Block
}

MatchStmt {
    span:  Span
    expr:  Expr
    arms:  [MatchArm]
}

MatchArm {
    span:    Span
    pattern: Pattern
    body:    MatchBody
}

MatchBody =
    | BlockBody { block: Block }
    | ExprBody  { expr: Expr }

LoopStmt {
    span:  Span
    body:  Block
}

WhileStmt {
    span:  Span
    cond:  Expr
    body:  Block
}

ForStmt {
    span:     Span
    var:      ValueIdent
    iterable: Expr
    body:     Block
}

BreakStmt    { span: Span }
ContinueStmt { span: Span }

Block {
    span:  Span
    stmts: [Statement]
}
```

---

## 10. Expression Nodes

```
Expr =
    | LitExpr
    | NameExpr
    | UnaryExpr
    | BinaryExpr
    | FieldAccessExpr
    | MethodCallExpr
    | AssocAccessExpr
    | AssocCallExpr
    | IndexExpr
    | PropagateExpr
    | StructLitExpr
    | EnumVariantExpr
    | BlockExpr

LitExpr {
    span:  Span
    value: LiteralValue
}

LiteralValue =
    | IntLit    { raw: u64; suffix: IntSuffix? }
    | FloatLit  { raw: f64; suffix: FloatSuffix? }
    | BoolLit   { value: bool }
    | StringLit { value: string }

NameExpr {
    span: Span
    name: ValueIdent
    // resolved to: Binding | Param | FuncDecl | ImplMethod
}

UnaryExpr {
    span: Span
    op:   UnaryOp
    expr: Expr
}

UnaryOp = | Not | Neg

BinaryExpr {
    span:  Span
    op:    BinaryOp
    left:  Expr
    right: Expr
}

BinaryOp =
    | Add | Sub | Mul | Div | Mod
    | Eq | Neq
    | Lt | Le | Gt | Ge
    | And | Or

FieldAccessExpr {
    span:  Span
    expr:  Expr
    field: ValueIdent
}

MethodCallExpr {
    span:   Span
    expr:   Expr
    method: ValueIdent
    args:   [Expr]
}

AssocAccessExpr {
    span: Span
    ty:   TypeIdent
    name: ValueIdent
}

AssocCallExpr {
    span: Span
    ty:   TypeIdent
    name: ValueIdent
    args: [Expr]
}

IndexExpr {
    span:  Span
    expr:  Expr
    index: Expr
}

PropagateExpr {
    span: Span
    expr: Expr
    // desugars to early return on Err/None
}

StructLitExpr {
    span:   Span
    ty:     TypeIdent
    fields: [FieldInit]
}

FieldInit {
    span:  Span
    name:  ValueIdent
    value: Expr
}

EnumVariantExpr {
    span:    Span
    ty:      TypeIdent
    variant: TypeIdent
    payload: EnumVariantPayload?
}

EnumVariantPayload =
    | TuplePayload { args: [Expr] }

BlockExpr {
    span:  Span
    block: Block
}
```

---

## 11. Pattern Nodes

```
Pattern =
    | WildcardPat
    | LiteralPat
    | BindingPat
    | EnumVariantPat
    | StructPat
    | SomePat
    | NonePat

WildcardPat  { span: Span }
LiteralPat   { span: Span; value: LiteralValue }
BindingPat   { span: Span; name: ValueIdent }
NonePat      { span: Span }

EnumVariantPat {
    span:    Span
    ty:      TypeIdent
    variant: TypeIdent
    fields:  [Pattern]
}

StructPat {
    span:   Span
    ty:     TypeIdent
    fields: [FieldPattern]
}

FieldPattern {
    span:    Span
    name:    ValueIdent
    pattern: Pattern?   // None = shorthand (bind to same name)
}

SomePat {
    span:  Span
    inner: Pattern
}
```

---

## 12. Type Expression Nodes

```
TypeExpr =
    | NamedTypeExpr
    | SliceTypeExpr
    | ArrayTypeExpr
    | OptionTypeExpr
    | TupleTypeExpr
    | UnitTypeExpr

NamedTypeExpr {
    span: Span
    name: TypeIdent
    args: [TypeExpr]
}

SliceTypeExpr {
    span: Span
    elem: TypeExpr
}

ArrayTypeExpr {
    span: Span
    elem: TypeExpr
    size: u64
}

OptionTypeExpr {
    span: Span
    inner: TypeExpr
    // sugar for NamedTypeExpr { name: "Option", args: [inner] }
}

TupleTypeExpr {
    span:   Span
    fields: [TypeExpr]
}

UnitTypeExpr { span: Span }
```

---

## 13. Annotation Node

```
Annotation {
    span: Span
    name: Ident
    args: [AnnotationArg]
}

AnnotationArg =
    | NamedStringArg { name: Ident; value: string }
    | NamedIntArg    { name: Ident; value: i64 }
    | FlagArg        { name: Ident }
    | PosStringArg   { value: string }
```

---

## 14. Lossless CST vs. AST

The **CST** (Concrete Syntax Tree) retains all tokens including whitespace, comments, and punctuation. It is the basis for the formatter and language server. The **AST** is derived from the CST by:

1. Dropping whitespace and comment nodes.
2. Normalizing token positions to `Span` byte offsets.
3. Resolving syntactic sugar (`?` suffix, `?TypeExpr`).
4. Interning all string identifiers.

The AST is the input to the type-checker and all later compiler phases. The CST is never modified by compilation; it is only read.
