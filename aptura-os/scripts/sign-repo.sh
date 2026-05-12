#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../config/distro.env
source "${ROOT_DIR}/config/distro.env"

log() {
  printf '[sign-repo] %s\n' "$*"
}

die() {
  printf '[sign-repo] ERROR: %s\n' "$*" >&2
  exit 1
}

main() {
  command -v gpg >/dev/null 2>&1 || die "Missing command: gpg"
  [[ -n "${REPO_GPG_KEY_ID}" ]] || die "Set REPO_GPG_KEY_ID in config/distro.env"

  local release="${ROOT_DIR}/${LOCAL_REPO_DIR}/dists/${BASE_SUITE}/Release"
  [[ -f "${release}" ]] || die "Missing Release file: ${release}"

  rm -f -- "${release}.gpg" "$(dirname "${release}")/InRelease"
  gpg --default-key "${REPO_GPG_KEY_ID}" --batch --yes --armor --detach-sign --output "${release}.gpg" "${release}"
  gpg --default-key "${REPO_GPG_KEY_ID}" --batch --yes --clearsign --output "$(dirname "${release}")/InRelease" "${release}"
  log "Signed ${release}"
}

main "$@"
