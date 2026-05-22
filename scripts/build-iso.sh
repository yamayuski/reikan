#!/usr/bin/env bash
# scripts/build-iso.sh — Build a bootable GRUB2 ISO for the Reikan x86_64 kernel
#
# Usage:
#   bash scripts/build-iso.sh [--release]
#
# Output: build/reikan-x86_64.iso
#
# Requirements (Ubuntu / Debian):
#   sudo apt-get install grub-pc-bin grub-common xorriso mtools
#
# The ISO can be mounted in VirtualBox (Settings → Storage → Controller: IDE
# → Optical Drive) to boot the kernel.  Output from the kernel is visible
# both on the VGA screen and on the serial port (COM1, 115200 8N1).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
KERNEL_DIR="$REPO_ROOT/kernel"
BUILD_DIR="$REPO_ROOT/build"
ISO_DIR="$BUILD_DIR/iso"

# ── Parse arguments ──────────────────────────────────────────────────────────
PROFILE="debug"
CARGO_FLAGS=()
for arg in "$@"; do
    case "$arg" in
        --release)
            PROFILE="release"
            CARGO_FLAGS+=(--release)
            ;;
        *)
            echo "Unknown argument: $arg" >&2
            exit 1
            ;;
    esac
done

# ── Build kernel ─────────────────────────────────────────────────────────────
echo "[1/3] Building kernel ($PROFILE)…"
(
    cd "$KERNEL_DIR"
    cargo build "${CARGO_FLAGS[@]}"
)

KERNEL_BIN="$KERNEL_DIR/target/x86_64-unknown-none/$PROFILE/reikan-kernel"

if [[ ! -f "$KERNEL_BIN" ]]; then
    echo "ERROR: kernel binary not found at $KERNEL_BIN" >&2
    exit 1
fi

# ── Assemble ISO directory tree ──────────────────────────────────────────────
echo "[2/3] Assembling ISO directory tree…"
rm -rf "$ISO_DIR"
mkdir -p "$ISO_DIR/boot/grub"

cp "$KERNEL_BIN" "$ISO_DIR/boot/reikan-kernel"

cat > "$ISO_DIR/boot/grub/grub.cfg" << 'EOF'
set timeout=5
set default=0

menuentry "Reikan kernel (x86_64)" {
    multiboot2 /boot/reikan-kernel
    boot
}
EOF

# ── Create ISO ───────────────────────────────────────────────────────────────
echo "[3/3] Creating ISO image…"
mkdir -p "$BUILD_DIR"
grub-mkrescue -o "$BUILD_DIR/reikan-x86_64.iso" "$ISO_DIR"

echo ""
echo "ISO created: $BUILD_DIR/reikan-x86_64.iso"
echo ""
echo "To boot in VirtualBox:"
echo "  1. Create a new VM  (Type: Other, Version: Other/Unknown 64-bit)"
echo "  2. Settings → Storage → IDE Controller → Optical Drive"
echo "     → Choose Disk → select build/reikan-x86_64.iso"
echo "  3. Settings → Serial Ports → Port 1 → Enable, connect to a pipe/file"
echo "     to capture UTF-8 output from the kernel"
echo "  4. Start the VM"
