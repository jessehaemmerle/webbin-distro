#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${ROOT_DIR}/config/distro.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "ERROR: Missing ${ENV_FILE}" >&2
  exit 1
fi

# shellcheck source=config/distro.env
source "${ENV_FILE}"

mkdir -p "${ROOT_DIR}/${LOG_DIR}"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

run_step() {
  local name="$1"
  shift
  local logfile="${ROOT_DIR}/${LOG_DIR}/${name}.log"
  log "Starting ${name}"
  if "$@" 2>&1 | tee "${logfile}"; then
    log "Finished ${name}"
  else
    log "ERROR: ${name} failed. See ${logfile}"
    exit 1
  fi
}

main() {
  log "Building ${DISTRO_NAME} ${DISTRO_VERSION} for ${ARCH} on ${BASE_SUITE}"
  run_step "validate" bash "${ROOT_DIR}/scripts/validate.sh"
  run_step "build-packages" bash "${ROOT_DIR}/scripts/build-packages.sh"
  run_step "create-local-repo" bash "${ROOT_DIR}/scripts/create-local-repo.sh"
  if [[ "${SIGN_REPO}" == "true" ]]; then
    run_step "sign-repo" bash "${ROOT_DIR}/scripts/sign-repo.sh"
  fi
  run_step "build-iso" bash "${ROOT_DIR}/scripts/build-iso.sh"
  log "Done. ISO output is in ${ROOT_DIR}/${DIST_DIR}"
}

main "$@"
