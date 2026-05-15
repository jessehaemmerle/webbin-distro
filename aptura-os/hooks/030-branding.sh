#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[030-branding] %s\n' "$*"
}

load_branding() {
  if [[ -r /etc/aptura/branding.conf ]]; then
    # shellcheck source=/dev/null
    source /etc/aptura/branding.conf
  fi

  : "${ID:=aptura}"
  : "${NAME:=Aptura OS}"
  : "${SHORT_NAME:=Aptura}"
  : "${PRETTY_NAME:=Aptura OS}"
  : "${VERSION_ID:=0.1.4}"
  : "${VERSION:=${VERSION_ID}}"
  : "${VERSION_CODENAME:=adeline}"
  : "${ID_LIKE:=debian}"
  : "${VARIANT:=Shell}"
  : "${VARIANT_ID:=aptura-shell}"
  : "${LOGO_NAME:=distributor-logo-aptura}"
  : "${ANSI_COLOR:=1;36}"
  : "${HOME_URL:=https://aptura.local}"
  : "${SUPPORT_URL:=${HOME_URL}/support}"
  : "${BUG_REPORT_URL:=${HOME_URL}/issues}"
  : "${PRIVACY_POLICY_URL:=${HOME_URL}/privacy}"
  : "${DESKTOP_NAME:=Aptura Shell}"
  : "${THEME_NAME:=Aptura-Shell}"
  : "${GTK_THEME_NAME:=${THEME_NAME}}"
  : "${ICON_THEME_NAME:=Aptura-Shell}"
  : "${ACCENT_COLOR:=#00d9c0}"
  : "${SECONDARY_ACCENT_COLOR:=#ff4fd8}"
  : "${WARNING_COLOR:=#ffe45c}"
  : "${SURFACE_COLOR:=#c8c6bc}"
  : "${DEFAULT_WALLPAPER:=/usr/share/backgrounds/aptura/aptura-context-grid.svg}"
  : "${WALLPAPER_ALTERNATIVES:=}"
  : "${PLYMOUTH_THEME:=aptura}"
  : "${LOGIN_THEME:=aptura}"
  : "${DEFAULT_MODE:=aptura-shell}"
  : "${USER_ICON:=/usr/share/pixmaps/aptura.svg}"
  : "${MOTD_DESCRIPTION:=Debian-compatible workstation with ${DESKTOP_NAME}, branding, defaults, and tooling.}"
}

escape_double() {
  local value="${1-}"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  printf '%s' "${value}"
}

write_var() {
  printf '%s="%s"\n' "$1" "$(escape_double "$2")"
}

install_wallpaper_alternative() {
  local wallpaper="$1"
  local priority="$2"
  [[ -n "${wallpaper}" && -f "${wallpaper}" ]] || return 0

  update-alternatives \
    --install /usr/share/images/desktop-base/desktop-background \
    desktop-background \
    "${wallpaper}" \
    "${priority}" || true
}

load_branding
log "Applying ${NAME} branding"

{
  write_var PRETTY_NAME "${PRETTY_NAME}"
  write_var NAME "${NAME}"
  write_var VERSION_ID "${VERSION_ID}"
  write_var VERSION "${VERSION}"
  write_var VERSION_CODENAME "${VERSION_CODENAME}"
  write_var ID "${ID}"
  write_var ID_LIKE "${ID_LIKE}"
  write_var VARIANT "${VARIANT}"
  write_var VARIANT_ID "${VARIANT_ID}"
  write_var LOGO "${LOGO_NAME}"
  write_var ANSI_COLOR "${ANSI_COLOR}"
  write_var HOME_URL "${HOME_URL}"
  write_var SUPPORT_URL "${SUPPORT_URL}"
  write_var BUG_REPORT_URL "${BUG_REPORT_URL}"
  write_var PRIVACY_POLICY_URL "${PRIVACY_POLICY_URL}"
} > /etc/os-release

{
  printf 'DISTRIB_ID=%s\n' "${SHORT_NAME}"
  printf 'DISTRIB_RELEASE=%s\n' "${VERSION_ID}"
  printf 'DISTRIB_CODENAME=%s\n' "${VERSION_CODENAME}"
  printf 'DISTRIB_DESCRIPTION="%s"\n' "$(escape_double "${PRETTY_NAME}")"
} > /etc/lsb-release

printf '%s \\n \\l\n' "${PRETTY_NAME}" > /etc/issue
printf '%s\n' "${PRETTY_NAME}" > /etc/issue.net

{
  write_var PRETTY_HOSTNAME "${NAME}"
  write_var ICON_NAME "${LOGO_NAME}"
  printf 'CHASSIS=desktop\n'
} > /etc/machine-info

install -d -m 0755 /etc/motd.d /etc/profile.d
{
  printf '%s\n' "${PRETTY_NAME}"
  printf '%s\n' "${MOTD_DESCRIPTION}"
} > /etc/motd.d/00-aptura

{
  write_var APTURA_BRAND_ID "${ID}"
  write_var APTURA_BRAND_NAME "${NAME}"
  write_var APTURA_BRAND_SHORT_NAME "${SHORT_NAME}"
  write_var APTURA_BRAND_EDITION "${VARIANT}"
  write_var APTURA_BRAND_ACCENT "${ACCENT_COLOR}"
  write_var APTURA_BRAND_WALLPAPER "${DEFAULT_WALLPAPER}"
  write_var APTURA_BRAND_ICON_THEME "${ICON_THEME_NAME}"
} | sed 's/^/export /' > /etc/profile.d/aptura-branding.sh

if command -v update-alternatives >/dev/null 2>&1; then
  priority=95
  install_wallpaper_alternative "${DEFAULT_WALLPAPER}" "${priority}"
  for wallpaper in ${WALLPAPER_ALTERNATIVES//,/ }; do
    priority=$((priority - 5))
    install_wallpaper_alternative "${wallpaper}" "${priority}"
  done
fi

if command -v plymouth-set-default-theme >/dev/null 2>&1 && [[ -d "/usr/share/plymouth/themes/${PLYMOUTH_THEME}" ]]; then
  plymouth-set-default-theme "${PLYMOUTH_THEME}" || true
fi

log "Branding complete"
