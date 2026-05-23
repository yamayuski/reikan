# research/

> English version: [README.md](README.md)

このディレクトリには、Reikan プロジェクトに関連する研究ノート、文献要約、および先行技術レビューが含まれています。

## 先行技術サマリー

以下のプロダクトについて調査が行われています。各エントリには要約、Reikan との類似点・相違点、参考にすべき点が記載されています。

### オペレーティングシステム

| プロダクト | 概要 | ファイル |
|---|---|---|
| [Fuchsia OS](fuchsia/) | Google のケイパビリティベース・マイクロカーネル OS（非 POSIX・非 Linux） | [fuchsia.md](fuchsia/fuchsia.md) · [fuchsia.ja.md](fuchsia/fuchsia.ja.md) |
| [seL4](sel4/) | 形式検証済みケイパビリティベース・マイクロカーネル | [sel4.md](sel4/sel4.md) · [sel4.ja.md](sel4/sel4.ja.md) |
| [Redox OS](redox-os/) | Rust ベースのマイクロカーネル OS（非 Linux、部分的 POSIX） | [redox-os.md](redox-os/redox-os.md) · [redox-os.ja.md](redox-os/redox-os.ja.md) |
| [Theseus OS](theseus-os/) | イントラリンガル・セルベースの研究用 OS（Rust、単一アドレス空間） | [theseus-os.md](theseus-os/theseus-os.md) · [theseus-os.ja.md](theseus-os/theseus-os.ja.md) |
| [AIOS](aios/) | LLM エージェント・オペレーティングシステム — エージェント中心 OS 層（研究） | [aios.md](aios/aios.md) · [aios.ja.md](aios/aios.ja.md) |
| [クロスプラットフォームのリソース隔離](cross-platform-isolation/) | Reikan Hosted Runtime を Linux/Windows/macOS で運用する際の Docker 級隔離の実現可能性 | [cross-platform-isolation.md](cross-platform-isolation/cross-platform-isolation.md) · [cross-platform-isolation.ja.md](cross-platform-isolation/cross-platform-isolation.ja.md) |

### プログラミング言語

| プロダクト | 概要 | ファイル |
|---|---|---|
| [Mojo](mojo/) | Modular による AI ファースト・システム言語（Python スーパーセット・MLIR ベース） | [mojo.md](mojo/mojo.md) · [mojo.ja.md](mojo/mojo.ja.md) |

---

## 関連領域（サマリー未作成）

以下の領域は Reikan に関連すると特定されていますが、専用のサマリーはまだ作成されていません。コントリビューションを歓迎します — [CONTRIBUTING.md](../CONTRIBUTING.md) をご覧ください。

- **ケイパビリティベースOS** — L4、EROS、Capsicum
- **OS カーネルの形式検証** — CertiKOS、CompCert
- **システムプログラミングの型システム** — Linear Haskell、Vale、Cyclone
- **代数的エフェクトとエフェクトシステム** — Koka、Eff、Frank
- **AI システムと推論インフラ** — vLLM、TensorRT、Triton、XLA
- **異種計算の抽象化** — SYCL、OneAPI、HSA、Metal
- **分散ケイパビリティシステム** — SPKI/SDSI、CapTP、Agoric
- **形式仕様言語** — TLA+、Alloy、Dafny、Lean 4、Coq、Iris
