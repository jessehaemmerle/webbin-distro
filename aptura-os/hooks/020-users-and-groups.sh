#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[020-users-and-groups] %s\n' "$*"
}

LIVE_USER="${LIVE_USER:-aptura}"

log "Configuring live user policy for ${LIVE_USER}"

install -d -m 0750 /etc/sudoers.d
cat > /etc/sudoers.d/aptura-admin <<'EOF'
%sudo ALL=(ALL:ALL) ALL
EOF
chmod 0440 /etc/sudoers.d/aptura-admin

if id "${LIVE_USER}" >/dev/null 2>&1; then
  usermod -aG sudo,audio,video,plugdev,netdev "${LIVE_USER}" || true
else
  log "Live user does not exist yet; live-config will create it during boot"
fi

passwd -l root >/dev/null 2>&1 || true

log "User and group policy complete"
