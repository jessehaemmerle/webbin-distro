#!/usr/bin/env bash
# Build a custom mainline Linux kernel as Aptura-branded .deb packages.
#
# Output: linux-image-<ver>-aptura_*.deb and linux-headers-<ver>-aptura_*.deb in
# the kernel output dir, ready to be picked up by scripts/create-local-repo.sh.
#
# NOTE: As of early 2026 there is no "Linux 7" release; the newest line is 6.x.
# KERNEL_VERSION in config/distro.env selects which mainline tarball to build.
# When 7.0 ships, set KERNEL_VERSION="7.0" (or a 7.x point release) and rerun.
#
# This MUST run on a Linux host with build tooling (see docs/kernel.md). It will
# refuse to run elsewhere.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=/dev/null
. "${REPO_ROOT}/scripts/lib/common.sh"
load_distro_env

if [ "$(uname -s)" != "Linux" ]; then
  die "Kernel builds require a Linux host. Current OS: $(uname -s)."
fi

if [ "${BUILD_CUSTOM_KERNEL}" != "true" ]; then
  log "BUILD_CUSTOM_KERNEL is not true; skipping custom kernel build."
  exit 0
fi

require_cmd make gcc flex bison bc curl xz tar
# Debian/Ubuntu packaging helpers used by 'make bindeb-pkg'.
require_cmd dpkg-deb

OUT_DIR="${REPO_ROOT}/${KERNEL_OUTPUT_DIR}"
WORK_DIR="${REPO_ROOT}/${BUILD_DIR}/kernel-src"
mkdir -p "${OUT_DIR}" "${WORK_DIR}"

SERIES_DIR="v${KERNEL_VERSION%%.*}.x"
TARBALL="linux-${KERNEL_VERSION}.tar.xz"
URL="${KERNEL_SOURCE_BASE}/${SERIES_DIR}/${TARBALL}"
SRC_DIR="${WORK_DIR}/linux-${KERNEL_VERSION}"

log "Building Aptura kernel ${KERNEL_VERSION}${KERNEL_LOCALVERSION}"

if [ ! -f "${WORK_DIR}/${TARBALL}" ]; then
  log "Downloading ${URL}"
  curl -fL --retry 3 -o "${WORK_DIR}/${TARBALL}" "${URL}"
fi

if [ ! -d "${SRC_DIR}" ]; then
  log "Extracting ${TARBALL}"
  tar -C "${WORK_DIR}" -xf "${WORK_DIR}/${TARBALL}"
fi

cd "${SRC_DIR}"

# Start from the running/host Ubuntu kernel config when available, otherwise a
# sane default, then layer the Aptura overrides on top.
if [ -f "/boot/config-$(uname -r)" ]; then
  log "Seeding .config from /boot/config-$(uname -r)"
  cp "/boot/config-$(uname -r)" .config
  make olddefconfig
else
  log "No host config found; using 'make defconfig'"
  make defconfig
fi

log "Applying Aptura kernel config overrides"
"${SCRIPT_DIR}/apply-aptura-config.sh" "${SRC_DIR}/.config" "${SCRIPT_DIR}/aptura-kernel.config"
make olddefconfig

# Brand the kernel version string: uname -r will end in -aptura.
export LOCALVERSION="${KERNEL_LOCALVERSION}"
scripts/config --disable LOCALVERSION_AUTO || true
scripts/config --set-str LOCALVERSION "${KERNEL_LOCALVERSION}" || true

JOBS="$(nproc 2>/dev/null || echo 2)"
log "Compiling with ${JOBS} jobs and producing .deb packages (make bindeb-pkg)"
make -j"${JOBS}" bindeb-pkg

log "Collecting kernel .deb artifacts into ${OUT_DIR}"
find "${WORK_DIR}" -maxdepth 1 -name '*.deb' -exec cp -v {} "${OUT_DIR}/" \;

log "Custom kernel build complete."
ls -1 "${OUT_DIR}"/*.deb
