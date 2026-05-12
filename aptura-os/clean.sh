#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

safe_remove() {
  local target="$1"
  local resolved_root
  local resolved_target

  resolved_root="$(cd "${ROOT_DIR}" && pwd -P)"
  if [[ -e "${target}" ]]; then
    resolved_target="$(cd "$(dirname "${target}")" && pwd -P)/$(basename "${target}")"
  else
    resolved_target="$(cd "${ROOT_DIR}" && pwd -P)/$(basename "${target}")"
  fi

  case "${resolved_target}" in
    "${resolved_root}/build"|"${resolved_root}/dist")
      log "Removing ${resolved_target}"
      rm -rf -- "${resolved_target}"
      ;;
    *)
      echo "ERROR: Refusing to remove unsafe path: ${resolved_target}" >&2
      exit 1
      ;;
  esac
}

safe_remove "${ROOT_DIR}/build"
safe_remove "${ROOT_DIR}/dist"
log "Clean complete"
