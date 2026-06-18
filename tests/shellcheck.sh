#!/usr/bin/env bash
# Run shellcheck across all shell scripts. No-op (with notice) if shellcheck
# is not installed, so it stays usable on minimal hosts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
. "${SCRIPT_DIR}/../scripts/lib/common.sh"
load_distro_env

if ! command -v shellcheck >/dev/null 2>&1; then
  warn "shellcheck not installed; skipping. (apt install shellcheck)"
  exit 0
fi

mapfile -t files < <(find "${REPO_ROOT}" \
  -path "${REPO_ROOT}/build" -prune -o \
  -name '*.sh' -print)
# Include extensionless hook/bin scripts with a shebang.
while IFS= read -r f; do files+=("$f"); done < <(
  grep -rlE '^#!/.*(bash|sh)' "${REPO_ROOT}/desktop/bin" "${REPO_ROOT}/hooks" 2>/dev/null || true)

log "Running shellcheck on ${#files[@]} files"
# -x: follow sourced files; treat unreachable severity sensibly.
shellcheck -x -S warning "${files[@]}"
log "shellcheck clean."
