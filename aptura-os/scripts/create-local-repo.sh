#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../config/distro.env
source "${ROOT_DIR}/config/distro.env"

log() {
  printf '[create-local-repo] %s\n' "$*"
}

die() {
  printf '[create-local-repo] ERROR: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"
}

main() {
  require_command apt-ftparchive
  require_command gzip

  local repo="${ROOT_DIR}/${LOCAL_REPO_DIR}"
  local pool="${repo}/pool/main"
  local dist="${repo}/dists/${BASE_SUITE}/main/binary-${ARCH}"

  rm -rf -- "${repo}"
  mkdir -p "${pool}" "${dist}"

  compgen -G "${ROOT_DIR}/${PACKAGE_OUTPUT_DIR}/*.deb" >/dev/null ||
    die "No .deb files found in ${ROOT_DIR}/${PACKAGE_OUTPUT_DIR}. Run scripts/build-packages.sh first."

  cp -- "${ROOT_DIR}/${PACKAGE_OUTPUT_DIR}"/*.deb "${pool}/"

  (
    cd "${repo}"
    apt-ftparchive packages "pool" > "dists/${BASE_SUITE}/main/binary-${ARCH}/Packages"
    gzip -9ck "dists/${BASE_SUITE}/main/binary-${ARCH}/Packages" > "dists/${BASE_SUITE}/main/binary-${ARCH}/Packages.gz"
    apt-ftparchive \
      -o "APT::FTPArchive::Release::Origin=${APTURA_REPO_ORIGIN}" \
      -o "APT::FTPArchive::Release::Label=${APTURA_REPO_LABEL}" \
      -o "APT::FTPArchive::Release::Suite=${BASE_SUITE}" \
      -o "APT::FTPArchive::Release::Codename=${BASE_SUITE}" \
      -o "APT::FTPArchive::Release::Architectures=${ARCH}" \
      -o "APT::FTPArchive::Release::Components=main" \
      release "dists/${BASE_SUITE}" > "dists/${BASE_SUITE}/Release"
  )

  log "Local repository written to ${repo}"
  log "Use: deb [signed-by=/usr/share/keyrings/aptura-archive-keyring.gpg] file:${repo} ${BASE_SUITE} main"
}

main "$@"
