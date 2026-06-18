#!/bin/sh
# Chroot hook: shrink the image.
set -e

echo "[aptura][hook] 070 cleanup"

apt-get autoremove -y || true
apt-get clean || true
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* || true
rm -f /var/cache/ldconfig/aux-cache || true
# Truncate machine-id so each install gets a fresh one.
: > /etc/machine-id || true
