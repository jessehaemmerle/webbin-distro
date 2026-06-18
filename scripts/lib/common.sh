#!/usr/bin/env bash
# Shared helpers for Aptura OS build scripts. Source this; do not execute it.
# shellcheck shell=bash

# Resolve repo root relative to this library file.
APTURA_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APTURA_REPO_ROOT="$(cd "${APTURA_LIB_DIR}/../.." && pwd)"

log()  { printf '\033[0;36m[aptura]\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m[aptura][warn]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[0;31m[aptura][error]\033[0m %s\n' "$*" >&2; exit 1; }

# Load tracked config plus optional untracked local overrides.
load_distro_env() {
  local cfg="${APTURA_REPO_ROOT}/config/distro.env"
  [ -f "${cfg}" ] || die "missing ${cfg}"
  # shellcheck source=/dev/null
  . "${cfg}"
  [ -f "${APTURA_REPO_ROOT}/config/distro.local.env" ] && \
    # shellcheck source=/dev/null
    . "${APTURA_REPO_ROOT}/config/distro.local.env"

  local brand="${APTURA_REPO_ROOT}/config/branding.conf"
  [ -f "${brand}" ] && \
    # shellcheck source=/dev/null
    . "${brand}"
  [ -f "${APTURA_REPO_ROOT}/config/branding.local.env" ] && \
    # shellcheck source=/dev/null
    . "${APTURA_REPO_ROOT}/config/branding.local.env"

  export REPO_ROOT="${APTURA_REPO_ROOT}"
}

# require_cmd cmd [cmd...] -> die if any are missing.
require_cmd() {
  local missing=0 c
  for c in "$@"; do
    if ! command -v "${c}" >/dev/null 2>&1; then
      warn "required command not found: ${c}"
      missing=1
    fi
  done
  [ "${missing}" -eq 0 ] || die "install the missing tools listed above and retry."
}

# is_linux -> 0 on Linux, 1 otherwise.
is_linux() { [ "$(uname -s)" = "Linux" ]; }

# Guard against destructive paths escaping the repo root.
assert_inside_repo() {
  local p; p="$(cd "$1" 2>/dev/null && pwd || true)"
  case "${p}" in
    "${APTURA_REPO_ROOT}"|"${APTURA_REPO_ROOT}"/*) return 0 ;;
    *) die "refusing to operate on path outside repo root: $1" ;;
  esac
}
