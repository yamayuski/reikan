# Cross-Platform Resource Isolation (Linux / Windows / macOS)

> 日本語版は [cross-platform-isolation.ja.md](cross-platform-isolation.ja.md) をご覧ください。

---

## Overview

This note investigates whether Reikan could run as a lightweight, strictly isolated runtime on top of existing host OSes (Windows/macOS/Linux), instead of requiring a VirtualBox-style VM-first workflow.

The key question is:

> Can we achieve Docker-class resource isolation on all three host OSes without depending on a specific kernel's native container model?

Short answer: **partially, but not uniformly**. Linux can provide near-complete process/container isolation primitives natively. Windows can provide strong process isolation with different semantics. macOS provides sandboxing, but not Linux-equivalent namespace/cgroup primitives.

---

## Isolation Primitive Comparison

| Dimension | Linux | Windows | macOS |
|---|---|---|---|
| Process/namespace isolation | Namespaces (`pid`, `net`, `mnt`, `ipc`, `uts`, `user`, `time`) | Server silos + object namespaces | App Sandbox / seatbelt profiles (policy sandbox, not Linux-style namespaces) |
| Resource quotas | cgroups v2 (CPU, memory, IO, pids) | Job Objects (CPU, memory, process limits) | rlimits + QoS controls (limited compared to cgroups hierarchy) |
| Syscall/API attack-surface reduction | seccomp-BPF, capabilities, LSM (SELinux/AppArmor) | Token-based restrictions, integrity levels, AppContainer capabilities | Sandbox policy allow/deny + code-signing/TCC ecosystem |
| Filesystem isolation | Mount namespaces, overlayfs, id-mapped mounts | Layered/container filesystems in Windows Containers | Sandbox path entitlements and containerized app data dirs |
| Network isolation | Network namespaces, veth/bridge/iptables | HNS/HCS networking model | No direct per-process network namespace equivalent |
| Practical parity with Docker model | High | Medium–High (Windows-native workload focused) | Low–Medium (security sandboxing strong, container primitive parity limited) |

---

## Findings by Host OS

### Linux

- Linux already has the strongest native substrate for a Reikan-hosted runtime:
  - **isolation**: namespaces
  - **resource control**: cgroups v2
  - **hardening**: seccomp + capabilities + LSM
- A Reikan runtime on Linux can map closely to a container-runtime architecture and achieve predictable resource envelopes.

### Windows

- Windows has robust kernel primitives, but with a different model:
  - **Job Objects** for quotas and accounting
  - **Silos / container infrastructure** for namespace-like isolation
  - **AppContainer + token/integrity model** for capability-style restriction
- This can deliver strong isolation for many workloads, but behavior differs from Linux containers and often integrates best with Windows-native container stacks.

### macOS

- macOS has strong security controls (sandbox, code-signing, TCC), but lacks first-class Linux-style namespace/cgroup equivalents.
- Practical strict multi-tenant runtime isolation on macOS often relies on:
  - tighter sandbox profiles for process restrictions, and/or
  - a lightweight VM boundary when Linux-container semantics are required.
- Result: achieving Linux/Windows-equivalent host-level resource isolation *without* virtualization is the hardest on macOS.

---

## Can One Kernel-Agnostic Isolation Layer Provide Equal Guarantees?

For strict "same-level" guarantees across Linux/Windows/macOS, a single purely user-space abstraction is not enough. Isolation guarantees are ultimately enforced by kernel primitives, and those primitives are not equivalent across the three OS families.

What is feasible:

1. Define a **common Reikan isolation contract** (CPU/memory/IO quotas, process boundary, filesystem/network policy, audit events).
2. Implement **per-OS backends**:
   - Linux backend: namespaces + cgroups + seccomp/LSM
   - Windows backend: silos/job objects/appcontainer-style restrictions
   - macOS backend: sandbox/entitlements + strict host policy
3. Classify guarantees as tiers (for example: Tier A = full parity target, Tier B = bounded differences).

What is not feasible today:

- Perfectly identical host-level isolation semantics on all three OSes without either:
  - accepting lowest-common-denominator guarantees, or
  - introducing a virtualization boundary where host primitives are insufficient.

---

## Recommendation for Reikan

### Proposed Direction

- Position this mode as **"Reikan Hosted Runtime"** (not a full OS replacement).
- Keep bare-metal Reikan as the long-term architecture target.
- Deliver hosted runtime with explicit isolation tiers:
  - **Linux**: first-class target for strict resource isolation.
  - **Windows**: supported with documented semantic differences.
  - **macOS**: supported for development workloads; strict isolation may require VM-backed mode for parity.

### Why this is practical

- Improves onboarding and adoption (no mandatory ISO boot path for every user).
- Preserves portability while being honest about kernel-level differences.
- Keeps security claims auditable by documenting per-OS guarantee boundaries.

---

## References

- Linux kernel documentation: cgroup v2, namespaces, seccomp
- Microsoft documentation: Job Objects, AppContainer, Windows Containers / Host Compute Service
- Apple documentation: App Sandbox (seatbelt), entitlement model, Virtualization framework
