#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[050-security] %s\n' "$*"
}

enable_service() {
  local service="$1"
  if command -v systemctl >/dev/null 2>&1; then
    systemctl enable "${service}" >/dev/null 2>&1 || true
  fi
}

disable_service() {
  local service="$1"
  if command -v systemctl >/dev/null 2>&1; then
    systemctl disable "${service}" >/dev/null 2>&1 || true
  fi
}

log "Applying security defaults"

enable_service apparmor.service
disable_service ssh.service
disable_service sshd.service

if command -v ufw >/dev/null 2>&1; then
  ufw --force reset >/dev/null 2>&1 || true
  ufw default deny incoming >/dev/null 2>&1 || true
  ufw default allow outgoing >/dev/null 2>&1 || true
  # Intentionally not enabling UFW in the MVP live session. See docs/security.md.
fi

install -d -m 0755 /etc/apt/apt.conf.d
cat > /etc/apt/apt.conf.d/51aptura-security <<'EOF'
APT::Periodic::Enable "1";
APT::Periodic::Update-Package-Lists "1";
APT::Get::AllowUnauthenticated "false";
Acquire::AllowInsecureRepositories "false";
Acquire::AllowDowngradeToInsecureRepositories "false";
EOF

cat > /etc/apt/apt.conf.d/52aptura-privacy <<'EOF'
Acquire::Languages "none";
APT::Install-Recommends "true";
APT::Install-Suggests "false";
EOF

log "Security defaults complete"
