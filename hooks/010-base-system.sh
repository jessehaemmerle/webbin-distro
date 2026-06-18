#!/bin/sh
# Chroot hook: base system tweaks for the live/installed image.
# Runs inside the live-build chroot as root.
set -e

echo "[aptura][hook] 010 base system"

# Default locale and timezone (installer lets the user change both).
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen || true
locale-gen || true
update-locale LANG=en_US.UTF-8 || true

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
