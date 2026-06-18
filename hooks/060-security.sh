#!/bin/sh
# Chroot hook: assert security posture in the image.
set -e

echo "[aptura][hook] 060 security"

# No SSH server by default on a desktop.
if dpkg -l openssh-server >/dev/null 2>&1; then
  apt-get purge -y openssh-server || true
fi

# Enable AppArmor + unattended-upgrades units (UFW is enabled by
# aptura-settings postinst, which also sets default-deny incoming).
systemctl enable apparmor.service 2>/dev/null || true
systemctl enable unattended-upgrades.service 2>/dev/null || true

# Disable any telemetry packages that may have been pulled in.
for pkg in popularity-contest apport whoopsie; do
  dpkg -l "$pkg" >/dev/null 2>&1 && apt-get purge -y "$pkg" || true
done
