#!/usr/bin/env bash
# Build the Aptura OS live ISO with live-build (Ubuntu mode).
# Linux host only; needs live-build and root for some live-build stages.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
. "${SCRIPT_DIR}/lib/common.sh"
load_distro_env

is_linux || die "ISO builds require Linux with live-build."
require_cmd lb

WORK="${REPO_ROOT}/${LIVE_BUILD_WORKDIR}"
assert_inside_repo "${REPO_ROOT}/build"
rm -rf "${WORK}"
mkdir -p "${WORK}"

log "Seeding live-build config"
cp -a "${REPO_ROOT}/config/live-build/config" "${WORK}/config"

# --- Inject chroot hooks ----------------------------------------------------
log "Injecting chroot hooks"
mkdir -p "${WORK}/config/hooks/normal"
for h in "${REPO_ROOT}"/hooks/0*.sh; do
  base="$(basename "${h}" .sh)"
  install -m 0755 "${h}" "${WORK}/config/hooks/normal/${base}.hook.chroot"
done

# --- Stage Calamares config + branding into the live filesystem -------------
log "Staging Calamares config into includes.chroot"
INST_DST="${WORK}/config/includes.chroot/usr/share/aptura/installer"
mkdir -p "${INST_DST}"
cp -a "${REPO_ROOT}/installer/calamares/settings.conf" "${INST_DST}/"
cp -a "${REPO_ROOT}/installer/calamares/modules" "${INST_DST}/"
cp -a "${REPO_ROOT}/installer/calamares/branding" "${INST_DST}/"
# Pull the shared logo into the Calamares branding dir.
cp -a "${REPO_ROOT}/branding/assets/logo.svg" "${INST_DST}/branding/aptura/logo.svg"

# --- Stage rendered branding assets into the live filesystem ----------------
if [ -d "${REPO_ROOT}/build/branding/assets" ]; then
  log "Staging wallpapers/logo into includes.chroot"
  BG_DST="${WORK}/config/includes.chroot/usr/share/backgrounds/aptura"
  mkdir -p "${BG_DST}"
  cp -a "${REPO_ROOT}/build/branding/assets/." "${BG_DST}/"
fi

# --- Wire in the local Aptura APT repository --------------------------------
LOCAL_REPO="${REPO_ROOT}/${LOCAL_REPO_DIR}"
if [ -d "${LOCAL_REPO}/pool" ]; then
  log "Wiring local Aptura repo as a chroot archive"
  echo "deb [trusted=yes] file:${LOCAL_REPO} ${BASE_SUITE} main" \
    > "${WORK}/config/archives/aptura-local.list.chroot"
fi

# --- Fetch the Mozilla signing key for the Firefox .deb repo ----------------
if [ -f "${WORK}/config/archives/mozilla.list.chroot" ]; then
  log "Fetching Mozilla signing key"
  if curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg \
       -o "${WORK}/config/archives/mozilla.key.chroot"; then
    :
  else
    warn "could not fetch Mozilla key; Firefox may fall back to the Ubuntu snap."
  fi
fi

# --- Configure live-build for Ubuntu ----------------------------------------
cd "${WORK}"
log "Running lb config (Ubuntu ${BASE_SUITE})"
lb config noauto \
  --mode ubuntu \
  --distribution "${BASE_SUITE}" \
  --archive-areas "${APT_COMPONENTS}" \
  --architectures "${ARCH}" \
  --linux-flavours none \
  --bootloaders grub-efi,grub-pc \
  --mirror-bootstrap "${MIRROR_BOOTSTRAP}" \
  --mirror-binary "${MIRROR_BINARY}" \
  --iso-volume "${ISO_VOLUME_ID}" \
  --iso-application "${DISTRO_NAME}" \
  --bootappend-live "boot=live components quiet splash"

log "Running lb build (this is long and needs root/loop devices)"
if [ "$(id -u)" -ne 0 ]; then
  warn "not root: live-build usually needs root. Re-run with sudo if it fails."
fi
lb build

# --- Collect the artifact ---------------------------------------------------
DIST="${REPO_ROOT}/${DIST_DIR}"
mkdir -p "${DIST}"
ISO_SRC="$(find "${WORK}" -maxdepth 1 -name 'live-image-*.iso' -o -name '*.iso' | head -n1)"
[ -n "${ISO_SRC}" ] || die "no ISO produced by live-build."
cp -v "${ISO_SRC}" "${DIST}/${ISO_NAME}"
( cd "${DIST}" && sha256sum "${ISO_NAME}" > "${ISO_NAME}.sha256" )
log "ISO ready: ${DIST}/${ISO_NAME}"
