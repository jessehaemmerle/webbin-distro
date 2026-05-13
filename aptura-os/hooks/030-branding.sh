#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[030-branding] %s\n' "$*"
}

log "Applying Aptura OS branding"

cat > /etc/os-release <<'EOF'
PRETTY_NAME="Aptura OS 0.1.4 Adeline COSMIC"
NAME="Aptura OS"
VERSION_ID="0.1.4"
VERSION="0.1.4 (Adeline COSMIC)"
VERSION_CODENAME=adeline
ID=aptura
ID_LIKE=debian
VARIANT="COSMIC"
VARIANT_ID=cosmic
LOGO=distributor-logo-aptura
ANSI_COLOR="1;36"
HOME_URL="https://aptura.local"
SUPPORT_URL="https://aptura.local/support"
BUG_REPORT_URL="https://aptura.local/issues"
PRIVACY_POLICY_URL="https://aptura.local/privacy"
EOF

cat > /etc/lsb-release <<'EOF'
DISTRIB_ID=Aptura
DISTRIB_RELEASE=0.1.4
DISTRIB_CODENAME=adeline
DISTRIB_DESCRIPTION="Aptura OS 0.1.4 Adeline COSMIC"
EOF

cat > /etc/issue <<'EOF'
Aptura OS 0.1.4 Adeline COSMIC \n \l
EOF

cat > /etc/issue.net <<'EOF'
Aptura OS 0.1.4 Adeline COSMIC
EOF

cat > /etc/machine-info <<'EOF'
PRETTY_HOSTNAME=Aptura OS
ICON_NAME=distributor-logo-aptura
CHASSIS=desktop
EOF

install -d -m 0755 /etc/aptura
cat > /etc/aptura/branding.conf <<'EOF'
DISTRO_NAME="Aptura OS"
DESKTOP_NAME="Aptura COSMIC"
DISTRO_VERSION="0.1.4"
DISTRO_CODENAME="adeline"
THEME_NAME="Aptura-COSMIC"
ICON_THEME_NAME="Aptura-COSMIC"
LOGO_NAME="distributor-logo-aptura"
ACCENT_COLOR="#00d9c0"
SECONDARY_ACCENT_COLOR="#ff4fd8"
WARNING_COLOR="#ffe45c"
SURFACE_COLOR="#c8c6bc"
HOME_URL="https://aptura.local"
SUPPORT_URL="https://aptura.local/support"
DEFAULT_MODE="cosmic"
EOF

install -d -m 0755 /etc/motd.d /etc/profile.d
cat > /etc/motd.d/00-aptura <<'EOF'
Aptura OS 0.1.4 Adeline COSMIC
Debian-compatible workstation with COSMIC, Aptura branding, defaults, and tooling.
EOF

cat > /etc/profile.d/aptura-branding.sh <<'EOF'
export APTURA_BRAND_NAME="Aptura OS"
export APTURA_BRAND_EDITION="COSMIC"
export APTURA_BRAND_ACCENT="#00d9c0"
EOF

if command -v update-alternatives >/dev/null 2>&1 && [[ -f /usr/share/backgrounds/aptura/aptura-retro-cosmic.svg ]]; then
  update-alternatives --install /usr/share/images/desktop-base/desktop-background desktop-background /usr/share/backgrounds/aptura/aptura-retro-cosmic.svg 90 || true
fi

if command -v plymouth-set-default-theme >/dev/null 2>&1 && [[ -d /usr/share/plymouth/themes/aptura ]]; then
  plymouth-set-default-theme aptura || true
fi

log "Branding complete"
