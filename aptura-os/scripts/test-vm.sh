#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../config/distro.env
source "${ROOT_DIR}/config/distro.env"

ISO_PATH="${1:-${ROOT_DIR}/${DIST_DIR}/${ISO_NAME}}"

die() {
  printf '[test-vm] ERROR: %s\n' "$*" >&2
  exit 1
}

main() {
  command -v qemu-system-x86_64 >/dev/null 2>&1 || die "Missing qemu-system-x86_64"
  [[ -f "${ISO_PATH}" ]] || die "ISO not found: ${ISO_PATH}"

  qemu-system-x86_64 \
    -enable-kvm \
    -m 4096 \
    -smp 4 \
    -machine q35,accel=kvm:tcg \
    -cpu host \
    -boot d \
    -cdrom "${ISO_PATH}" \
    -display gtk \
    -device virtio-vga \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0
}

main "$@"
