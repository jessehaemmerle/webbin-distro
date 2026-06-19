#!/bin/sh
# Chroot hook: base system tweaks for the live/installed image.
# Runs inside the live-build chroot as root.
set -e

# Build variables exported by build-iso.sh into the image.
[ -f /etc/aptura/build.env ] && . /etc/aptura/build.env

echo "[aptura][hook] 010 base system"

# Default locale, language, keyboard and timezone (installer lets the user
# change all of them). Defaults come from config/distro.env (German / Austria).
DEFAULT_LOCALE="${DEFAULT_LOCALE:-de_AT.UTF-8}"
SECONDARY_LOCALE="${SECONDARY_LOCALE:-en_US.UTF-8}"
DEFAULT_LANGUAGE="${DEFAULT_LANGUAGE:-de_AT:de}"
DEFAULT_KEYBOARD_LAYOUT="${DEFAULT_KEYBOARD_LAYOUT:-de}"
DEFAULT_KEYBOARD_VARIANT="${DEFAULT_KEYBOARD_VARIANT:-nodeadkeys}"
DEFAULT_KEYBOARD_MODEL="${DEFAULT_KEYBOARD_MODEL:-pc105}"
DEFAULT_TIMEZONE="${DEFAULT_TIMEZONE:-Europe/Vienna}"

{
  echo "${DEFAULT_LOCALE} UTF-8"
  echo "${SECONDARY_LOCALE} UTF-8"
} >> /etc/locale.gen
locale-gen || true
update-locale "LANG=${DEFAULT_LOCALE}" "LANGUAGE=${DEFAULT_LANGUAGE}" || true

# Console + X11 keyboard defaults.
cat > /etc/default/keyboard <<EOF
XKBMODEL="${DEFAULT_KEYBOARD_MODEL}"
XKBLAYOUT="${DEFAULT_KEYBOARD_LAYOUT}"
XKBVARIANT="${DEFAULT_KEYBOARD_VARIANT}"
XKBOPTIONS=""
BACKSPACE="guess"
EOF

# Timezone.
ln -sf "/usr/share/zoneinfo/${DEFAULT_TIMEZONE}" /etc/localtime || true
echo "${DEFAULT_TIMEZONE}" > /etc/timezone || true

# Hostname identity.
echo "aptura" > /etc/hostname

# Prefer Flatpak over Snap on Aptura: remove snapd if present and PREFER set.
if [ "${PREFER_FLATPAK_OVER_SNAP:-true}" = "true" ]; then
  if dpkg -l snapd >/dev/null 2>&1; then
    echo "[aptura][hook] removing snapd in favour of Flatpak"
    apt-get purge -y snapd || true
    apt-get autoremove -y || true
    # Block reinstallation pulling snapd back in.
    cat > /etc/apt/preferences.d/no-snapd <<'EOF'
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
  fi
fi
