#!/usr/bin/env bash
# Remove build artifacts. Only touches build/ and dist/ inside the repo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
. "${SCRIPT_DIR}/scripts/lib/common.sh"
load_distro_env

for d in "${BUILD_DIR}" "${DIST_DIR}"; do
  target="${REPO_ROOT}/${d}"
  [ -e "${target}" ] || continue
  assert_inside_repo "${target}"
  log "Removing ${target}"
  rm -rf "${target}"
done
log "Clean complete."
