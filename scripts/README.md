# scripts/

CI, build, and development scripts for the Reikan project.

---

## Scripts

| Script | Description |
|---|---|
| `build-iso.sh` | Build a bootable GRUB2 ISO image for the x86_64 kernel |

---

## `build-iso.sh`

Compiles the Reikan x86_64 kernel and wraps it in a GRUB2 bootable ISO.

```bash
# Install dependencies (Ubuntu / Debian)
sudo apt-get install grub-pc-bin grub-common xorriso mtools

# Build ISO (debug)
bash scripts/build-iso.sh

# Build ISO (release, size-optimised)
bash scripts/build-iso.sh --release
```

Output: `build/reikan-x86_64.iso`

See [kernel/README.md](../kernel/README.md) for full instructions on running
the ISO in VirtualBox.
