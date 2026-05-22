# kernel/

Reikan カーネルのソースコード。

> **Language:** English version is [README.md](README.md).

---

## 現在の状態

**Phase 2 ブートストラップ — Rust プレースホルダー。**

`src/arch/x86_64/` 配下に、Rust で書かれた最小限の x86_64 カーネルブートスタブが
あります。これは、言語ツールチェーンが成熟した段階（Phase 1）で Reikan-lang に
置き換えられる暫定実装です。スコープは意図的に最小限に抑えています：
Multiboot2 ブート + UTF-8 テキスト出力 + クリーンなハルト。

---

## ディレクトリ構成

```
kernel/
├── src/
│   ├── arch/
│   │   ├── mod.rs          # arch サブモジュール宣言
│   │   └── x86_64/
│   │       ├── boot.S      # Multiboot2 ヘッダ + 32→64 ビットモード切替
│   │       ├── vga.rs      # VGA テキストモード（80×25）コンソール
│   │       ├── serial.rs   # UART 16550 シリアルポート（COM1）— 完全 UTF-8
│   │       └── mod.rs      # arch/x86_64 モジュールルート（boot.S をインクルード）
│   └── main.rs             # kernel_main — boot.S からのエントリポイント
├── .cargo/
│   └── config.toml         # x86_64-unknown-none ターゲット、リンカフラグ
├── Cargo.toml              # Rust パッケージ（no_std、panic = abort）
└── linker.ld               # リンカスクリプト（1 MiB にロード）
```

---

## ビルド方法

### 前提条件

```
rustup target add x86_64-unknown-none
```

### コンパイル

```bash
cd kernel
cargo build           # デバッグビルド
cargo build --release # リリースビルド（サイズ最適化）
```

カーネルの ELF バイナリは
`target/x86_64-unknown-none/{debug,release}/reikan-kernel` に出力されます。

### ブータブル ISO の作成（GRUB ツールが必要）

```bash
# Ubuntu / Debian:
sudo apt-get install grub-pc-bin grub-common xorriso mtools

bash ../scripts/build-iso.sh           # デバッグ ISO
bash ../scripts/build-iso.sh --release # リリース ISO
```

ISO は `../build/reikan-x86_64.iso` に書き出されます。

---

## VirtualBox（Windows 11）での実行

1. 新しい VM を作成：**タイプ** は Other、**バージョン** は Other/Unknown (64-bit)。
2. **設定 → ストレージ → IDE コントローラ → 光学ドライブ** →
   `build/reikan-x86_64.iso` をアタッチ。
3. *（任意）* **設定 → シリアルポート → ポート 1**：有効にし、
   生ファイルまたは名前付きパイプに接続して UTF-8 シリアル出力を記録（115200 8N1）。
4. VM を起動。画面に `Reikan kernel — x86_64 boot OK` が表示されます。

---

## ブートシーケンス

```
GRUB2 が ELF をロード → 1 MiB の Multiboot2 ヘッダを発見
  └─ _start（32 ビット保護モード）
       ├─ Multiboot2 マジック（0x36D76289）を検証
       ├─ 2 MiB ヒュージページで最初の 1 GiB をアイデンティティマップ
       ├─ PAE + EFER.LME + ページング有効化 → 64 ビットロングモード
       ├─ 64 ビット GDT をロード、ファージャンプ
       └─ kernel_main(mb2_magic: u32, mb2_info_ptr: u64)
            ├─ UART COM1 初期化（115200 8N1）
            ├─ シリアルポートに UTF-8 ブートメッセージを出力
            ├─ VGA コンソールに ASCII メッセージを出力
            └─ ハルト（cli + hlt ループ）
```

---

## 今後の計画（将来の Phase）

```
kernel/
├── src/
│   ├── boot/         # アーキテクチャ固有のブートおよび初期化コード
│   ├── capability/   # ケイパビリティテーブルと管理
│   ├── mm/           # 物理・仮想メモリ管理
│   ├── sched/        # スケジューラの核
│   ├── ipc/          # IPC プリミティブ
│   ├── trap/         # 例外・割り込みハンドリング
│   └── arch/         # ISA 固有コード（aarch64/、x86_64/）
├── tests/            # カーネルのユニットテストと統合テスト
└── proofs/           # 形式検証の成果物
```

詳細なカーネルアーキテクチャ設計については
[docs/architecture-outline.ja.md](../docs/architecture-outline.ja.md) §9 を
参照してください。
