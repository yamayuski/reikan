# クロスプラットフォームのリソース隔離（Linux / Windows / macOS）

> English version: [cross-platform-isolation.md](cross-platform-isolation.md)

---

## 概要

このノートは、Reikan を VirtualBox のような VM 前提ワークフローではなく、既存 OS（Windows/macOS/Linux）上で厳格に隔離された軽量ランタイムとして動作させられるかを調査するものです。

中心となる問いは次です。

> 特定カーネルのネイティブコンテナ機能に依存せず、3 OS すべてで Docker 級のリソース隔離を実現できるか？

結論を先に述べると、**部分的には可能だが、一様ではない** です。Linux はネイティブに高い隔離機能を提供します。Windows も強力な機能を持ちますが意味論が異なります。macOS は強力なサンドボックスを持つ一方で、Linux の namespace/cgroup と同等の機能は持ちません。

---

## 隔離プリミティブ比較

| 観点 | Linux | Windows | macOS |
|---|---|---|---|
| プロセス/名前空間隔離 | namespace（`pid`/`net`/`mnt`/`ipc`/`uts`/`user`/`time`） | Server silo + object namespace | App Sandbox / seatbelt（ポリシーサンドボックス。Linux 的 namespace ではない） |
| リソース上限 | cgroups v2（CPU/メモリ/IO/pids） | Job Object（CPU/メモリ/プロセス数制限） | rlimit + QoS（cgroups 階層ほど強力ではない） |
| Syscall/API 攻撃面縮小 | seccomp-BPF、capabilities、LSM（SELinux/AppArmor） | トークン制御、整合性レベル、AppContainer capability | サンドボックスポリシー + コード署名/TCC |
| ファイルシステム隔離 | mount namespace、overlayfs、id-mapped mount | Windows Container のレイヤード FS | entitlement によるパス制約、アプリコンテナ領域 |
| ネットワーク隔離 | net namespace、veth/bridge/iptables | HNS/HCS ネットワーク | Linux 的なプロセス単位 net namespace はなし |
| Docker モデルとの実運用上の近さ | 高 | 中〜高（Windows ネイティブ向けで強い） | 低〜中（サンドボックスは強いがコンテナ機能同等性は限定的） |

---

## OS 別の調査結果

### Linux

- Reikan ホストランタイムの基盤として最も有力です。
  - **隔離**: namespace
  - **リソース制御**: cgroups v2
  - **ハードニング**: seccomp + capability + LSM
- コンテナランタイムに近い設計へ素直にマッピングでき、予測可能なリソース境界を定義しやすいです。

### Windows

- Windows も強力なカーネル機能を持ちますが、モデルは Linux と異なります。
  - **Job Object**: クォータ/課金
  - **Silo / コンテナ機構**: namespace に近い隔離
  - **AppContainer + token/integrity**: 権限制約
- 多くのワークロードで強い隔離を実現できますが、Linux コンテナと同一意味論にはなりません。

### macOS

- macOS は sandbox・コード署名・TCC による強い保護を持ちますが、Linux 的 namespace/cgroup の直接同等物はありません。
- 厳格なマルチテナント隔離を実用的に行う場合、次の併用が現実的です。
  - より厳格な sandbox プロファイル
  - Linux コンテナ同等の要件が必要な場合は軽量 VM 境界
- よって、**仮想化なしで Linux/Windows と同水準を揃えるのは最も難しい** のが macOS です。

---

## カーネル非依存の単一レイヤーで同等保証は可能か

Linux/Windows/macOS で「同一レベル」の厳格保証を実現するうえで、純粋なユーザ空間抽象のみで完結するのは困難です。最終的な保証はカーネル機能で強制され、3 OS 間でその機能は同等ではありません。

実現可能な方針:

1. **Reikan 共通隔離契約**（CPU/メモリ/IO 上限、プロセス境界、FS/ネットワークポリシー、監査イベント）を定義する。
2. OS ごとの **バックエンド** を実装する。
   - Linux: namespace + cgroups + seccomp/LSM
   - Windows: silo + job object + appcontainer 系制約
   - macOS: sandbox/entitlement + 厳格ホストポリシー
3. 保証をティア化する（例: Tier A = 高保証、Tier B = 差異あり）。

現状で難しいこと:

- 仮想化を使わずに 3 OS で完全に同一意味論のホスト隔離を実現すること。
  - 最小公倍数レベルまで保証を下げるか、
  - 不足部分を VM 境界で補うか、
  のどちらかが必要になります。

---

## オプション分析: Docker-compatible コンテナへ隔離責務を移譲する場合

実務上の有力な選択肢として、低レイヤー隔離を既存の Docker-compatible コンテナ基盤に委譲し、Reikan をその上位の **コンテナ最適化 OS/ランタイム層** として位置づける方法があります。

### メリット

- **導入速度が高い**: OCI/コンテナの既存ツール群、イメージ形式、レジストリ、CI/CD を再利用できる。
- **運用知見を流用できる**: 既存のプラットフォーム運用手法で Reikan ホストモードを立ち上げやすい。
- **既存ハードニングの恩恵**: コンテナランタイム周辺で継続的に改善される防御機構や周辺ツールを活用できる。

### デメリット

- **隔離制御が間接化する**: 最終的な強制主体は Reikan 単体ではなく、ホストカーネル + コンテナランタイムになる。
- **OS 間の意味論差異が残る**: Linux/Windows/macOS 間でコンテナ保証の同一化は難しい。
- **ポリシー表現力の上限**: 下位基盤に同等プリミティブがない場合、Reikan が想定する capability/lifecycle 不変条件を完全強制できない可能性がある。

### GPU リソース統治のリスク（重要）

隔離責務のコンテナ委譲は、特にアクセラレータ統治で問題化しやすいです。

- GPU 可視性とスケジューリングはホストドライバや runtime plugin 側に依存し、Reikan の制御面が及ばない領域が生じる。
- 細粒度制約（エージェント別 VRAM 上限、プリエンプション方針、キュー公平性、決定的な課金/監査）は一部未提供またはベンダ依存になりやすい。
- その結果、AI-first OS として重要な「エンドツーエンドに監査可能なアクセラレータ制御保証」が弱まる可能性がある。

要するに、コンテナ委譲は移植性・導入性では有利だが、Reikan が最も重視すべき GPU/NPU 実行制御の主権を弱めうる。

### 位置づけの指針

- **bare-metal Reikan** を引き続き本流（完全制御・検証可能性・アクセラレータ統治）に置く。
- Docker-compatible 形態は **移行/ホスト運用モード** として保証範囲を明示して提供する。
- 特に GPU スケジューリング/隔離意味論は、コンテナ委譲モードではホスト/ランタイム依存であることを明記する。

---

## Reikan への提案

### 推奨方向

- この形態を **「Reikan Hosted Runtime」** として定義する（フル OS 置換とは区別）。
- 長期的な本流は引き続き bare-metal Reikan とする。
- Hosted Runtime は隔離ティアを明示する。
  - **Linux**: 厳格リソース隔離の第一級ターゲット
  - **Windows**: サポート。ただし意味論差異を明文化
  - **macOS**: 開発用途中心。厳格同等保証は VM 併用モードを選択肢にする

### この方向の利点

- ISO ブート前提を緩和し、導入ハードルを下げられる。
- 移植性を維持しつつ、カーネル差異を正直に扱える。
- OS ごとの保証境界を明文化し、セキュリティ主張を監査可能にできる。

---

## 参考資料

- Linux kernel documentation: cgroup v2 / namespaces / seccomp
- Microsoft documentation: Job Objects / AppContainer / Windows Containers / Host Compute Service
- Apple documentation: App Sandbox（seatbelt）/ entitlement model / Virtualization framework
