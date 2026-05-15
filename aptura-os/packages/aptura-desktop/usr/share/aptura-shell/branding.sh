# Branding defaults shared by Aptura Shell scripts.
# This file is sourced by POSIX sh and Bash entry points.

if [ -r "${APTURA_BRANDING_CONF:-/etc/aptura/branding.conf}" ]; then
  # shellcheck source=/dev/null
  . "${APTURA_BRANDING_CONF:-/etc/aptura/branding.conf}"
fi

: "${ID:=aptura}"
: "${NAME:=Aptura OS}"
: "${SHORT_NAME:=Aptura}"
: "${PRETTY_NAME:=${NAME}}"
: "${DESKTOP_NAME:=Aptura Shell}"
: "${SHELL_SESSION_ID:=aptura}"
: "${SHELL_SESSION_NAME:=${DESKTOP_NAME}}"
: "${XDG_CURRENT_DESKTOP_NAME:=Aptura}"
: "${XDG_MENU_PREFIX:=aptura-}"
: "${PANEL_TITLE:=${SHORT_NAME}}"
: "${THEME_NAME:=Aptura-Shell}"
: "${GTK_THEME_NAME:=${THEME_NAME}}"
: "${ICON_THEME_NAME:=Aptura-Shell}"
: "${CURSOR_THEME_NAME:=Adwaita}"
: "${CURSOR_SIZE:=24}"
: "${LOGO_NAME:=distributor-logo-aptura}"
: "${APP_ICON_NAME:=aptura}"
: "${USER_ICON:=/usr/share/pixmaps/aptura.svg}"
: "${DEFAULT_WALLPAPER:=/usr/share/backgrounds/aptura/aptura-context-grid.svg}"
: "${WALLPAPER_DIR:=/usr/share/backgrounds/aptura}"
: "${ABOUT_DESCRIPTION:=A Debian-compatible desktop distribution with Aptura Shell, Wayland defaults, practical tooling, and a Plasma fallback session.}"
: "${BASE_FAMILY:=debian}"
: "${BASE_SUITE:=trixie}"
