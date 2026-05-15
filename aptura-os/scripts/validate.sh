#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/config/distro.env"

# shellcheck source=../config/distro.env
source "${ENV_FILE}"
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

: "${SHELL_SESSION_ID:=aptura}"
: "${THEME_NAME:=Aptura-Shell}"
: "${GTK_THEME_NAME:=${THEME_NAME}}"
: "${ICON_THEME_NAME:=Aptura-Shell}"
: "${DEFAULT_WALLPAPER:=/usr/share/backgrounds/aptura/aptura-context-grid.svg}"
: "${WALLPAPER_ALTERNATIVES:=}"
: "${APP_ICON:=/usr/share/icons/hicolor/scalable/apps/aptura.svg}"
: "${USER_ICON:=/usr/share/pixmaps/aptura.svg}"
: "${LOGO_NAME:=distributor-logo-aptura}"
: "${LOGO_ASSET:=/usr/share/aptura/branding/aptura-logo.svg}"
: "${WORDMARK_ASSET:=/usr/share/aptura/branding/aptura-wordmark.svg}"
: "${BADGE_ASSET:=/usr/share/aptura/branding/aptura-badge.svg}"

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

require_packaged_branding_file() {
  local installed_path="$1"
  if [[ "${installed_path}" != /* ]]; then
    fail "Branding asset path must be absolute: ${installed_path}"
    return
  fi

  require_file "${ROOT_DIR}/packages/aptura-branding${installed_path}"
}

first_matching_line() {
  local pattern="$1"
  local file="$2"
  grep -nE "${pattern}" "${file}" | head -n 1 | cut -d: -f1 || true
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
  require_file "${ROOT_DIR}/scripts/render-branding.sh"
  require_file "${ROOT_DIR}/config/live-build/config/includes.chroot/usr/lib/live/config/1170-aptura-sddm"
  require_file "${ROOT_DIR}/installer/calamares/modules/bootloader.conf"
  require_file "${ROOT_DIR}/installer/calamares/modules/displaymanager.conf"
  require_file "${ROOT_DIR}/installer/calamares/modules/fstab.conf"
  require_file "${ROOT_DIR}/installer/calamares/modules/grubcfg.conf"
  require_file "${ROOT_DIR}/installer/calamares/modules/initramfs.conf"
  require_file "${ROOT_DIR}/installer/calamares/modules/luksbootkeyfile.conf"
  require_file "${ROOT_DIR}/installer/calamares/modules/packages.conf"
  require_file "${ROOT_DIR}/installer/calamares/modules/services-systemd.conf"
  require_file "${ROOT_DIR}/installer/calamares/modules/partition.conf"
  require_dir "${ROOT_DIR}/config/live-build"

  local removed_cosmic_file
  for removed_cosmic_file in \
    "${ROOT_DIR}/config/keyrings/aptura-cosmic-desktop-obs.asc" \
    "${ROOT_DIR}/config/live-build/config/archives/cosmic-desktop.list.chroot" \
    "${ROOT_DIR}/config/live-build/config/archives/cosmic-desktop.list.binary" \
    "${ROOT_DIR}/config/live-build/config/archives/cosmic-desktop.key.chroot" \
    "${ROOT_DIR}/config/live-build/config/archives/cosmic-desktop.key.binary" \
    "${ROOT_DIR}/config/live-build/config/includes.chroot/etc/apt/preferences.d/60aptura-cosmic-desktop-obs" \
    "${ROOT_DIR}/packages/aptura-settings/etc/apt/preferences.d/60aptura-cosmic-desktop-obs"; do
    if [[ -e "${removed_cosmic_file}" ]]; then
      fail "COSMIC OBS file should be removed: ${removed_cosmic_file#${ROOT_DIR}/}"
    fi
  done

  if ! grep -Eq '^[[:space:]]*deb[[:space:]]+' "${ROOT_DIR}/config/apt-sources.list"; then
    fail "config/apt-sources.list does not contain any deb entries"
  fi

  if grep -Eiq 'trusted=yes|allow-insecure' "${ROOT_DIR}/config/apt-sources.list"; then
    fail "config/apt-sources.list contains insecure repository options"
  fi

  if grep -Eq 'aptura-cosmic-desktop-obs|cosmic-desktop|download\.opensuse\.org/repositories/home:/nomispaz:/debian:/cosmic-desktop' "${ROOT_DIR}/config/apt-sources.list"; then
    fail "config/apt-sources.list still contains the COSMIC OBS repository"
  fi

  local packages_count
  packages_count="$(grep -Ev '^[[:space:]]*(#|$)' "${ROOT_DIR}/config/packages.list" | wc -l | awk '{print $1}')"
  [[ "${packages_count}" -gt 0 ]] || fail "config/packages.list is empty"

  local boot_pkg
  for boot_pkg in grub-common grub2-common grub-pc-bin grub-efi-amd64-bin efibootmgr dosfstools mtools cryptsetup cryptsetup-initramfs; do
    if ! grep -Eq "^[[:space:]]*${boot_pkg}([[:space:]]*)$" "${ROOT_DIR}/config/packages.list"; then
      fail "config/packages.list missing bootloader support package: ${boot_pkg}"
    fi
  done

  local conflicting_grub_pkg
  for conflicting_grub_pkg in grub-pc grub-efi-amd64; do
    if grep -Eq "^[[:space:]]*${conflicting_grub_pkg}([[:space:]]*)$" "${ROOT_DIR}/config/packages.list"; then
      fail "config/packages.list contains mutually exclusive GRUB package: ${conflicting_grub_pkg}"
    fi
  done

  if ! grep -Eq -- '--bootloaders[[:space:]]+"syslinux,grub-efi"' "${ROOT_DIR}/scripts/build-iso.sh"; then
    fail "scripts/build-iso.sh must include BIOS and UEFI ISO bootloaders"
  fi

  local shell_pkg
  for shell_pkg in labwc waybar wofi swaybg mako-notifier foot grim slurp swaylock wl-clipboard libnotify-bin xdg-desktop-portal-wlr polkit-kde-agent-1; do
    if ! grep -Eq "^[[:space:]]*${shell_pkg}([[:space:]]*)$" "${ROOT_DIR}/config/packages.list"; then
      fail "config/packages.list missing Aptura Shell package: ${shell_pkg}"
    fi
  done

  local plasma_pkg
  for plasma_pkg in kde-plasma-desktop plasma-workspace sddm systemsettings dolphin konsole kate ark kde-spectacle plasma-discover xdg-desktop-portal-kde; do
    if ! grep -Eq "^[[:space:]]*${plasma_pkg}([[:space:]]*)$" "${ROOT_DIR}/config/packages.list"; then
      fail "config/packages.list missing Plasma fallback package: ${plasma_pkg}"
    fi
  done

  local removed_desktop_pkg
  for removed_desktop_pkg in spectacle cosmic-session cosmic-greeter cosmic-greeter-daemon cosmic-comp cosmic-panel cosmic-applets cosmic-app-library cosmic-icons cosmic-launcher cosmic-bg cosmic-idle cosmic-notifications cosmic-osd cosmic-randr cosmic-screenshot cosmic-settings cosmic-settings-daemon cosmic-files cosmic-term cosmic-edit cosmic-player cosmic-wallpapers cosmic-workspaces xdg-desktop-portal-cosmic greetd; do
    if grep -Eq "^[[:space:]]*${removed_desktop_pkg}([[:space:]]*)$" "${ROOT_DIR}/config/packages.list"; then
      fail "config/packages.list still contains removed desktop package: ${removed_desktop_pkg}"
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

  if grep -Eq '^[[:space:]]*(kernel|img|fallback|timeout):' "${ROOT_DIR}/installer/calamares/modules/bootloader.conf"; then
    fail "bootloader.conf contains obsolete systemd-boot keys; use current Calamares keys"
  fi

  if ! grep -Eq '^[[:space:]]*kernelSearchPath:[[:space:]]*"/usr/lib/modules"' "${ROOT_DIR}/installer/calamares/modules/bootloader.conf"; then
    fail "bootloader.conf must set kernelSearchPath for current Calamares bootloader support"
  fi

  if ! grep -Eq '^[[:space:]]*crypttabOptions:[[:space:]]*luks,keyscript=/bin/cat[[:space:]]*$' "${ROOT_DIR}/installer/calamares/modules/fstab.conf"; then
    fail "fstab.conf must set Debian-compatible crypttabOptions for encrypted installs"
  fi

  if ! grep -Eq '^[[:space:]]*backend:[[:space:]]*apt[[:space:]]*$' "${ROOT_DIR}/installer/calamares/modules/packages.conf"; then
    fail "packages.conf must use the apt backend"
  fi

  if ! grep -Eq '^[[:space:]]*-[[:space:]]*live-boot[[:space:]]*$' "${ROOT_DIR}/installer/calamares/modules/packages.conf"; then
    fail "packages.conf must remove live-boot from the installed target"
  fi

  local settings_conf="${ROOT_DIR}/installer/calamares/settings.conf"
  local grubcfg_line bootloader_line packages_line luks_line initramfscfg_line initramfs_line
  grubcfg_line="$(first_matching_line '^[[:space:]]*-[[:space:]]*grubcfg[[:space:]]*$' "${settings_conf}")"
  bootloader_line="$(first_matching_line '^[[:space:]]*-[[:space:]]*bootloader[[:space:]]*$' "${settings_conf}")"
  packages_line="$(first_matching_line '^[[:space:]]*-[[:space:]]*packages[[:space:]]*$' "${settings_conf}")"
  luks_line="$(first_matching_line '^[[:space:]]*-[[:space:]]*luksbootkeyfile[[:space:]]*$' "${settings_conf}")"
  initramfscfg_line="$(first_matching_line '^[[:space:]]*-[[:space:]]*initramfscfg[[:space:]]*$' "${settings_conf}")"
  initramfs_line="$(first_matching_line '^[[:space:]]*-[[:space:]]*initramfs[[:space:]]*$' "${settings_conf}")"

  if [[ -z "${grubcfg_line}" || -z "${bootloader_line}" || -z "${packages_line}" || -z "${luks_line}" || -z "${initramfscfg_line}" || -z "${initramfs_line}" ]]; then
    fail "settings.conf missing required bootloader/LUKS exec modules"
  else
    if (( grubcfg_line >= bootloader_line )); then
      fail "settings.conf must run grubcfg before bootloader"
    fi
    if (( packages_line <= bootloader_line || packages_line >= luks_line )); then
      fail "settings.conf must remove live packages after bootloader and before LUKS/initramfs jobs"
    fi
    if (( luks_line >= initramfscfg_line || initramfscfg_line >= initramfs_line )); then
      fail "settings.conf must run luksbootkeyfile, initramfscfg, then initramfs in order"
    fi
  fi

  if grep -Eq '^[[:space:]]*defaultPartitionTableType:[[:space:]]*gpt' "${ROOT_DIR}/installer/calamares/modules/partition.conf"; then
    fail "partition.conf forces GPT for BIOS installs; let Calamares select by boot mode"
  fi

  if ! grep -Eq '^[[:space:]]*-[[:space:]]*sddm[[:space:]]*$' "${ROOT_DIR}/installer/calamares/modules/displaymanager.conf"; then
    fail "displaymanager.conf must select sddm"
  fi

  if ! grep -Eq "^[[:space:]]*desktopFile:[[:space:]]*\"${SHELL_SESSION_ID}\"" "${ROOT_DIR}/installer/calamares/modules/displaymanager.conf"; then
    fail "displaymanager.conf must set ${SHELL_SESSION_ID} as the default desktop file"
  fi

  if ! grep -Eq '^[[:space:]]*executable:[[:space:]]*"aptura-session"' "${ROOT_DIR}/installer/calamares/modules/displaymanager.conf"; then
    fail "displaymanager.conf must launch aptura-session"
  fi

  if ! grep -Eq '^[[:space:]]*Session=\$\{SHELL_SESSION_ID\}[[:space:]]*$' "${ROOT_DIR}/config/live-build/config/includes.chroot/usr/lib/live/config/1170-aptura-sddm"; then
    fail "live SDDM config must autologin through SHELL_SESSION_ID from branding"
  fi

  if grep -Eq '^[[:space:]]*-[[:space:]]*xfs[[:space:]]*$' "${ROOT_DIR}/installer/calamares/modules/partition.conf"; then
    fail "partition.conf must not offer XFS root until a separate GRUB-safe /boot layout exists"
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

  local meta_control="${ROOT_DIR}/packages/aptura-meta/debian/control"
  local shell_dep
  for shell_dep in labwc waybar wofi swaybg mako-notifier foot grim slurp swaylock wl-clipboard libnotify-bin xdg-desktop-portal-wlr polkit-kde-agent-1; do
    if ! grep -Eq "^[[:space:]]*${shell_dep},?[[:space:]]*$" "${meta_control}"; then
      fail "aptura-meta missing Aptura Shell dependency: ${shell_dep}"
    fi
  done

  local boot_dep
  for boot_dep in cryptsetup cryptsetup-initramfs grub-common grub2-common grub-pc-bin grub-efi-amd64-bin efibootmgr; do
    if ! grep -Eq "^[[:space:]]*${boot_dep},?[[:space:]]*$" "${meta_control}"; then
      fail "aptura-meta missing bootloader/encryption dependency: ${boot_dep}"
    fi
  done

  local conflicting_grub_pkg
  for conflicting_grub_pkg in grub-pc grub-efi-amd64; do
    if grep -Eq "^[[:space:]]*${conflicting_grub_pkg},?[[:space:]]*$" "${meta_control}"; then
      fail "aptura-meta depends on mutually exclusive GRUB package: ${conflicting_grub_pkg}"
    fi
  done

  require_file "${ROOT_DIR}/packages/aptura-branding/etc/default/grub.d/aptura.cfg"
  require_packaged_branding_file "${USER_ICON}"
  require_packaged_branding_file "${APP_ICON}"
  require_packaged_branding_file "${LOGO_ASSET}"
  require_packaged_branding_file "${WORDMARK_ASSET}"
  require_packaged_branding_file "${BADGE_ASSET}"
  require_packaged_branding_file "${DEFAULT_WALLPAPER}"
  local wallpaper_asset
  for wallpaper_asset in ${WALLPAPER_ALTERNATIVES//,/ }; do
    require_packaged_branding_file "${wallpaper_asset}"
  done
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/hicolor/scalable/apps/${LOGO_NAME}.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/hicolor/scalable/apps/aptura-welcome.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/etc/motd.d/00-aptura"
  require_file "${ROOT_DIR}/packages/aptura-branding/etc/profile.d/aptura-branding.sh"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/themes/${THEME_NAME}/index.theme"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/themes/${THEME_NAME}/gtk-3.0/gtk.css"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/themes/${THEME_NAME}/gtk-3.0/gtk-dark.css"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/themes/${THEME_NAME}/gtk-4.0/gtk.css"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/themes/${THEME_NAME}/gtk-4.0/gtk-dark.css"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/${ICON_THEME_NAME}/index.theme"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/aptura-shell/branding.sh"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-session"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-panel"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-launcher"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-control"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-screenshot"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/wayland-sessions/aptura.desktop"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/aptura-shell/xdg/labwc/rc.xml"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/aptura-shell/xdg/labwc/autostart"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/aptura-shell/xdg/labwc/menu.xml"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/aptura-shell/waybar/config.jsonc"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/aptura-shell/waybar/style.css"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/aptura-shell/wofi/config"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/aptura-shell/wofi/style.css"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-about"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/aptura-about.desktop"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-welcome"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/aptura-welcome.desktop"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-system-check"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/aptura-system-check.desktop"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-safe-update"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/aptura-safe-update.desktop"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-rescue-center"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/aptura-rescue-center.desktop"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-privacy-check"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/aptura-privacy-check.desktop"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-mode"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/aptura-mode.desktop"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-support-bundle"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/aptura-support-bundle.desktop"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-journey"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/aptura-journey.desktop"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-context"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/aptura-context.desktop"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-shift"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/aptura-shift.desktop"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-aftercare"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/aptura-aftercare.desktop"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/bin/aptura-live-bridge"
  require_file "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/aptura-live-bridge.desktop"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/${ICON_THEME_NAME}/scalable/apps/aptura-journey.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/${ICON_THEME_NAME}/scalable/apps/aptura-context.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/${ICON_THEME_NAME}/scalable/apps/aptura-shift.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/${ICON_THEME_NAME}/scalable/apps/aptura-aftercare.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/${ICON_THEME_NAME}/scalable/apps/aptura-live-bridge.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/hicolor/scalable/apps/aptura-journey.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/hicolor/scalable/apps/aptura-context.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/hicolor/scalable/apps/aptura-shift.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/hicolor/scalable/apps/aptura-aftercare.svg"
  require_file "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/hicolor/scalable/apps/aptura-live-bridge.svg"
  require_file "${ROOT_DIR}/packages/aptura-settings/etc/skel/.config/gtk-3.0/settings.ini"
  require_file "${ROOT_DIR}/packages/aptura-settings/etc/skel/.config/gtk-4.0/settings.ini"
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
