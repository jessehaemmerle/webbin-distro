#!/usr/bin/env bash
# Validate the Aptura repository layout, config, and package metadata.
# Runs on any OS (no root, no Linux-only tooling required).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
. "${SCRIPT_DIR}/lib/common.sh"
load_distro_env

errors=0
check() { if eval "$2"; then log "ok: $1"; else warn "FAIL: $1"; errors=$((errors+1)); fi; }

log "Validating ${DISTRO_NAME} repository"

# Required top-level pieces.
for d in config kernel branding desktop packages installer hooks scripts tests docs; do
  check "directory ${d}/ exists" "[ -d '${REPO_ROOT}/${d}' ]"
done

# Required config.
check "config/distro.env present"   "[ -f '${REPO_ROOT}/config/distro.env' ]"
check "config/branding.conf present" "[ -f '${REPO_ROOT}/config/branding.conf' ]"
check "live-build package list present" \
  "[ -f '${REPO_ROOT}/config/live-build/config/package-lists/aptura.list.chroot' ]"

# Base must be Ubuntu for this generation of the project.
check "base family is ubuntu" "[ '${BASE_FAMILY}' = 'ubuntu' ]"
check "arch is set" "[ -n '${ARCH}' ]"

# Each package has a control (or control.in).
for pkg in aptura-meta aptura-branding aptura-desktop aptura-settings aptura-apps aptura-kernel; do
  check "package ${pkg} has control" \
    "[ -f '${REPO_ROOT}/packages/${pkg}/debian/control' ] || [ -f '${REPO_ROOT}/packages/${pkg}/debian/control.in' ]"
done

# Calamares essentials.
check "calamares settings.conf present" "[ -f '${REPO_ROOT}/installer/calamares/settings.conf' ]"
check "calamares branding present" "[ -d '${REPO_ROOT}/installer/calamares/branding/aptura' ]"

# Kernel build script present and version set.
check "kernel build script present" "[ -f '${REPO_ROOT}/kernel/build-kernel.sh' ]"
check "KERNEL_VERSION set" "[ -n '${KERNEL_VERSION}' ]"

# Hooks are POSIX-ish and numbered.
check "hooks present" "ls '${REPO_ROOT}'/hooks/0*.sh >/dev/null 2>&1"

if [ "${errors}" -gt 0 ]; then
  die "${errors} validation error(s)."
fi
log "Validation passed."
