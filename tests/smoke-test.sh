#!/usr/bin/env bash
# Fast structural smoke test. Runs validate.sh plus a few content sanity checks.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
. "${SCRIPT_DIR}/../scripts/lib/common.sh"
load_distro_env

fails=0
want() { if grep -q "$2" "$1" 2>/dev/null; then log "ok: $3"; else warn "FAIL: $3"; fails=$((fails+1)); fi; }

"${SCRIPT_DIR}/../scripts/validate.sh"

want "${REPO_ROOT}/config/distro.env" 'BASE_FAMILY="ubuntu"' "base is Ubuntu"
want "${REPO_ROOT}/packages/aptura-meta/debian/control" "aptura-kernel" "meta depends on custom kernel"
want "${REPO_ROOT}/packages/aptura-apps/debian/control" "libreoffice" "apps include LibreOffice"
want "${REPO_ROOT}/packages/aptura-apps/debian/control" "thunderbird" "apps include Thunderbird"
want "${REPO_ROOT}/desktop/wayland-sessions/aptura.desktop" "aptura-session" "Aptura Shell session present"
want "${REPO_ROOT}/installer/calamares/modules/unpackfs.conf" "casper" "Calamares uses Ubuntu casper path"
want "${REPO_ROOT}/hooks/050-flatpak-apps.sh" "com.spotify.Client" "Spotify queued via Flatpak"
want "${REPO_ROOT}/config/distro.env" 'DEFAULT_LOCALE="de_AT.UTF-8"' "default locale is de_AT"
want "${REPO_ROOT}/hooks/010-base-system.sh" "etc/default/keyboard" "keyboard layout configured"
want "${REPO_ROOT}/packages/aptura-apps/debian/control" "libreoffice-l10n-de" "German LibreOffice langpack"
want "${REPO_ROOT}/branding/templates/sddm/Main.qml.in" "sddm.login" "SDDM greeter has a Main.qml"
want "${REPO_ROOT}/desktop/themes/Aptura-Shell/labwc/themerc" "window.active.border.color" "labwc theme present"
want "${REPO_ROOT}/desktop/themes/Aptura-Shell/gtk-3.0/gtk.css" "accent_color" "GTK theme present"
want "${REPO_ROOT}/packages/aptura-welcome/payload/usr/bin/aptura-welcome" "Adw.Application" "welcome app present"
want "${REPO_ROOT}/packages/aptura-secureboot/payload/usr/sbin/aptura-secureboot" "mokutil --import" "Secure Boot enrollment present"
want "${REPO_ROOT}/packages/aptura-meta/debian/control" "aptura-secureboot" "meta depends on secureboot"

if [ "${fails}" -gt 0 ]; then die "${fails} smoke-test failure(s)."; fi
log "Smoke test passed."
