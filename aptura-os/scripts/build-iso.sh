#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../config/distro.env
source "${ROOT_DIR}/config/distro.env"
if [[ -f "${ROOT_DIR}/config/distro.local.env" ]]; then
  # shellcheck source=/dev/null
  source "${ROOT_DIR}/config/distro.local.env"
fi
# shellcheck source=../config/branding.conf
source "${ROOT_DIR}/config/branding.conf"
if [[ -f "${ROOT_DIR}/config/branding.local.env" ]]; then
  # shellcheck source=/dev/null
  source "${ROOT_DIR}/config/branding.local.env"
fi
: "${LIVE_USERNAME:=${DISTRO_ID}}"
: "${LIVE_HOSTNAME:=${DISTRO_ID}-live}"

log() {
  printf '[build-iso] %s\n' "$*"
}

die() {
  printf '[build-iso] ERROR: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"
}

sudo_cmd() {
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

copy_hooks() {
  local hook
  mkdir -p "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}/config/hooks/normal"
  for hook in "${ROOT_DIR}"/hooks/*.sh; do
    [[ -f "${hook}" ]] || continue
    cp -- "${hook}" "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}/config/hooks/normal/$(basename "${hook}" .sh).hook.chroot"
  done
}

write_package_list() {
  mkdir -p "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}/config/package-lists"
  grep -Ev '^[[:space:]]*(#|$)' "${ROOT_DIR}/config/packages.list" \
    > "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}/config/package-lists/aptura.list.chroot"
}

copy_local_packages() {
  mkdir -p "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}/config/packages.chroot"
  compgen -G "${ROOT_DIR}/${PACKAGE_OUTPUT_DIR}/*.deb" >/dev/null ||
    die "No local .deb packages found. Run scripts/build-packages.sh first."
  cp -- "${ROOT_DIR}/${PACKAGE_OUTPUT_DIR}"/*.deb "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}/config/packages.chroot/"
}

copy_installer_config() {
  mkdir -p "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}/config/includes.chroot/etc/calamares"
  cp -a "${ROOT_DIR}/installer/calamares/." "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}/config/includes.chroot/etc/calamares/"
}

copy_sources() {
  mkdir -p "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}/config/includes.chroot/etc/apt"
  cp -- "${ROOT_DIR}/config/apt-sources.list" "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}/config/includes.chroot/etc/apt/sources.list"
}

copy_keyrings() {
  local keyring_dir="${ROOT_DIR}/config/keyrings"
  [[ -d "${keyring_dir}" ]] || return 0

  mkdir -p "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}/config/includes.chroot/usr/share/keyrings"
  cp -- "${keyring_dir}"/* "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}/config/includes.chroot/usr/share/keyrings/"
}

set_live_config_permissions() {
  local component="${ROOT_DIR}/${LIVE_BUILD_WORKDIR}/config/includes.chroot/usr/lib/live/config/1170-aptura-sddm"
  [[ -f "${component}" ]] || return 0
  chmod 0755 "${component}"
}

prepare_live_build_tree() {
  rm -rf -- "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}"
  mkdir -p "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}"
  cp -a "${ROOT_DIR}/config/live-build/config" "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}/"
  set_live_config_permissions
  write_package_list
  copy_hooks
  copy_local_packages
  copy_installer_config
  copy_sources
  copy_keyrings
}

configure_live_build() {
  (
    cd "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}"
    lb config \
      --mode "${BASE_DISTRIBUTION}" \
      --distribution "${BASE_SUITE}" \
      --architectures "${ARCH}" \
      --archive-areas "${APT_COMPONENTS}" \
      --binary-images iso-hybrid \
      --bootloaders "syslinux,grub-efi" \
      --bootappend-live "boot=live components quiet splash username=${LIVE_USERNAME} hostname=${LIVE_HOSTNAME}" \
      --debian-installer live \
      --iso-application "${DISTRO_NAME} Live" \
      --iso-publisher "${DISTRO_NAME}" \
      --iso-volume "${ISO_VOLUME_ID}" \
      --mirror-bootstrap "${MIRROR_BOOTSTRAP}" \
      --mirror-binary "${MIRROR_BINARY}" \
      --mirror-chroot-security "${MIRROR_SECURITY}" \
      --apt-secure true \
      --apt-recommends true \
      --firmware-binary true \
      --firmware-chroot true
  )
}

build_image() {
  (
    cd "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}"
    sudo_cmd lb build
  )
}

collect_image() {
  mkdir -p "${ROOT_DIR}/${DIST_DIR}"
  local iso
  iso="$(find "${ROOT_DIR}/${LIVE_BUILD_WORKDIR}" -maxdepth 1 -type f \( -name '*.iso' -o -name '*.hybrid.iso' \) | head -n 1 || true)"
  [[ -n "${iso}" && -f "${iso}" ]] || die "live-build finished but no ISO was found"
  cp -- "${iso}" "${ROOT_DIR}/${DIST_DIR}/${ISO_NAME}"
  (
    cd "${ROOT_DIR}/${DIST_DIR}"
    sha256sum "${ISO_NAME}" > "${ISO_NAME}.sha256"
  )
  log "ISO written to ${ROOT_DIR}/${DIST_DIR}/${ISO_NAME}"
}

main() {
  [[ "$(uname -s)" == "Linux" ]] || die "live-build must run on Linux"
  require_command lb
  if [[ "${EUID}" -ne 0 ]]; then
    require_command sudo
  fi
  require_command sha256sum

  bash "${ROOT_DIR}/scripts/render-branding.sh"
  prepare_live_build_tree
  configure_live_build
  build_image
  collect_image
}

main "$@"
