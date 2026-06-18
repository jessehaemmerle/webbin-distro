#!/bin/sh
# Chroot hook: groups and live-session defaults.
# The persistent user is created by Calamares at install time; casper provides
# the live user. Here we just ensure useful groups and sudo policy exist.
set -e

echo "[aptura][hook] 020 users and groups"

for grp in netdev plugdev bluetooth video audio; do
  getent group "$grp" >/dev/null 2>&1 || groupadd --system "$grp" || true
done

# Ensure members of sudo get admin rights (Ubuntu default, asserted here).
if [ ! -f /etc/sudoers.d/aptura ]; then
  echo "%sudo ALL=(ALL:ALL) ALL" > /etc/sudoers.d/aptura
  chmod 0440 /etc/sudoers.d/aptura
fi
