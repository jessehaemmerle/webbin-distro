#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../config/distro.env
source "${ROOT_DIR}/config/distro.env"
if [[ -f "${ROOT_DIR}/config/distro.local.env" ]]; then
  # shellcheck source=/dev/null
  source "${ROOT_DIR}/config/distro.local.env"
fi

log() {
  printf '[build-packages] %s\n' "$*"
}

die() {
  printf '[build-packages] ERROR: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"
}

prepare_output() {
  mkdir -p "${ROOT_DIR}/${PACKAGE_OUTPUT_DIR}"
  find "${ROOT_DIR}/${PACKAGE_OUTPUT_DIR}" -maxdepth 1 -type f -name '*.deb' -delete
}

build_one() {
  local pkg_dir="$1"
  local pkg_name
  pkg_name="$(basename "${pkg_dir}")"

  log "Building ${pkg_name}"
  (
    cd "${pkg_dir}"
    dpkg-buildpackage -us -uc -b
  )
}

collect_debs() {
  find "${ROOT_DIR}/packages" -maxdepth 1 -type f -name '*.deb' -print0 |
    while IFS= read -r -d '' deb; do
      mv -- "${deb}" "${ROOT_DIR}/${PACKAGE_OUTPUT_DIR}/"
    done
}

main() {
  require_command dpkg-buildpackage
  require_command dpkg-deb
  bash "${ROOT_DIR}/scripts/render-branding.sh"
  prepare_output

  local pkg
  for pkg in "${ROOT_DIR}"/packages/aptura-*; do
    [[ -d "${pkg}/debian" ]] || continue
    build_one "${pkg}"
  done

  collect_debs
  log "Packages written to ${ROOT_DIR}/${PACKAGE_OUTPUT_DIR}"
}

main "$@"
