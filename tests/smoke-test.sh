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

if [ "${fails}" -gt 0 ]; then die "${fails} smoke-test failure(s)."; fi
log "Smoke test passed."
