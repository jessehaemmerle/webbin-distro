#!/bin/sh
# Chroot hook: activate Aptura branding inside the image.
set -e

echo "[aptura][hook] 030 branding"

# Rasterise the logo for Plymouth/GRUB if a converter is available (the SVG is
# the source of truth shipped by aptura-branding).
if command -v rsvg-convert >/dev/null 2>&1; then
  mkdir -p /usr/share/plymouth/themes/aptura
  rsvg-convert -w 256 -h 256 \
    /usr/share/icons/hicolor/scalable/apps/logo.svg \
    -o /usr/share/plymouth/themes/aptura/logo.png || true
fi

# Make the Aptura Plymouth theme the default boot splash.
if command -v plymouth-set-default-theme >/dev/null 2>&1; then
  plymouth-set-default-theme -R aptura || plymouth-set-default-theme aptura || true
fi

# Regenerate GRUB config so the Aptura theme/distributor name take effect.
update-grub 2>/dev/null || true

# Default wallpaper for the live session (installed systems inherit via skel).
mkdir -p /etc/skel/.config
