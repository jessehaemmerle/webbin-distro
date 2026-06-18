#!/usr/bin/env bash
# Sign the local APT repository Release file with the configured GPG key.
# Enabled by SIGN_REPO=true + REPO_GPG_KEY_ID in config/distro.env.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
. "${SCRIPT_DIR}/lib/common.sh"
load_distro_env

[ "${SIGN_REPO}" = "true" ] || { log "SIGN_REPO not true; nothing to sign."; exit 0; }
[ -n "${REPO_GPG_KEY_ID}" ] || die "SIGN_REPO=true but REPO_GPG_KEY_ID is empty."
require_cmd gpg

REL="${REPO_ROOT}/${LOCAL_REPO_DIR}/dists/${BASE_SUITE}/Release"
[ -f "${REL}" ] || die "Release file not found: ${REL} (run create-local-repo.sh first)"

log "Signing ${REL} with key ${REPO_GPG_KEY_ID}"
gpg --default-key "${REPO_GPG_KEY_ID}" --batch --yes -abs -o "${REL}.gpg" "${REL}"
gpg --default-key "${REPO_GPG_KEY_ID}" --batch --yes --clearsign \
    -o "$(dirname "${REL}")/InRelease" "${REL}"
log "Repository signed."
