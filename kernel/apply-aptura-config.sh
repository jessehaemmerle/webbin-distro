#!/usr/bin/env bash
# Merge Aptura kernel config overrides into a kernel .config.
#
# Usage: apply-aptura-config.sh <path/to/.config> <path/to/overrides.config>
#
# Each non-comment line in the overrides file is a normal Kconfig assignment,
# e.g. "CONFIG_FOO=y" or "# CONFIG_BAR is not set". Existing matching entries
# are replaced; new ones are appended. Run "make olddefconfig" afterwards to
# resolve dependencies.
set -euo pipefail

CONFIG_FILE="${1:?missing .config path}"
OVERRIDES="${2:?missing overrides path}"

[ -f "${CONFIG_FILE}" ] || { echo "no .config at ${CONFIG_FILE}" >&2; exit 1; }
[ -f "${OVERRIDES}" ] || { echo "no overrides at ${OVERRIDES}" >&2; exit 1; }

while IFS= read -r line; do
  case "${line}" in
    ''|'##'*) continue ;;          # blank or section comment
  esac

  if printf '%s\n' "${line}" | grep -Eq '^CONFIG_[A-Z0-9_]+='; then
    key="${line%%=*}"
  elif printf '%s\n' "${line}" | grep -Eq '^# CONFIG_[A-Z0-9_]+ is not set$'; then
    key="$(printf '%s\n' "${line}" | sed -E 's/^# (CONFIG_[A-Z0-9_]+) is not set$/\1/')"
  else
    continue
  fi

  # Drop any existing definition of this key, then append the override.
  sed -i -E "/^${key}=/d; /^# ${key} is not set\$/d" "${CONFIG_FILE}"
  printf '%s\n' "${line}" >> "${CONFIG_FILE}"
done < "${OVERRIDES}"

echo "Applied Aptura overrides from ${OVERRIDES} to ${CONFIG_FILE}"
