#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[030-branding] %s\n' "$*"
}

log "Applying Aptura OS branding"

cat > /etc/os-release <<'EOF'
PRETTY_NAME="Aptura OS 0.1"
NAME="Aptura OS"
VERSION_ID="0.1"
VERSION="0.1 (flow)"
VERSION_CODENAME=flow
ID=aptura
ID_LIKE=debian
HOME_URL="https://example.invalid/aptura"
SUPPORT_URL="https://example.invalid/aptura/support"
BUG_REPORT_URL="https://example.invalid/aptura/issues"
PRIVACY_POLICY_URL="https://example.invalid/aptura/privacy"
EOF

install -d -m 0755 /etc/aptura
cat > /etc/aptura/branding.conf <<'EOF'
DISTRO_NAME="Aptura OS"
DESKTOP_NAME="Aptura Flow"
ACCENT_COLOR="#18a999"
DEFAULT_MODE="dark"
EOF

if command -v update-alternatives >/dev/null 2>&1 && [[ -f /usr/share/backgrounds/aptura/aptura-default.svg ]]; then
  update-alternatives --install /usr/share/images/desktop-base/desktop-background desktop-background /usr/share/backgrounds/aptura/aptura-default.svg 80 || true
fi

if command -v plymouth-set-default-theme >/dev/null 2>&1 && [[ -d /usr/share/plymouth/themes/aptura ]]; then
  plymouth-set-default-theme aptura || true
fi

log "Branding complete"
