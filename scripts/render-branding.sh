#!/usr/bin/env bash
# Render Aptura branding from config into build/branding.
#
# Reads config/distro.env + config/branding.conf (+ local overrides) and expands
# @VAR@ placeholders in branding/templates/** into concrete files under
# build/branding/**. Also copies static assets. Safe to run on any OS.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
. "${SCRIPT_DIR}/lib/common.sh"
load_distro_env

TEMPLATE_DIR="${REPO_ROOT}/branding/templates"
ASSET_DIR="${REPO_ROOT}/branding/assets"
OUT_DIR="${REPO_ROOT}/build/branding"

rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"

# Variables exposed to templates as @NAME@.
render_one() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "${dst}")"
  sed \
    -e "s|@DISTRO_ID@|${DISTRO_ID}|g" \
    -e "s|@DISTRO_NAME@|${DISTRO_NAME}|g" \
    -e "s|@DISTRO_PRETTY_NAME@|${DISTRO_PRETTY_NAME}|g" \
    -e "s|@DISTRO_VERSION@|${DISTRO_VERSION}|g" \
    -e "s|@DISTRO_CODENAME@|${DISTRO_CODENAME}|g" \
    -e "s|@DISTRO_HOME_URL@|${DISTRO_HOME_URL}|g" \
    -e "s|@DISTRO_SUPPORT_URL@|${DISTRO_SUPPORT_URL}|g" \
    -e "s|@DESKTOP_NAME@|${DESKTOP_NAME}|g" \
    -e "s|@BRAND_NAME@|${BRAND_NAME}|g" \
    -e "s|@BRAND_SHORT@|${BRAND_SHORT}|g" \
    -e "s|@BRAND_TAGLINE@|${BRAND_TAGLINE}|g" \
    -e "s|@BRAND_VENDOR@|${BRAND_VENDOR}|g" \
    -e "s|@COLOR_BACKGROUND@|${COLOR_BACKGROUND}|g" \
    -e "s|@COLOR_PRIMARY@|${COLOR_PRIMARY}|g" \
    -e "s|@COLOR_ACCENT@|${COLOR_ACCENT}|g" \
    -e "s|@COLOR_HIGHLIGHT@|${COLOR_HIGHLIGHT}|g" \
    -e "s|@COLOR_WARNING@|${COLOR_WARNING}|g" \
    -e "s|@COLOR_NEUTRAL@|${COLOR_NEUTRAL}|g" \
    -e "s|@COLOR_TEXT@|${COLOR_TEXT}|g" \
    -e "s|@GTK_THEME_NAME@|${GTK_THEME_NAME}|g" \
    -e "s|@ICON_THEME_NAME@|${ICON_THEME_NAME}|g" \
    -e "s|@PLYMOUTH_THEME_NAME@|${PLYMOUTH_THEME_NAME}|g" \
    -e "s|@GRUB_THEME_NAME@|${GRUB_THEME_NAME}|g" \
    -e "s|@SDDM_THEME_NAME@|${SDDM_THEME_NAME}|g" \
    -e "s|@CALAMARES_BRANDING_ID@|${CALAMARES_BRANDING_ID}|g" \
    "${src}" > "${dst}"
}

log "Rendering branding templates -> ${OUT_DIR}"
if [ -d "${TEMPLATE_DIR}" ]; then
  while IFS= read -r -d '' tpl; do
    rel="${tpl#"${TEMPLATE_DIR}/"}"
    dst="${OUT_DIR}/${rel%.in}"
    render_one "${tpl}" "${dst}"
    log "  rendered ${rel%.in}"
  done < <(find "${TEMPLATE_DIR}" -type f -name '*.in' -print0)
fi

if [ -d "${ASSET_DIR}" ]; then
  log "Copying static assets"
  mkdir -p "${OUT_DIR}/assets"
  cp -r "${ASSET_DIR}/." "${OUT_DIR}/assets/"
fi

log "Branding rendered for ${DISTRO_PRETTY_NAME}"
