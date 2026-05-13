#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/config/distro.env"

# shellcheck source=../config/distro.env
source "${ENV_FILE}"

errors=0
warnings=0

info() {
  printf '[INFO] %s\n' "$*"
}

warn() {
  warnings=$((warnings + 1))
  printf '[WARN] %s\n' "$*" >&2
}

fail() {
  errors=$((errors + 1))
  printf '[FAIL] %s\n' "$*" >&2
}

have() {
  command -v "$1" >/dev/null 2>&1
}

require_file() {
  [[ -f "$1" ]] || fail "Missing file: ${1#${ROOT_DIR}/}"
}

require_dir() {
  [[ -d "$1" ]] || fail "Missing directory: ${1#${ROOT_DIR}/}"
}

check_platform() {
  if [[ "$(uname -s)" != "Linux" ]]; then
    warn "Full ISO builds require Linux. This validation can run elsewhere, but live-build will not."
  fi
}

check_commands() {
  local required=(bash awk sed grep find sort gzip dpkg-deb)
  local build_required=(lb dpkg-buildpackage dpkg-scanpackages apt-ftparchive xorriso mksquashfs gpg)
  local optional=(qemu-system-x86_64 qemu-system-aarch64 shellcheck)

  for cmd in "${required[@]}"; do
    have "${cmd}" || fail "Required command not found: ${cmd}"
  done

  for cmd in "${build_required[@]}"; do
    have "${cmd}" || warn "Full build command not found: ${cmd}"
  done

  for cmd in "${optional[@]}"; do
    have "${cmd}" || warn "Optional command not found: ${cmd}"
  done
}

check_config() {
  require_file "${ROOT_DIR}/config/distro.env"
  require_file "${ROOT_DIR}/config/packages.list"
  require_file "${ROOT_DIR}/config/apt-sources.list"
  require_file "${ROOT_DIR}/config/branding.conf"
  require_file "${ROOT_DIR}/installer/calamares/modules/bootloader.conf"
  require_file "${ROOT_DIR}/installer/calamares/modules/partition.conf"
  require_dir "${ROOT_DIR}/config/live-build"

  if ! grep -Eq '^[[:space:]]*deb[[:space:]]+' "${ROOT_DIR}/config/apt-sources.list"; then
    fail "config/apt-sources.list does not contain any deb entries"
  fi

  if grep -Eiq 'trusted=yes|allow-insecure' "${ROOT_DIR}/config/apt-sources.list"; then
    fail "config/apt-sources.list contains insecure repository options"
  fi

  local packages_count
  packages_count="$(grep -Ev '^[[:space:]]*(#|$)' "${ROOT_DIR}/config/packages.list" | wc -l | awk '{print $1}')"
  [[ "${packages_count}" -gt 0 ]] || fail "config/packages.list is empty"

  local boot_pkg
  for boot_pkg in grub-common grub2-common grub-pc-bin grub-efi-amd64-bin efibootmgr dosfstools mtools; do
    if ! grep -Eq "^[[:space:]]*${boot_pkg}([[:space:]]*)$" "${ROOT_DIR}/config/packages.list"; then
      fail "config/packages.list missing bootloader support package: ${boot_pkg}"
    fi
  done

  local cosmic_pkg
  for cosmic_pkg in cosmic-session cosmic-greeter cosmic-comp cosmic-panel cosmic-app-library cosmic-settings cosmic-files cosmic-term cosmic-edit xdg-desktop-portal-cosmic greetd; do
    if ! grep -Eq "^[[:space:]]*${cosmic_pkg}([[:space:]]*)$" "${ROOT_DIR}/config/packages.list"; then
      fail "config/packages.list missing COSMIC package: ${cosmic_pkg}"
    fi
  done

  local legacy_pkg
  for legacy_pkg in xfce4 xfce4-session xfwm4 xfdesktop4 xfce4-panel xfconf thunar lightdm lightdm-gtk-greeter; do
    if grep -Eq "^[[:space:]]*${legacy_pkg}([[:space:]]*)$" "${ROOT_DIR}/config/packages.list"; then
      fail "config/packages.list still contains legacy desktop package: ${legacy_pkg}"
    fi
  done

  if ! grep -Eq '^[[:space:]]*efiBootloaderId:[[:space:]]*"debian"' "${ROOT_DIR}/installer/calamares/modules/bootloader.conf"; then
    fail "bootloader.conf must set efiBootloaderId: \"debian\" for Debian GRUB EFI"
  fi

  if grep -Eq '^[[:space:]]*defaultPartitionTableType:[[:space:]]*gpt' "${ROOT_DIR}/installer/calamares/modules/partition.conf"; then
    fail "partition.conf forces GPT for BIOS installs; let Calamares select by boot mode"
  fi

  case " ${SUPPORTED_ARCHITECTURES} " in
    *" ${ARCH} "*) ;;
    *) fail "ARCH=${ARCH} is not listed in SUPPORTED_ARCHITECTURES=${SUPPORTED_ARCHITECTURES}" ;;
  esac
}

check_packages() {
  local pkg
  for pkg in aptura-meta aptura-branding aptura-desktop aptura-settings; do
    require_dir "${ROOT_DIR}/packages/${pkg}/debian"
    require_file "${ROOT_DIR}/packages/${pkg}/debian/control"
    require_file "${ROOT_DIR}/packages/${pkg}/debian/changelog"
    require_file "${ROOT_DIR}/packages/${pkg}/debian/rules"
    require_file "${ROOT_DIR}/packages/${pkg}/debian/install"
  done

  require_file "${ROOT_DIR}/packages/aptura-branding/etc/default/grub.d/aptura.cfg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/pixmaps/aptura.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/pixmaps/distributor-logo.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/aptura/branding/aptura-logo.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/aptura/branding/aptura-wordmark.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/backgrounds/aptura/aptura-retro-cosmic.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/cosmic/com.system76.CosmicSettings/v1/accent_palette_dark"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/cosmic/com.system76.CosmicSettings/v1/accent_palette_light"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/hicolor/scalable/apps/distributor-logo-aptura.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/hicolor/scalable/apps/aptura-welcome.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/etc/motd.d/00-aptura"
  require_file "${ROOT_DIR}/packages/aptura-branding/etc/profile.d/aptura-branding.sh"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/themes/Aptura-COSMIC/index.theme"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/themes/Aptura-COSMIC/gtk-3.0/gtk.css"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/themes/Aptura-COSMIC/gtk-3.0/gtk-dark.css"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/themes/Aptura-COSMIC/gtk-4.0/gtk.css"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/themes/Aptura-COSMIC/gtk-4.0/gtk-dark.css"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/Aptura-COSMIC/index.theme"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-about"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/aptura-about.desktop"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-welcome"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/aptura-welcome.desktop"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-system-check"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/aptura-system-check.desktop"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/metainfo/io.aptura.system-check.metainfo.xml"
}

check_permissions() {
  if [[ "$(uname -s)" == "Linux" && "${EUID}" -ne 0 ]] && ! have sudo; then
    warn "live-build often needs root. Install sudo or run inside a privileged build VM."
  fi
}

main() {
  info "Validating ${DISTRO_NAME} project at ${ROOT_DIR}"
  check_platform
  check_commands
  check_config
  check_packages
  check_permissions

  if [[ "${errors}" -gt 0 ]]; then
    printf '[FAIL] Validation finished with %d error(s) and %d warning(s)\n' "${errors}" "${warnings}" >&2
    exit 1
  fi

  printf '[OK] Validation finished with %d warning(s)\n' "${warnings}"
}

main "$@"
