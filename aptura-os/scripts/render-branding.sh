#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

load_config() {
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
}

derive_branding() {
  : "${ID:=${DISTRO_ID}}"
  : "${NAME:=${DISTRO_NAME}}"
  : "${SHORT_NAME:=${NAME%% *}}"
  : "${PRETTY_NAME:=${DISTRO_PRETTY_NAME:-${NAME} ${DISTRO_VERSION}}}"
  : "${VERSION_ID:=${DISTRO_VERSION}}"
  : "${VERSION_CODENAME:=${DISTRO_CODENAME}}"
  : "${VERSION:=${VERSION_ID} (${DESKTOP_NAME})}"
  : "${VARIANT:=${DESKTOP_NAME}}"
  : "${VARIANT_ID:=${ID}-shell}"
  : "${ID_LIKE:=debian}"
  : "${ANSI_COLOR:=1;36}"

  : "${HOME_URL:=https://${ID}.local}"
  : "${SUPPORT_URL:=${HOME_URL}/support}"
  : "${BUG_REPORT_URL:=${HOME_URL}/issues}"
  : "${PRIVACY_POLICY_URL:=${HOME_URL}/privacy}"
  : "${RELEASE_NOTES_URL:=${HOME_URL}/releases}"

  : "${BRAND_SHARE_NAME:=${ID}}"
  : "${BRANDING_ASSET_DIR:=/usr/share/${BRAND_SHARE_NAME}/branding}"
  : "${LOGO:=distributor-logo-${ID}}"
  : "${LOGO_NAME:=${LOGO}}"
  : "${APP_ICON_NAME:=${ID}}"
  : "${APP_ICON:=/usr/share/icons/hicolor/scalable/apps/${APP_ICON_NAME}.svg}"
  : "${USER_ICON:=/usr/share/pixmaps/${ID}.svg}"
  : "${LOGO_ASSET:=${BRANDING_ASSET_DIR}/${ID}-logo.svg}"
  : "${WORDMARK_ASSET:=${BRANDING_ASSET_DIR}/${ID}-wordmark.svg}"
  : "${BADGE_ASSET:=${BRANDING_ASSET_DIR}/${ID}-badge.svg}"

  : "${WALLPAPER_DIR:=/usr/share/backgrounds/${ID}}"
  : "${DEFAULT_WALLPAPER:=${WALLPAPER_DIR}/${ID}-default.svg}"
  : "${WALLPAPER:=${DEFAULT_WALLPAPER}}"
  : "${WALLPAPER_ALTERNATIVES:=}"

  : "${PLYMOUTH_THEME:=${ID}}"
  : "${LOGIN_THEME:=${ID}}"
  : "${THEME_NAME:=${SHORT_NAME}-Shell}"
  : "${GTK_THEME_NAME:=${THEME_NAME}}"
  : "${ICON_THEME_NAME:=${THEME_NAME}}"
  : "${CURSOR_THEME_NAME:=Adwaita}"
  : "${CURSOR_SIZE:=24}"

  : "${SHELL_SESSION_ID:=${ID}}"
  : "${SHELL_SESSION_NAME:=${DESKTOP_NAME}}"
  : "${XDG_CURRENT_DESKTOP_NAME:=${SHORT_NAME}}"
  : "${XDG_MENU_PREFIX:=${SHELL_SESSION_ID}-}"
  : "${PANEL_TITLE:=${SHORT_NAME}}"
  : "${LIVE_USERNAME:=${ID}}"
  : "${LIVE_HOSTNAME:=${ID}-live}"
  : "${DEFAULT_MODE:=${VARIANT_ID}}"

  : "${ACCENT_COLOR:=#00d9c0}"
  : "${SECONDARY_ACCENT_COLOR:=#ff4fd8}"
  : "${WARNING_COLOR:=#ffe45c}"
  : "${ERROR_COLOR:=#ff4f6d}"
  : "${SURFACE_COLOR:=#c8c6bc}"
  : "${SURFACE_DARK_COLOR:=#12142b}"
  : "${SIDEBAR_BACKGROUND_COLOR:=#11142b}"
  : "${SIDEBAR_TEXT_COLOR:=#f4f0df}"
  : "${TEXT_COLOR:=#101318}"
  : "${LIGHT_COLOR:=#f4f0df}"
  : "${MID_COLOR:=#7b7c82}"
  : "${WINDOW_COLOR:=#fffaf0}"

  : "${MOTD_DESCRIPTION:=Debian-compatible workstation with ${SHELL_SESSION_NAME}, branding, defaults, and tooling.}"
  : "${ABOUT_DESCRIPTION:=A Debian-compatible desktop distribution with ${SHELL_SESSION_NAME}, Wayland defaults, practical tooling, and a Plasma fallback session.}"
  : "${CALAMARES_HEADER_TEXT:=${SHELL_SESSION_NAME} Installer}"
  : "${CALAMARES_WELCOME_TITLE:=Install ${NAME}}"
  : "${CALAMARES_WELCOME_SUBTITLE:=${SHELL_SESSION_NAME} workstation}"
  : "${CALAMARES_WELCOME_DESCRIPTION:=${SHELL_SESSION_NAME}, Wayland defaults, local tools}"
  : "${CALAMARES_WELCOME_FOOTER:=${SHELL_SESSION_NAME}: logo, boot, greeter, installer, icons, colors, and wallpaper}"
  : "${CALAMARES_ACTION_LABEL:=Continue}"
  : "${CALAMARES_LOGO_INITIAL:=${SHORT_NAME:0:1}}"
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

yaml_string() {
  printf '"%s"' "$(escape_double "$1")"
}

xml_text() {
  local value="${1-}"
  value="${value//&/&amp;}"
  value="${value//</&lt;}"
  value="${value//>/&gt;}"
  value="${value//\"/&quot;}"
  printf '%s' "${value}"
}

ensure_dirs() {
  mkdir -p \
    "${ROOT_DIR}/packages/aptura-branding/etc/aptura" \
    "${ROOT_DIR}/packages/aptura-branding/etc/default/grub.d" \
    "${ROOT_DIR}/packages/aptura-branding/etc/motd.d" \
    "${ROOT_DIR}/packages/aptura-branding/etc/profile.d" \
    "${ROOT_DIR}/packages/aptura-branding/usr/lib/os-release.d" \
    "${ROOT_DIR}/packages/aptura-branding/usr/share/${BRAND_SHARE_NAME}/branding" \
    "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/${ICON_THEME_NAME}/scalable/apps" \
    "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/${ICON_THEME_NAME}/scalable/places" \
    "${ROOT_DIR}/packages/aptura-branding/usr/share/icons/${ICON_THEME_NAME}/scalable/devices" \
    "${ROOT_DIR}/packages/aptura-branding/usr/share/themes/${THEME_NAME}" \
    "${ROOT_DIR}/packages/aptura-settings/etc/skel/.config/gtk-3.0" \
    "${ROOT_DIR}/packages/aptura-settings/etc/skel/.config/gtk-4.0" \
    "${ROOT_DIR}/packages/aptura-desktop/usr/share/wayland-sessions"
}

write_branding_conf() {
  local target="${ROOT_DIR}/packages/aptura-branding/etc/aptura/branding.conf"
  {
    printf '# Generated by scripts/render-branding.sh from config/distro.env and config/branding.conf.\n'
    write_var ID "${ID}"
    write_var NAME "${NAME}"
    write_var SHORT_NAME "${SHORT_NAME}"
    write_var PRETTY_NAME "${PRETTY_NAME}"
    write_var DISTRO_NAME "${NAME}"
    write_var DESKTOP_NAME "${DESKTOP_NAME}"
    write_var DISTRO_PRETTY_NAME "${PRETTY_NAME}"
    write_var DISTRO_VERSION "${VERSION_ID}"
    write_var DISTRO_CODENAME "${VERSION_CODENAME}"
    write_var VERSION_ID "${VERSION_ID}"
    write_var VERSION "${VERSION}"
    write_var VERSION_CODENAME "${VERSION_CODENAME}"
    write_var VARIANT "${VARIANT}"
    write_var VARIANT_ID "${VARIANT_ID}"
    write_var ID_LIKE "${ID_LIKE}"
    write_var ANSI_COLOR "${ANSI_COLOR}"
    write_var HOME_URL "${HOME_URL}"
    write_var SUPPORT_URL "${SUPPORT_URL}"
    write_var BUG_REPORT_URL "${BUG_REPORT_URL}"
    write_var PRIVACY_POLICY_URL "${PRIVACY_POLICY_URL}"
    write_var RELEASE_NOTES_URL "${RELEASE_NOTES_URL}"
    write_var BRAND_SHARE_NAME "${BRAND_SHARE_NAME}"
    write_var BRANDING_ASSET_DIR "${BRANDING_ASSET_DIR}"
    write_var LOGO "${LOGO_NAME}"
    write_var LOGO_NAME "${LOGO_NAME}"
    write_var APP_ICON_NAME "${APP_ICON_NAME}"
    write_var APP_ICON "${APP_ICON}"
    write_var USER_ICON "${USER_ICON}"
    write_var LOGO_ASSET "${LOGO_ASSET}"
    write_var WORDMARK_ASSET "${WORDMARK_ASSET}"
    write_var BADGE_ASSET "${BADGE_ASSET}"
    write_var WALLPAPER_DIR "${WALLPAPER_DIR}"
    write_var DEFAULT_WALLPAPER "${DEFAULT_WALLPAPER}"
    write_var WALLPAPER "${WALLPAPER}"
    write_var WALLPAPER_ALTERNATIVES "${WALLPAPER_ALTERNATIVES}"
    write_var PLYMOUTH_THEME "${PLYMOUTH_THEME}"
    write_var LOGIN_THEME "${LOGIN_THEME}"
    write_var THEME_NAME "${THEME_NAME}"
    write_var GTK_THEME_NAME "${GTK_THEME_NAME}"
    write_var ICON_THEME_NAME "${ICON_THEME_NAME}"
    write_var CURSOR_THEME_NAME "${CURSOR_THEME_NAME}"
    write_var CURSOR_SIZE "${CURSOR_SIZE}"
    write_var SHELL_SESSION_ID "${SHELL_SESSION_ID}"
    write_var SHELL_SESSION_NAME "${SHELL_SESSION_NAME}"
    write_var XDG_CURRENT_DESKTOP_NAME "${XDG_CURRENT_DESKTOP_NAME}"
    write_var XDG_MENU_PREFIX "${XDG_MENU_PREFIX}"
    write_var PANEL_TITLE "${PANEL_TITLE}"
    write_var LIVE_USERNAME "${LIVE_USERNAME}"
    write_var LIVE_HOSTNAME "${LIVE_HOSTNAME}"
    write_var DEFAULT_MODE "${DEFAULT_MODE}"
    write_var ACCENT_COLOR "${ACCENT_COLOR}"
    write_var SECONDARY_ACCENT_COLOR "${SECONDARY_ACCENT_COLOR}"
    write_var WARNING_COLOR "${WARNING_COLOR}"
    write_var ERROR_COLOR "${ERROR_COLOR}"
    write_var SURFACE_COLOR "${SURFACE_COLOR}"
    write_var SURFACE_DARK_COLOR "${SURFACE_DARK_COLOR}"
    write_var SIDEBAR_BACKGROUND_COLOR "${SIDEBAR_BACKGROUND_COLOR}"
    write_var SIDEBAR_TEXT_COLOR "${SIDEBAR_TEXT_COLOR}"
    write_var TEXT_COLOR "${TEXT_COLOR}"
    write_var LIGHT_COLOR "${LIGHT_COLOR}"
    write_var MID_COLOR "${MID_COLOR}"
    write_var WINDOW_COLOR "${WINDOW_COLOR}"
    write_var MOTD_DESCRIPTION "${MOTD_DESCRIPTION}"
    write_var ABOUT_DESCRIPTION "${ABOUT_DESCRIPTION}"
    write_var CALAMARES_HEADER_TEXT "${CALAMARES_HEADER_TEXT}"
    write_var CALAMARES_WELCOME_TITLE "${CALAMARES_WELCOME_TITLE}"
    write_var CALAMARES_WELCOME_SUBTITLE "${CALAMARES_WELCOME_SUBTITLE}"
    write_var CALAMARES_WELCOME_DESCRIPTION "${CALAMARES_WELCOME_DESCRIPTION}"
    write_var CALAMARES_WELCOME_FOOTER "${CALAMARES_WELCOME_FOOTER}"
    write_var CALAMARES_ACTION_LABEL "${CALAMARES_ACTION_LABEL}"
    write_var CALAMARES_LOGO_INITIAL "${CALAMARES_LOGO_INITIAL}"
    write_var BASE_FAMILY "${BASE_FAMILY}"
    write_var BASE_DISTRIBUTION "${BASE_DISTRIBUTION}"
    write_var BASE_SUITE "${BASE_SUITE}"
  } > "${target}"
}

write_os_release_fragment() {
  local target="${ROOT_DIR}/packages/aptura-branding/usr/lib/os-release.d/aptura-os-release"
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
  } > "${target}"
}

write_system_identity_files() {
  {
    write_var PRETTY_HOSTNAME "${NAME}"
    write_var ICON_NAME "${LOGO_NAME}"
    printf 'CHASSIS=desktop\n'
  } > "${ROOT_DIR}/packages/aptura-branding/etc/machine-info"

  {
    printf '%s\n' "${PRETTY_NAME}"
    printf '%s\n' "${MOTD_DESCRIPTION}"
  } > "${ROOT_DIR}/packages/aptura-branding/etc/motd.d/00-aptura"

  {
    write_var APTURA_BRAND_ID "${ID}"
    write_var APTURA_BRAND_NAME "${NAME}"
    write_var APTURA_BRAND_SHORT_NAME "${SHORT_NAME}"
    write_var APTURA_BRAND_EDITION "${VARIANT}"
    write_var APTURA_BRAND_ACCENT "${ACCENT_COLOR}"
    write_var APTURA_BRAND_WALLPAPER "${DEFAULT_WALLPAPER}"
    write_var APTURA_BRAND_ICON_THEME "${ICON_THEME_NAME}"
  } | sed 's/^/export /' > "${ROOT_DIR}/packages/aptura-branding/etc/profile.d/aptura-branding.sh"
}

write_grub_defaults() {
  local target="${ROOT_DIR}/packages/aptura-branding/etc/default/grub.d/aptura.cfg"
  {
    printf '# Generated branding defaults. The EFI directory remains "debian" for compatibility\n'
    printf '# with Debian GRUB EFI binaries; these values brand the generated menu.\n'
    write_var GRUB_DISTRIBUTOR "${NAME}"
    printf 'GRUB_TIMEOUT_STYLE=menu\n'
    printf 'GRUB_TIMEOUT=5\n'
    printf 'GRUB_GFXMODE=auto\n'
    printf 'GRUB_TERMINAL_OUTPUT=gfxterm\n'
    printf 'GRUB_DISABLE_OS_PROBER=false\n'
    write_var GRUB_COLOR_NORMAL "light-gray/black"
    write_var GRUB_COLOR_HIGHLIGHT "light-cyan/black"
  } > "${target}"
}

write_branding_install() {
  local target="${ROOT_DIR}/packages/aptura-branding/debian/install"
  {
    printf 'etc/aptura/branding.conf etc/aptura/\n'
    printf 'etc/default/grub.d/aptura.cfg etc/default/grub.d/\n'
    printf 'etc/machine-info etc/\n'
    printf 'etc/motd.d/00-aptura etc/motd.d/\n'
    printf 'etc/profile.d/aptura-branding.sh etc/profile.d/\n'
    printf 'usr/lib/os-release.d/aptura-os-release usr/lib/os-release.d/\n'
    printf 'usr/share/backgrounds/* usr/share/backgrounds/\n'
    printf 'usr/share/%s usr/share/\n' "${BRAND_SHARE_NAME}"
    printf 'usr/share/icons/* usr/share/icons/\n'
    printf 'usr/share/pixmaps/*.svg usr/share/pixmaps/\n'
    printf 'usr/share/themes/* usr/share/themes/\n'
    printf 'usr/share/plymouth/themes/* usr/share/plymouth/themes/\n'
  } > "${target}"
}

write_icon_theme_index() {
  local target="${ROOT_DIR}/packages/aptura-branding/usr/share/icons/${ICON_THEME_NAME}/index.theme"
  {
    printf '[Icon Theme]\n'
    printf 'Name=%s\n' "${ICON_THEME_NAME}"
    printf 'Comment=%s icons for %s\n' "${SHORT_NAME}" "${VARIANT}"
    printf 'Inherits=hicolor,Adwaita\n'
    printf 'Directories=scalable/apps,scalable/places,scalable/devices\n\n'
    printf '[scalable/apps]\n'
    printf 'Size=48\nType=Scalable\nMinSize=16\nMaxSize=256\nContext=Applications\n\n'
    printf '[scalable/places]\n'
    printf 'Size=48\nType=Scalable\nMinSize=16\nMaxSize=256\nContext=Places\n\n'
    printf '[scalable/devices]\n'
    printf 'Size=48\nType=Scalable\nMinSize=16\nMaxSize=256\nContext=Devices\n'
  } > "${target}"
}

write_theme_index() {
  local target="${ROOT_DIR}/packages/aptura-branding/usr/share/themes/${THEME_NAME}/index.theme"
  {
    printf '[Desktop Entry]\n'
    printf 'Name=%s\n' "${THEME_NAME}"
    printf 'Comment=%s desktop theme for %s\n' "${SHORT_NAME}" "${VARIANT}"
  } > "${target}"
}

replace_define_color() {
  local file="$1"
  local name="$2"
  local color="$3"
  local tmp
  [[ -f "${file}" ]] || return 0
  tmp="$(mktemp)"
  sed -E "s|^@define-color ${name} .*|@define-color ${name} ${color};|" "${file}" > "${tmp}"
  mv -- "${tmp}" "${file}"
}

sync_gtk_theme_colors() {
  local css="${ROOT_DIR}/packages/aptura-branding/usr/share/themes/${THEME_NAME}/gtk-3.0/gtk.css"
  replace_define_color "${css}" aptura_teal "${ACCENT_COLOR}"
  replace_define_color "${css}" aptura_magenta "${SECONDARY_ACCENT_COLOR}"
  replace_define_color "${css}" aptura_title "${SURFACE_DARK_COLOR}"
  replace_define_color "${css}" aptura_title_inactive "${MID_COLOR}"
  replace_define_color "${css}" aptura_face "${SURFACE_COLOR}"
  replace_define_color "${css}" aptura_light "${LIGHT_COLOR}"
  replace_define_color "${css}" aptura_mid "${MID_COLOR}"
  replace_define_color "${css}" aptura_text "${TEXT_COLOR}"
  replace_define_color "${css}" aptura_window "${WINDOW_COLOR}"
  replace_define_color "${css}" aptura_warning "${WARNING_COLOR}"
}

write_gtk_skeletons() {
  local target
  for target in \
    "${ROOT_DIR}/packages/aptura-settings/etc/skel/.config/gtk-3.0/settings.ini" \
    "${ROOT_DIR}/packages/aptura-settings/etc/skel/.config/gtk-4.0/settings.ini"; do
    {
      printf '[Settings]\n'
      printf 'gtk-theme-name=%s\n' "${GTK_THEME_NAME}"
      printf 'gtk-icon-theme-name=%s\n' "${ICON_THEME_NAME}"
      printf 'gtk-application-prefer-dark-theme=1\n'
      printf 'gtk-cursor-theme-name=%s\n' "${CURSOR_THEME_NAME}"
    } > "${target}"
  done
}

write_desktop_session() {
  local target="${ROOT_DIR}/packages/aptura-desktop/usr/share/wayland-sessions/${SHELL_SESSION_ID}.desktop"
  {
    printf '[Desktop Entry]\n'
    printf 'Name=%s\n' "${SHELL_SESSION_NAME}"
    printf "Comment=%s's Wayland desktop session\n" "${SHORT_NAME}"
    printf 'Exec=aptura-session\n'
    printf 'Type=Application\n'
    printf 'DesktopNames=%s\n' "${XDG_CURRENT_DESKTOP_NAME}"
  } > "${target}"
}

write_waybar_style() {
  local target="${ROOT_DIR}/packages/aptura-desktop/usr/share/aptura-shell/waybar/style.css"
  {
    printf '* {\n'
    printf '  border: none;\n'
    printf '  border-radius: 0;\n'
    printf '  font-family: "Noto Sans", "Cantarell", sans-serif;\n'
    printf '  font-size: 12px;\n'
    printf '  min-height: 0;\n'
    printf '}\n\n'
    printf 'window#waybar {\n'
    printf '  background: %s;\n' "${SURFACE_DARK_COLOR}"
    printf '  border-bottom: 1px solid %s;\n' "${ACCENT_COLOR}"
    printf '  color: #f6f7fb;\n'
    printf '}\n\n'
    printf '#custom-launcher {\n'
    printf '  background: %s;\n' "${ACCENT_COLOR}"
    printf '  color: %s;\n' "${SURFACE_DARK_COLOR}"
    printf '  font-weight: 700;\n'
    printf '  padding: 0 16px;\n'
    printf '}\n\n'
    printf '#taskbar button {\n'
    printf '  background: transparent;\n'
    printf '  color: #f6f7fb;\n'
    printf '  margin: 3px 2px;\n'
    printf '  padding: 0 8px;\n'
    printf '}\n\n'
    printf '#taskbar button.active {\n'
    printf '  background: rgba(255, 255, 255, 0.14);\n'
    printf '}\n\n'
    printf '#clock {\n'
    printf '  color: %s;\n' "${WARNING_COLOR}"
    printf '  font-weight: 700;\n'
    printf '  padding: 0 12px;\n'
    printf '}\n\n'
    printf '#idle_inhibitor,\n#network,\n#pulseaudio,\n#battery,\n#tray,\n#custom-power {\n'
    printf '  background: rgba(255, 255, 255, 0.08);\n'
    printf '  color: #f6f7fb;\n'
    printf '  margin: 4px 3px;\n'
    printf '  padding: 0 10px;\n'
    printf '}\n\n'
    printf '#battery.warning {\n'
    printf '  color: %s;\n' "${WARNING_COLOR}"
    printf '}\n\n'
    printf '#battery.critical {\n'
    printf '  background: %s;\n' "${ERROR_COLOR}"
    printf '  color: #ffffff;\n'
    printf '}\n\n'
    printf '#custom-power {\n'
    printf '  background: %s;\n' "${SECONDARY_ACCENT_COLOR}"
    printf '  color: #ffffff;\n'
    printf '}\n'
  } > "${target}"
}

write_wofi_config() {
  local target="${ROOT_DIR}/packages/aptura-desktop/usr/share/aptura-shell/wofi/config"
  {
    printf 'allow_images=true\n'
    printf 'insensitive=true\n'
    printf 'matching=fuzzy\n'
    printf 'show=drun\n'
    printf 'width=560\n'
    printf 'height=440\n'
    printf 'location=center\n'
    printf 'prompt=%s\n' "${PANEL_TITLE}"
    printf 'term=foot\n'
  } > "${target}"
}

write_labwc_config() {
  local environment="${ROOT_DIR}/packages/aptura-desktop/usr/share/aptura-shell/xdg/labwc/environment"
  local menu="${ROOT_DIR}/packages/aptura-desktop/usr/share/aptura-shell/xdg/labwc/menu.xml"
  local rc="${ROOT_DIR}/packages/aptura-desktop/usr/share/aptura-shell/xdg/labwc/rc.xml"
  local tmp theme_name

  {
    printf 'XDG_CURRENT_DESKTOP=%s\n' "${XDG_CURRENT_DESKTOP_NAME}"
    printf 'XDG_SESSION_DESKTOP=%s\n' "${SHELL_SESSION_ID}"
    printf 'DESKTOP_SESSION=%s\n' "${SHELL_SESSION_ID}"
    printf 'XDG_MENU_PREFIX=%s\n' "${XDG_MENU_PREFIX}"
    printf 'GTK_THEME=%s\n' "${GTK_THEME_NAME}"
  } > "${environment}"

  {
    printf '<?xml version="1.0" encoding="UTF-8"?>\n'
    printf '<openbox_menu>\n'
    printf '  <menu id="root-menu" label="%s">\n' "$(xml_text "${PANEL_TITLE}")"
    printf '    <item label="Launcher" icon="%s">\n' "${APP_ICON_NAME}"
    printf '      <action name="Execute" command="aptura-launcher" />\n'
    printf '    </item>\n'
    printf '    <item label="Terminal" icon="utilities-terminal">\n'
    printf '      <action name="Execute" command="aptura-control terminal" />\n'
    printf '    </item>\n'
    printf '    <item label="Files" icon="system-file-manager">\n'
    printf '      <action name="Execute" command="dolphin" />\n'
    printf '    </item>\n'
    printf '    <item label="Settings" icon="preferences-system">\n'
    printf '      <action name="Execute" command="systemsettings" />\n'
    printf '    </item>\n'
    printf '    <separator />\n'
    printf '    <item label="Power" icon="system-shutdown">\n'
    printf '      <action name="Execute" command="aptura-control power" />\n'
    printf '    </item>\n'
    printf '  </menu>\n'
    printf '</openbox_menu>\n'
  } > "${menu}"

  if [[ -f "${rc}" ]]; then
    theme_name="$(xml_text "${THEME_NAME}")"
    tmp="$(mktemp)"
    awk -v theme_name="${theme_name}" '
      /<theme>/ {
        in_theme = 1
      }
      in_theme && !updated && /<name>.*<\/name>/ {
        sub(/<name>.*<\/name>/, "<name>" theme_name "</name>")
        updated = 1
      }
      {
        print
      }
      /<\/theme>/ {
        in_theme = 0
      }
    ' "${rc}" > "${tmp}"
    mv -- "${tmp}" "${rc}"
  fi
}

copy_calamares_branding_assets() {
  local default_dir="${ROOT_DIR}/installer/calamares/branding/aptura"
  local brand_dir="${ROOT_DIR}/installer/calamares/branding/${LOGIN_THEME}"
  local asset

  mkdir -p "${brand_dir}"
  for asset in show.qml; do
    if [[ ! -e "${brand_dir}/${asset}" && -e "${default_dir}/${asset}" ]]; then
      cp -- "${default_dir}/${asset}" "${brand_dir}/${asset}"
    fi
  done
}

write_calamares_logo() {
  local brand_dir="$1"
  local initial
  initial="$(xml_text "${CALAMARES_LOGO_INITIAL}")"

  cat > "${brand_dir}/logo.svg" <<EOF
<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 128 128" role="img" aria-label="$(xml_text "${NAME}") installer logo">
  <rect x="8" y="8" width="112" height="112" fill="${SURFACE_COLOR}" stroke="#05070a" stroke-width="4"/>
  <path d="M12 12H116V116" fill="none" stroke="${LIGHT_COLOR}" stroke-width="4"/>
  <path d="M120 12V120H12" fill="none" stroke="#686a72" stroke-width="4"/>
  <rect x="18" y="18" width="92" height="18" fill="${SIDEBAR_BACKGROUND_COLOR}" stroke="#05070a" stroke-width="3"/>
  <path d="M23 23H105" stroke="${SIDEBAR_TEXT_COLOR}" stroke-width="2"/>
  <g fill="${SURFACE_COLOR}" stroke="#05070a" stroke-width="2">
    <rect x="82" y="22" width="9" height="9"/>
    <rect x="95" y="22" width="9" height="9"/>
  </g>
  <rect x="18" y="40" width="92" height="70" fill="${TEXT_COLOR}" stroke="#05070a" stroke-width="3"/>
  <path d="M64 46L98 75L64 106L30 75Z" fill="none" stroke="${ACCENT_COLOR}" stroke-width="5"/>
  <text x="64" y="91" text-anchor="middle" fill="${LIGHT_COLOR}" stroke="#05070a" stroke-width="2" paint-order="stroke" font-family="Arial, Helvetica, sans-serif" font-size="54" font-weight="700">${initial}</text>
  <path d="M28 114H102" stroke="${SECONDARY_ACCENT_COLOR}" stroke-width="5"/>
</svg>
EOF
}

write_calamares_welcome() {
  local brand_dir="$1"
  local header title subtitle description footer action initial
  header="$(xml_text "${CALAMARES_HEADER_TEXT}")"
  title="$(xml_text "${CALAMARES_WELCOME_TITLE}")"
  subtitle="$(xml_text "${CALAMARES_WELCOME_SUBTITLE}")"
  description="$(xml_text "${CALAMARES_WELCOME_DESCRIPTION}")"
  footer="$(xml_text "${CALAMARES_WELCOME_FOOTER}")"
  action="$(xml_text "${CALAMARES_ACTION_LABEL}")"
  initial="$(xml_text "${CALAMARES_LOGO_INITIAL}")"

  cat > "${brand_dir}/welcome.svg" <<EOF
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="800" viewBox="0 0 1200 800" role="img" aria-label="$(xml_text "${NAME}") installer welcome">
  <defs>
    <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="${SIDEBAR_BACKGROUND_COLOR}"/>
      <stop offset="0.48" stop-color="${SURFACE_DARK_COLOR}"/>
      <stop offset="1" stop-color="#0d1026"/>
    </linearGradient>
    <linearGradient id="sun" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="${WARNING_COLOR}"/>
      <stop offset="1" stop-color="${SECONDARY_ACCENT_COLOR}"/>
    </linearGradient>
    <pattern id="stars" width="90" height="90" patternUnits="userSpaceOnUse">
      <rect width="90" height="90" fill="none"/>
      <rect x="14" y="22" width="4" height="4" fill="${LIGHT_COLOR}"/>
      <rect x="68" y="14" width="3" height="3" fill="${ACCENT_COLOR}"/>
      <rect x="42" y="70" width="4" height="4" fill="${WARNING_COLOR}"/>
    </pattern>
    <clipPath id="sunClip">
      <circle cx="600" cy="295" r="118"/>
    </clipPath>
  </defs>

  <rect width="1200" height="800" fill="url(#sky)"/>
  <rect width="1200" height="800" fill="url(#stars)" opacity="0.55"/>

  <g clip-path="url(#sunClip)">
    <circle cx="600" cy="295" r="118" fill="url(#sun)"/>
    <g stroke="${SURFACE_DARK_COLOR}" stroke-width="12">
      <path d="M470 254H730"/>
      <path d="M462 293H738"/>
      <path d="M478 332H722"/>
      <path d="M520 371H680"/>
    </g>
  </g>

  <path d="M0 490L170 380L300 470L430 350L560 476L700 372L840 488L1000 344L1200 490V800H0Z" fill="#090b18"/>
  <path d="M0 525L130 452L260 530L384 438L520 542L660 442L790 526L934 430L1200 535V800H0Z" fill="${SURFACE_DARK_COLOR}"/>

  <g stroke="${ACCENT_COLOR}" stroke-width="2" opacity="0.8">
    <path d="M0 612H1200"/>
    <path d="M0 656H1200"/>
    <path d="M0 705H1200"/>
    <path d="M0 760H1200"/>
    <path d="M600 545L120 800"/>
    <path d="M600 545L300 800"/>
    <path d="M600 545L480 800"/>
    <path d="M600 545L720 800"/>
    <path d="M600 545L900 800"/>
    <path d="M600 545L1080 800"/>
  </g>

  <rect x="130" y="110" width="940" height="430" rx="0" fill="${SURFACE_COLOR}" stroke="#05070a" stroke-width="8"/>
  <path d="M140 120H1060V530" fill="none" stroke="${LIGHT_COLOR}" stroke-width="6"/>
  <path d="M1070 120V540H140" fill="none" stroke="#686a72" stroke-width="6"/>
  <rect x="156" y="142" width="888" height="66" fill="${SIDEBAR_BACKGROUND_COLOR}" stroke="#05070a" stroke-width="6"/>
  <text x="202" y="185" fill="${SIDEBAR_TEXT_COLOR}" font-family="Arial, Helvetica, sans-serif" font-size="32" font-weight="700">${header}</text>
  <g fill="${SURFACE_COLOR}" stroke="#05070a" stroke-width="4">
    <rect x="902" y="160" width="28" height="28"/>
    <rect x="944" y="160" width="28" height="28"/>
    <rect x="986" y="160" width="28" height="28"/>
  </g>

  <rect x="226" y="260" width="236" height="200" fill="${TEXT_COLOR}" stroke="#05070a" stroke-width="5"/>
  <path d="M344 296L422 428H383L366 390H323L306 428H266Z" fill="${LIGHT_COLOR}" stroke="#05070a" stroke-width="6" stroke-linejoin="round"/>
  <text x="344" y="381" text-anchor="middle" fill="${ACCENT_COLOR}" stroke="#05070a" stroke-width="3" paint-order="stroke" font-family="Arial, Helvetica, sans-serif" font-size="58" font-weight="700">${initial}</text>
  <rect x="318" y="378" width="54" height="18" fill="${WARNING_COLOR}" stroke="#05070a" stroke-width="5"/>
  <path d="M274 448H414" stroke="${SECONDARY_ACCENT_COLOR}" stroke-width="12"/>

  <text x="520" y="315" fill="#05070a" font-family="Arial, Helvetica, sans-serif" font-size="46" font-weight="700">${title}</text>
  <text x="520" y="375" fill="${TEXT_COLOR}" font-family="Courier New, monospace" font-size="28">${subtitle}</text>
  <text x="520" y="414" fill="${TEXT_COLOR}" font-family="Courier New, monospace" font-size="21">${description}</text>
  <rect x="520" y="442" width="300" height="58" fill="${ACCENT_COLOR}" stroke="#05070a" stroke-width="5"/>
  <path d="M530 452H810V490" fill="none" stroke="${LIGHT_COLOR}" stroke-width="4"/>
  <path d="M820 452V500H530" fill="none" stroke="#0d4f68" stroke-width="4"/>
  <text x="670" y="480" text-anchor="middle" fill="#05070a" font-family="Arial, Helvetica, sans-serif" font-size="25" font-weight="700">${action}</text>

  <rect y="710" width="1200" height="90" fill="${TEXT_COLOR}" stroke="${ACCENT_COLOR}" stroke-width="5"/>
  <text x="600" y="765" text-anchor="middle" fill="${SIDEBAR_TEXT_COLOR}" font-family="Courier New, monospace" font-size="23">${footer}</text>
</svg>
EOF
}

write_calamares_slideshow() {
  local brand_dir="$1"

  cat > "${brand_dir}/show.qml" <<'EOF'
import QtQuick 2.15
import calamares.slideshow 1.0

Presentation {
  id: presentation

  Slide {
    Image {
      anchors.fill: parent
      source: "welcome.svg"
      fillMode: Image.PreserveAspectCrop
    }
  }
}
EOF
}

write_calamares_branding() {
  local brand_dir="${ROOT_DIR}/installer/calamares/branding/${LOGIN_THEME}"
  local settings="${ROOT_DIR}/installer/calamares/settings.conf"
  local users_conf="${ROOT_DIR}/installer/calamares/modules/users.conf"
  local display_conf="${ROOT_DIR}/installer/calamares/modules/displaymanager.conf"
  local tmp

  copy_calamares_branding_assets
  write_calamares_logo "${brand_dir}"
  write_calamares_welcome "${brand_dir}"
  write_calamares_slideshow "${brand_dir}"

  {
    printf 'componentName: %s\n' "${LOGIN_THEME}"
    printf 'strings:\n'
    printf '  productName: %s\n' "$(yaml_string "${NAME}")"
    printf '  shortProductName: %s\n' "$(yaml_string "${SHORT_NAME}")"
    printf '  version: %s\n' "$(yaml_string "${VERSION_ID}")"
    printf '  shortVersion: %s\n' "$(yaml_string "${VERSION_ID}")"
    printf '  versionedName: %s\n' "$(yaml_string "${PRETTY_NAME}")"
    printf '  shortVersionedName: %s\n' "$(yaml_string "${SHELL_SESSION_NAME}")"
    printf '  bootloaderEntryName: %s\n' "$(yaml_string "${NAME}")"
    printf '  productUrl: %s\n' "$(yaml_string "${HOME_URL}")"
    printf '  supportUrl: %s\n' "$(yaml_string "${SUPPORT_URL}")"
    printf '  knownIssuesUrl: %s\n' "$(yaml_string "${BUG_REPORT_URL}")"
    printf '  releaseNotesUrl: %s\n\n' "$(yaml_string "${RELEASE_NOTES_URL}")"
    printf 'images:\n'
    printf '  productLogo: logo.svg\n'
    printf '  productIcon: logo.svg\n'
    printf '  productWelcome: welcome.svg\n\n'
    printf 'style:\n'
    printf '  sidebarBackground: %s\n' "$(yaml_string "${SIDEBAR_BACKGROUND_COLOR}")"
    printf '  sidebarText: %s\n' "$(yaml_string "${SIDEBAR_TEXT_COLOR}")"
    printf '  sidebarTextSelect: %s\n\n' "$(yaml_string "${ACCENT_COLOR}")"
    printf 'slideshow: "show.qml"\n'
  } > "${brand_dir}/branding.desc"

  {
    printf 'QWidget {\n'
    printf '  font-family: Sans, Arial, Helvetica, sans-serif;\n'
    printf '  color: %s;\n' "${TEXT_COLOR}"
    printf '  background: %s;\n' "${SURFACE_COLOR}"
    printf '}\n\n'
    printf '#sidebarAppName {\n'
    printf '  color: %s;\n' "${SIDEBAR_TEXT_COLOR}"
    printf '  font-weight: 700;\n'
    printf '}\n\n'
    printf '#sidebarMenuApp {\n'
    printf '  background: %s;\n' "${SIDEBAR_BACKGROUND_COLOR}"
    printf '  border-right: 3px solid #05070a;\n'
    printf '}\n\n'
    printf '#sidebarMenuApp QListView::item:selected {\n'
    printf '  color: #05070a;\n'
    printf '  background: %s;\n' "${ACCENT_COLOR}"
    printf '}\n\n'
    printf 'QPushButton {\n'
    printf '  background: %s;\n' "${SURFACE_COLOR}"
    printf '  border-top: 2px solid %s;\n' "${LIGHT_COLOR}"
    printf '  border-left: 2px solid %s;\n' "${LIGHT_COLOR}"
    printf '  border-right: 2px solid #686a72;\n'
    printf '  border-bottom: 2px solid #686a72;\n'
    printf '  padding: 6px 14px;\n'
    printf '}\n\n'
    printf 'QPushButton:pressed {\n'
    printf '  background: #b6b2a8;\n'
    printf '  border-top: 2px solid #686a72;\n'
    printf '  border-left: 2px solid #686a72;\n'
    printf '  border-right: 2px solid %s;\n' "${LIGHT_COLOR}"
    printf '  border-bottom: 2px solid %s;\n' "${LIGHT_COLOR}"
    printf '}\n\n'
    printf 'QLineEdit,\nQComboBox,\nQTextEdit,\nQPlainTextEdit {\n'
    printf '  background: %s;\n' "${WINDOW_COLOR}"
    printf '  color: %s;\n' "${TEXT_COLOR}"
    printf '  border-top: 2px solid #686a72;\n'
    printf '  border-left: 2px solid #686a72;\n'
    printf '  border-right: 2px solid #ffffff;\n'
    printf '  border-bottom: 2px solid #ffffff;\n'
    printf '  padding: 4px;\n'
    printf '}\n\n'
    printf 'QProgressBar {\n'
    printf '  border: 2px solid #05070a;\n'
    printf '  background: %s;\n' "${MID_COLOR}"
    printf '  text-align: center;\n'
    printf '}\n\n'
    printf 'QProgressBar::chunk {\n'
    printf '  background: %s;\n' "${ACCENT_COLOR}"
    printf '}\n\n'
    printf 'QTabBar::tab {\n'
    printf '  background: #aaa79e;\n'
    printf '  color: %s;\n' "${TEXT_COLOR}"
    printf '  border-top: 2px solid %s;\n' "${LIGHT_COLOR}"
    printf '  border-left: 2px solid %s;\n' "${LIGHT_COLOR}"
    printf '  border-right: 2px solid #686a72;\n'
    printf '  padding: 6px 12px;\n'
    printf '}\n\n'
    printf 'QTabBar::tab:selected {\n'
    printf '  background: %s;\n' "${SURFACE_COLOR}"
    printf '  color: %s;\n' "${SIDEBAR_BACKGROUND_COLOR}"
    printf '}\n'
  } > "${brand_dir}/style.qss"

  tmp="$(mktemp)"
  sed -E "s|^branding:.*|branding: ${LOGIN_THEME}|" "${settings}" > "${tmp}"
  mv -- "${tmp}" "${settings}"

  tmp="$(mktemp)"
  if grep -Eq '^avatarFilePath:' "${users_conf}"; then
    sed -E "s|^avatarFilePath:.*|avatarFilePath: ${USER_ICON}|" "${users_conf}" > "${tmp}"
  else
    cat "${users_conf}" > "${tmp}"
    printf 'avatarFilePath: %s\n' "${USER_ICON}" >> "${tmp}"
  fi
  mv -- "${tmp}" "${users_conf}"

  {
    printf 'displaymanagers:\n'
    printf '  - sddm\n\n'
    printf 'defaultDesktopEnvironment:\n'
    printf '  executable: "aptura-session"\n'
    printf '  desktopFile: "%s"\n\n' "${SHELL_SESSION_ID}"
    printf 'basicSetup: true\n'
    printf 'sysconfigSetup: false\n'
  } > "${display_conf}"
}

main() {
  load_config
  derive_branding
  ensure_dirs
  write_branding_conf
  write_os_release_fragment
  write_system_identity_files
  write_grub_defaults
  write_branding_install
  write_icon_theme_index
  write_theme_index
  sync_gtk_theme_colors
  write_gtk_skeletons
  write_desktop_session
  write_waybar_style
  write_wofi_config
  write_labwc_config
  write_calamares_branding
  printf '[render-branding] Rendered %s branding from config files.\n' "${NAME}"
}

main "$@"
