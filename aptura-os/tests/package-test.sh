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

check_control_field() {
  local file="$1"
  local field="$2"
  if grep -Eq "^${field}:" "${file}"; then
    ok "$(basename "$(dirname "$(dirname "${file}")")") control has ${field}"
  else
    fail "${file#${ROOT_DIR}/} missing ${field}"
  fi
}

check_package() {
  local pkg="$1"
  local dir="${ROOT_DIR}/packages/${pkg}"
  local control="${dir}/debian/control"
  local changelog="${dir}/debian/changelog"
  local rules="${dir}/debian/rules"
  local install="${dir}/debian/install"
  local format="${dir}/debian/source/format"

  [[ -d "${dir}" ]] || { fail "Missing package directory: ${pkg}"; return; }
  [[ -f "${control}" ]] || fail "Missing ${pkg}/debian/control"
  [[ -f "${changelog}" ]] || fail "Missing ${pkg}/debian/changelog"
  [[ -f "${rules}" ]] || fail "Missing ${pkg}/debian/rules"
  [[ -f "${install}" ]] || fail "Missing ${pkg}/debian/install"
  [[ -f "${format}" ]] || fail "Missing ${pkg}/debian/source/format"
  [[ -x "${rules}" ]] || fail "${pkg}/debian/rules is not executable"

  if [[ -f "${control}" ]]; then
    check_control_field "${control}" Source
    check_control_field "${control}" Maintainer
    check_control_field "${control}" Build-Depends
    check_control_field "${control}" Package
    check_control_field "${control}" Architecture
    check_control_field "${control}" Description
  fi

  if [[ -f "${changelog}" ]] && ! grep -Eq "^${pkg} \\([^)]+\\) trixie;" "${changelog}"; then
    fail "${pkg}/debian/changelog has unexpected header"
  fi
}

main() {
  check_package aptura-meta
  check_package aptura-branding
  check_package aptura-desktop
  check_package aptura-settings

  if [[ "${errors}" -gt 0 ]]; then
    printf '[FAIL] Package test finished with %d error(s)\n' "${errors}" >&2
    exit 1
  fi

  printf '[OK] Package metadata test passed\n'
}

main "$@"
