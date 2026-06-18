#!/usr/bin/env bash
# Validate Debian control metadata for each Aptura package.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
. "${SCRIPT_DIR}/../scripts/lib/common.sh"
load_distro_env

fails=0
for pkg in aptura-meta aptura-branding aptura-desktop aptura-settings aptura-apps aptura-kernel; do
  ctrl="${REPO_ROOT}/packages/${pkg}/debian/control"
  [ -f "${ctrl}" ] || ctrl="${REPO_ROOT}/packages/${pkg}/debian/control.in"
  if [ ! -f "${ctrl}" ]; then warn "FAIL: ${pkg} has no control"; fails=$((fails+1)); continue; fi

  for field in "Source:" "Package:" "Maintainer:" "Architecture:" "Description:"; do
    if ! grep -q "^${field}" "${ctrl}"; then
      warn "FAIL: ${pkg} missing ${field}"; fails=$((fails+1))
    fi
  done
  log "checked ${pkg}"
done

# lintian if available (Linux); informational only.
if command -v lintian >/dev/null 2>&1; then
  for deb in "${REPO_ROOT}/${PACKAGE_OUTPUT_DIR}"/*.deb; do
    [ -e "${deb}" ] || continue
    log "lintian ${deb}"
    lintian --no-tag-display-limit "${deb}" || true
  done
fi

if [ "${fails}" -gt 0 ]; then die "${fails} package metadata failure(s)."; fi
log "Package metadata OK."
