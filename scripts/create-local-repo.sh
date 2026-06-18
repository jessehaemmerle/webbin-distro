#!/usr/bin/env bash
# Assemble a local APT repository from the built Aptura .deb packages and the
# custom kernel .deb files, so live-build (and installed systems, once signed)
# can resolve Aptura dependencies.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
. "${SCRIPT_DIR}/lib/common.sh"
load_distro_env

REPO_DIR="${REPO_ROOT}/${LOCAL_REPO_DIR}"
POOL="${REPO_DIR}/pool/main"
DISTS="${REPO_DIR}/dists/${BASE_SUITE}/main/binary-${ARCH}"

assert_inside_repo "${REPO_ROOT}/build"
rm -rf "${REPO_DIR}"
mkdir -p "${POOL}" "${DISTS}"

log "Collecting .deb files into local repo pool"
found=0
for d in "${REPO_ROOT}/${PACKAGE_OUTPUT_DIR}" "${REPO_ROOT}/${KERNEL_OUTPUT_DIR}"; do
  [ -d "${d}" ] || continue
  while IFS= read -r -d '' deb; do
    cp -v "${deb}" "${POOL}/"
    found=1
  done < <(find "${d}" -maxdepth 1 -name '*.deb' -print0)
done

if [ "${found}" -eq 0 ]; then
  warn "no .deb files found; local repo will be empty (expected off-Linux)."
fi

if command -v dpkg-scanpackages >/dev/null 2>&1; then
  log "Generating Packages index"
  ( cd "${REPO_DIR}" && dpkg-scanpackages -m pool/main /dev/null > "${DISTS}/Packages" )
  gzip -kf "${DISTS}/Packages"

  # Minimal Release file (signed later by sign-repo.sh when enabled).
  cat > "${REPO_DIR}/dists/${BASE_SUITE}/Release" <<EOF
Origin: ${APTURA_REPO_ORIGIN}
Label: ${APTURA_REPO_LABEL}
Suite: ${BASE_SUITE}
Codename: ${BASE_SUITE}
Architectures: ${ARCH}
Components: main
Description: Aptura OS local package repository
EOF
  log "Local repo ready at ${REPO_DIR}"
else
  warn "dpkg-scanpackages not available; skipping index generation (need Linux)."
fi
