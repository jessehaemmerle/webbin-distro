#!/usr/bin/env bash
# Aptura OS top-level build orchestrator.
#
#   ./build.sh            full build (validate -> kernel -> packages -> repo -> iso)
#   ./build.sh --no-iso   everything except the live ISO (useful off-Linux)
#
# Full ISO creation requires a Linux host with live-build (see README.md).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
. "${SCRIPT_DIR}/scripts/lib/common.sh"
load_distro_env

BUILD_ISO=1
for arg in "$@"; do
  case "${arg}" in
    --no-iso) BUILD_ISO=0 ;;
    *) die "unknown argument: ${arg}" ;;
  esac
done

mkdir -p "${REPO_ROOT}/${LOG_DIR}"

log "Building ${DISTRO_PRETTY_NAME} (base: ${BASE_DISTRIBUTION} ${BASE_SUITE}, arch: ${ARCH})"

log "Step 1/6: render branding"
"${SCRIPT_DIR}/scripts/render-branding.sh"

log "Step 2/6: validate repository, config, packages"
"${SCRIPT_DIR}/scripts/validate.sh"

if [ "${BUILD_CUSTOM_KERNEL}" = "true" ]; then
  log "Step 3/6: build custom kernel"
  if is_linux; then
    "${SCRIPT_DIR}/kernel/build-kernel.sh"
  else
    warn "not Linux: skipping kernel compile (run kernel/build-kernel.sh on Linux)"
  fi
else
  log "Step 3/6: custom kernel disabled, skipping"
fi

log "Step 4/6: build Aptura .deb packages"
"${SCRIPT_DIR}/scripts/build-packages.sh"

log "Step 5/6: create local APT repository"
"${SCRIPT_DIR}/scripts/create-local-repo.sh"
if [ "${SIGN_REPO}" = "true" ]; then
  "${SCRIPT_DIR}/scripts/sign-repo.sh"
fi

if [ "${BUILD_ISO}" -eq 1 ]; then
  log "Step 6/6: build live ISO"
  if is_linux; then
    "${SCRIPT_DIR}/scripts/build-iso.sh"
    log "Done. Artifacts in ${REPO_ROOT}/${DIST_DIR}:"
    ls -1 "${REPO_ROOT}/${DIST_DIR}" 2>/dev/null || true
  else
    warn "not Linux: skipping ISO build. Re-run on an Ubuntu host to produce the ISO."
  fi
else
  log "Step 6/6: ISO skipped (--no-iso)"
fi

log "Build finished."
