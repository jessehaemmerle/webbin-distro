#!/usr/bin/env bash
# Boot the built Aptura ISO in QEMU/KVM for manual testing.
#   ./scripts/test-vm.sh [path-to.iso]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
. "${SCRIPT_DIR}/lib/common.sh"
load_distro_env

ISO="${1:-${REPO_ROOT}/${DIST_DIR}/${ISO_NAME}}"
[ -f "${ISO}" ] || die "ISO not found: ${ISO} (build it first with ./build.sh)"
require_cmd qemu-system-x86_64

ACCEL="tcg"
if [ -e /dev/kvm ]; then ACCEL="kvm"; fi
log "Booting ${ISO} in QEMU (accel=${ACCEL})"

# Throwaway disk so Calamares install tests don't touch the host.
DISK="${REPO_ROOT}/build/test-disk.qcow2"
if [ ! -f "${DISK}" ]; then
  qemu-img create -f qcow2 "${DISK}" 25G >/dev/null
fi

exec qemu-system-x86_64 \
  -machine q35,accel="${ACCEL}" \
  -m 4096 -smp 2 \
  -cpu host \
  -drive file="${DISK}",if=virtio,format=qcow2 \
  -cdrom "${ISO}" \
  -boot d \
  -vga virtio -display gtk \
  -device intel-hda -device hda-duplex \
  -bios /usr/share/ovmf/OVMF.fd
