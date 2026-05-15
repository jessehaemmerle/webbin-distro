#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
errors=0

fail() {
  errors=$((errors + 1))
  printf '[FAIL] %s\n' "$*" >&2
}

ok() {
  printf '[OK] %s\n' "$*"
}

require_file() {
  if [[ -f "${ROOT_DIR}/$1" ]]; then
    ok "$1"
  else
    fail "Missing file: $1"
  fi
}

require_dir() {
  if [[ -d "${ROOT_DIR}/$1" ]]; then
    ok "$1"
  else
    fail "Missing directory: $1"
  fi
}

require_executable() {
  if [[ -x "${ROOT_DIR}/$1" ]]; then
    ok "$1 executable"
  else
    fail "Not executable: $1"
  fi
}

main() {
  require_file README.md
  require_file LICENSE
  require_file build.sh
  require_file clean.sh

  require_dir config
  require_file config/live-build/config/includes.chroot/usr/lib/live/config/1170-aptura-sddm
  require_dir hooks
  require_dir desktop/wallpapers
  require_dir desktop/greeter-theme
  require_dir desktop/settings-center
  require_dir installer/calamares/modules
  require_dir installer/calamares/branding/aptura
  require_dir packages/aptura-meta
  require_dir packages/aptura-branding
  require_dir packages/aptura-desktop
  require_dir packages/aptura-settings
  require_dir scripts
  require_dir docs
  require_dir tests

  require_executable build.sh
  require_executable clean.sh
  require_executable scripts/validate.sh
  require_executable scripts/render-branding.sh
  require_executable scripts/build-iso.sh
  require_executable scripts/build-packages.sh
  require_executable scripts/create-local-repo.sh
  require_executable scripts/sign-repo.sh
  require_executable scripts/test-vm.sh
  require_executable packages/aptura-desktop/usr/bin/aptura-session
  require_executable packages/aptura-desktop/usr/bin/aptura-panel
  require_executable packages/aptura-desktop/usr/bin/aptura-launcher
  require_executable packages/aptura-desktop/usr/bin/aptura-control
  require_executable packages/aptura-desktop/usr/bin/aptura-screenshot
  require_executable packages/aptura-desktop/usr/bin/aptura-safe-update
  require_executable packages/aptura-desktop/usr/bin/aptura-rescue-center
  require_executable packages/aptura-desktop/usr/bin/aptura-privacy-check
  require_executable packages/aptura-desktop/usr/bin/aptura-mode
  require_executable packages/aptura-desktop/usr/bin/aptura-support-bundle
  require_executable packages/aptura-desktop/usr/bin/aptura-journey
  require_executable packages/aptura-desktop/usr/bin/aptura-context
  require_executable packages/aptura-desktop/usr/bin/aptura-shift
  require_executable packages/aptura-desktop/usr/bin/aptura-aftercare
  require_executable packages/aptura-desktop/usr/bin/aptura-live-bridge
  require_file packages/aptura-desktop/usr/share/aptura-shell/branding.sh

  if [[ "${errors}" -gt 0 ]]; then
    printf '[FAIL] Smoke test finished with %d error(s)\n' "${errors}" >&2
    exit 1
  fi

  printf '[OK] Smoke test passed\n'
}

main "$@"
