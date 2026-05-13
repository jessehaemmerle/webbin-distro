#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
errors=0

fail() {
  errors=$((errors + 1))
  printf '[FAIL] %s\n' "$*" >&2
}

ok() {
  printf '[OK] %s\n' "$*"
}

check_control_field() {
  local file="$1"
  local field="$2"
  if grep -Eq "^${field}:" "${file}"; then
    ok "$(basename "$(dirname "$(dirname "${file}")")") control has ${field}"
  else
    fail "${file#${ROOT_DIR}/} missing ${field}"
  fi
}

check_control_depends() {
  local control="$1"
  local package_name="$2"
  if grep -Eq "^[[:space:]]*${package_name},?[[:space:]]*$" "${control}"; then
    ok "$(basename "$(dirname "$(dirname "${control}")")") depends on ${package_name}"
  else
    fail "${control#${ROOT_DIR}/} missing dependency: ${package_name}"
  fi
}

check_control_not_depends() {
  local control="$1"
  local package_name="$2"
  if grep -Eq "^[[:space:]]*${package_name},?[[:space:]]*$" "${control}"; then
    fail "${control#${ROOT_DIR}/} still depends on ${package_name}"
  else
    ok "$(basename "$(dirname "$(dirname "${control}")")") does not depend on ${package_name}"
  fi
}

check_live_package_list_contains() {
  local package_name="$1"
  local package_list="${ROOT_DIR}/config/packages.list"
  if grep -Eq "^${package_name}$" "${package_list}"; then
    ok "packages.list includes ${package_name}"
  else
    fail "config/packages.list missing package: ${package_name}"
  fi
}

check_live_package_list_not_contains() {
  local package_name="$1"
  local package_list="${ROOT_DIR}/config/packages.list"
  if grep -Eq "^${package_name}$" "${package_list}"; then
    fail "config/packages.list still includes ${package_name}"
  else
    ok "packages.list does not include ${package_name}"
  fi
}

check_package() {
  local pkg="$1"
  local dir="${ROOT_DIR}/packages/${pkg}"
  local control="${dir}/debian/control"
  local changelog="${dir}/debian/changelog"
  local rules="${dir}/debian/rules"
  local install="${dir}/debian/install"
  local format="${dir}/debian/source/format"

  [[ -d "${dir}" ]] || { fail "Missing package directory: ${pkg}"; return; }
  [[ -f "${control}" ]] || fail "Missing ${pkg}/debian/control"
  [[ -f "${changelog}" ]] || fail "Missing ${pkg}/debian/changelog"
  [[ -f "${rules}" ]] || fail "Missing ${pkg}/debian/rules"
  [[ -f "${install}" ]] || fail "Missing ${pkg}/debian/install"
  [[ -f "${format}" ]] || fail "Missing ${pkg}/debian/source/format"
  [[ -x "${rules}" ]] || fail "${pkg}/debian/rules is not executable"

  if [[ -f "${control}" ]]; then
    check_control_field "${control}" Source
    check_control_field "${control}" Maintainer
    check_control_field "${control}" Build-Depends
    check_control_field "${control}" Package
    check_control_field "${control}" Architecture
    check_control_field "${control}" Description
  fi

  if [[ -f "${changelog}" ]] && ! grep -Eq "^${pkg} \\([^)]+\\) trixie;" "${changelog}"; then
    fail "${pkg}/debian/changelog has unexpected header"
  fi
}

check_aptura_desktop_feature() {
  local feature="$1"
  local install="${ROOT_DIR}/packages/aptura-desktop/debian/install"
  local icon_name="${2:-}"

  if [[ -f "${ROOT_DIR}/packages/aptura-desktop/usr/bin/${feature}" ]]; then
    ok "${feature} script exists"
  else
    fail "Missing aptura-desktop/usr/bin/${feature}"
  fi

  if [[ -f "${ROOT_DIR}/packages/aptura-desktop/usr/share/applications/${feature}.desktop" ]]; then
    ok "${feature}.desktop exists"
  else
    fail "Missing aptura-desktop/usr/share/applications/${feature}.desktop"
  fi

  if grep -Eq "usr/bin/${feature}[[:space:]]+usr/bin/" "${install}"; then
    ok "${feature} is installed"
  else
    fail "aptura-desktop/debian/install does not install ${feature}"
  fi

  if [[ -n "${icon_name}" ]]; then
    if [[ -f "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/Aptura-Shell/scalable/apps/${icon_name}.svg" ]]; then
      ok "${icon_name} Aptura-Shell icon exists"
    else
      fail "Missing Aptura-Shell icon: ${icon_name}.svg"
    fi

    if [[ -f "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/hicolor/scalable/apps/${icon_name}.svg" ]]; then
      ok "${icon_name} hicolor icon exists"
    else
      fail "Missing hicolor icon: ${icon_name}.svg"
    fi
  fi
}

check_documented_feature() {
  local feature="$1"
  local doc="${ROOT_DIR}/packages/aptura-desktop/usr/share/aptura-desktop/README.md"

  if grep -Eq "${feature}" "${doc}"; then
    ok "${feature} documented in aptura-desktop README"
  else
    fail "${feature} missing from aptura-desktop README"
  fi
}

main() {
  check_package aptura-meta
  check_package aptura-branding
  check_package aptura-desktop
  check_package aptura-settings

  local desktop_control="${ROOT_DIR}/packages/aptura-desktop/debian/control"
  local meta_control="${ROOT_DIR}/packages/aptura-meta/debian/control"
  local shell_dep
  for shell_dep in labwc waybar wofi swaybg mako-notifier foot grim slurp swaylock wl-clipboard libnotify-bin xdg-desktop-portal-wlr polkit-kde-agent-1; do
    check_live_package_list_contains "${shell_dep}"
    check_control_depends "${desktop_control}" "${shell_dep}"
    check_control_depends "${meta_control}" "${shell_dep}"
  done

  local plasma_dep
  for plasma_dep in kde-plasma-desktop plasma-workspace sddm systemsettings dolphin konsole kate ark kde-spectacle plasma-discover xdg-desktop-portal-kde; do
    check_live_package_list_contains "${plasma_dep}"
    check_control_depends "${desktop_control}" "${plasma_dep}"
    check_control_depends "${meta_control}" "${plasma_dep}"
  done

  local boot_dep
  for boot_dep in cryptsetup cryptsetup-initramfs grub-common grub2-common grub-pc-bin grub-efi-amd64-bin efibootmgr; do
    check_live_package_list_contains "${boot_dep}"
    check_control_depends "${meta_control}" "${boot_dep}"
  done

  local removed_desktop_dep
  for removed_desktop_dep in spectacle cosmic-session cosmic-greeter cosmic-greeter-daemon cosmic-comp cosmic-panel cosmic-app-library cosmic-icons cosmic-settings cosmic-files cosmic-term cosmic-edit xdg-desktop-portal-cosmic greetd; do
    check_live_package_list_not_contains "${removed_desktop_dep}"
    check_control_not_depends "${desktop_control}" "${removed_desktop_dep}"
    check_control_not_depends "${meta_control}" "${removed_desktop_dep}"
  done

  for shell_feature in aptura-session aptura-panel aptura-launcher aptura-control aptura-screenshot; do
    if [[ -f "${ROOT_DIR}/packages/aptura-desktop/usr/bin/${shell_feature}" ]]; then
      ok "${shell_feature} script exists"
    else
      fail "Missing aptura-desktop/usr/bin/${shell_feature}"
    fi

    if grep -Eq "usr/bin/${shell_feature}[[:space:]]+usr/bin/" "${ROOT_DIR}/packages/aptura-desktop/debian/install"; then
      ok "${shell_feature} is installed"
    else
      fail "aptura-desktop/debian/install does not install ${shell_feature}"
    fi
  done

  if [[ -f "${ROOT_DIR}/packages/aptura-desktop/usr/share/wayland-sessions/aptura.desktop" ]]; then
    ok "Aptura Shell session file exists"
  else
    fail "Missing Aptura Shell wayland session file"
  fi

  if grep -Eq 'usr/share/wayland-sessions/aptura.desktop[[:space:]]+usr/share/wayland-sessions/' "${ROOT_DIR}/packages/aptura-desktop/debian/install"; then
    ok "Aptura Shell session file is installed"
  else
    fail "aptura-desktop/debian/install does not install Aptura Shell session file"
  fi

  if [[ -f "${ROOT_DIR}/packages/aptura-desktop/usr/share/aptura-shell/xdg/labwc/rc.xml" ]]; then
    ok "Aptura Shell labwc configuration exists"
  else
    fail "Missing Aptura Shell labwc configuration"
  fi

  check_documented_feature "Aptura Shell"

  check_aptura_desktop_feature aptura-safe-update
  check_aptura_desktop_feature aptura-rescue-center
  check_aptura_desktop_feature aptura-privacy-check
  check_aptura_desktop_feature aptura-mode
  check_aptura_desktop_feature aptura-support-bundle
  check_aptura_desktop_feature aptura-journey aptura-journey
  check_aptura_desktop_feature aptura-context aptura-context
  check_aptura_desktop_feature aptura-shift aptura-shift
  check_aptura_desktop_feature aptura-aftercare aptura-aftercare
  check_aptura_desktop_feature aptura-live-bridge aptura-live-bridge
  check_documented_feature aptura-journey
  check_documented_feature aptura-context
  check_documented_feature aptura-shift
  check_documented_feature aptura-aftercare
  check_documented_feature aptura-live-bridge

  if [[ -f "${ROOT_DIR}/packages/aptura-branding/usr/share/backgrounds/aptura/aptura-context-grid.svg" ]]; then
    ok "aptura-context-grid wallpaper exists"
  else
    fail "Missing aptura-context-grid wallpaper"
  fi

  if [[ -f "${ROOT_DIR}/packages/aptura-settings/etc/skel/.config/gtk-3.0/settings.ini" ]]; then
    ok "GTK 3 skeleton settings exist"
  else
    fail "Missing GTK 3 skeleton settings"
  fi

  if [[ -f "${ROOT_DIR}/packages/aptura-settings/etc/skel/.config/gtk-4.0/settings.ini" ]]; then
    ok "GTK 4 skeleton settings exist"
  else
    fail "Missing GTK 4 skeleton settings"
  fi

  if [[ "${errors}" -gt 0 ]]; then
    printf '[FAIL] Package test finished with %d error(s)\n' "${errors}" >&2
    exit 1
  fi

  printf '[OK] Package metadata test passed\n'
}

main "$@"
