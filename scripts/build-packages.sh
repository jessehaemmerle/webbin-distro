#!/usr/bin/env bash
# Build the Aptura .deb packages into the package output dir.
#
# Staging model: each tracked package under packages/<pkg> is copied to
# build/packages-src/<pkg>, then:
#   - missing debian boilerplate (changelog/rules/source/format/copyright) is
#     generated,
#   - control.in is rendered to control with config vars,
#   - dynamic payloads are staged (branding <- build/branding, desktop <- desktop/),
#   - dpkg-buildpackage produces the .deb (Linux + tooling only).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
. "${SCRIPT_DIR}/lib/common.sh"
load_distro_env

SRC_ROOT="${REPO_ROOT}/build/packages-src"
OUT_DIR="${REPO_ROOT}/${PACKAGE_OUTPUT_DIR}"
rm -rf "${SRC_ROOT}"
mkdir -p "${SRC_ROOT}" "${OUT_DIR}"

PACKAGES="aptura-branding aptura-desktop aptura-settings aptura-apps aptura-kernel aptura-meta"

gen_boilerplate() {
  local dir="$1" name="$2"
  mkdir -p "${dir}/debian/source"
  [ -f "${dir}/debian/source/format" ] || echo "3.0 (native)" > "${dir}/debian/source/format"
  [ -f "${dir}/debian/rules" ] || printf '#!/usr/bin/make -f\n%%:\n\tdh $@\n' > "${dir}/debian/rules"
  chmod +x "${dir}/debian/rules"
  if [ ! -f "${dir}/debian/changelog" ]; then
    cat > "${dir}/debian/changelog" <<EOF
${name} (${DISTRO_VERSION}) ${BASE_SUITE}; urgency=medium

  * Aptura OS ${DISTRO_VERSION} build.

 -- Aptura <packages@aptura.example>  $(date -R 2>/dev/null || echo 'Wed, 18 Jun 2026 00:00:00 +0000')
EOF
  fi
  [ -f "${dir}/debian/copyright" ] || cat > "${dir}/debian/copyright" <<'EOF'
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Files: *
Copyright: 2026 Aptura
License: MIT
EOF
}

render_control_in() {
  local dir="$1"
  [ -f "${dir}/debian/control.in" ] || return 0
  sed -e "s|@KERNEL_VERSION@|${KERNEL_VERSION}|g" \
      -e "s|@DISTRO_VERSION@|${DISTRO_VERSION}|g" \
      -e "s|@BASE_SUITE@|${BASE_SUITE}|g" \
      "${dir}/debian/control.in" > "${dir}/debian/control"
  rm -f "${dir}/debian/control.in"
}

stage_payload() {
  local pkg="$1" dir="$2"
  case "${pkg}" in
    aptura-branding)
      [ -d "${REPO_ROOT}/build/branding" ] || \
        die "build/branding missing; run scripts/render-branding.sh first"
      mkdir -p "${dir}/payload"
      cp -a "${REPO_ROOT}/build/branding/." "${dir}/payload/"
      ;;
    aptura-desktop)
      mkdir -p "${dir}/payload"
      cp -a "${REPO_ROOT}/desktop/." "${dir}/payload/"
      ;;
  esac
}

build_one() {
  local pkg="$1"
  local src="${REPO_ROOT}/packages/${pkg}"
  local dst="${SRC_ROOT}/${pkg}"
  [ -d "${src}" ] || die "missing package source: ${src}"
  log "Staging ${pkg}"
  cp -a "${src}" "${dst}"
  gen_boilerplate "${dst}" "${pkg}"
  render_control_in "${dst}"
  stage_payload "${pkg}" "${dst}"

  if is_linux && command -v dpkg-buildpackage >/dev/null 2>&1; then
    log "Building ${pkg} (.deb)"
    ( cd "${dst}" && dpkg-buildpackage -us -uc -b )
    find "${SRC_ROOT}" -maxdepth 1 -name "${pkg}_*.deb" -exec mv -v {} "${OUT_DIR}/" \;
  else
    warn "skip .deb build for ${pkg} (need Linux + dpkg-dev/debhelper); staged at ${dst}"
  fi
}

for p in ${PACKAGES}; do
  build_one "${p}"
done

log "Package staging complete. Built artifacts (if any):"
ls -1 "${OUT_DIR}"/*.deb 2>/dev/null || warn "no .deb files produced on this host."
