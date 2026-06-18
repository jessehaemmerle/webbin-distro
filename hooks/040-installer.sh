#!/bin/sh
# Chroot hook: install the Aptura Calamares config + branding into the image.
# The actual files are staged into /usr/share/aptura/installer by build-iso.sh
# (copied from installer/calamares) before this hook runs.
set -e

echo "[aptura][hook] 040 installer"

SRC=/usr/share/aptura/installer
if [ -d "$SRC" ]; then
  mkdir -p /etc/calamares /usr/share/calamares/branding
  cp -a "$SRC/settings.conf" /etc/calamares/settings.conf
  cp -a "$SRC/modules" /etc/calamares/
  cp -a "$SRC/branding/aptura" /usr/share/calamares/branding/

  # Desktop launcher so the installer is one click away in the live session.
  cat > /usr/share/applications/aptura-install.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Install Aptura OS
Comment=Install Aptura OS to this computer
Exec=pkexec calamares
Icon=logo
Terminal=false
Categories=System;
EOF
else
  echo "[aptura][hook] WARNING: $SRC missing; Calamares config not installed"
fi
