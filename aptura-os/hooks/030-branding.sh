#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[030-branding] %s\n' "$*"
}

log "Applying Aptura OS branding"

cat > /etc/os-release <<'EOF'
PRETTY_NAME="Aptura OS 0.1 Classic XFCE"
NAME="Aptura OS"
VERSION_ID="0.1"
VERSION="0.1 (Classic XFCE)"
VERSION_CODENAME=trixie
ID=aptura
ID_LIKE=debian
VARIANT="Classic XFCE"
VARIANT_ID=classic-xfce
LOGO=distributor-logo-aptura
ANSI_COLOR="1;36"
HOME_URL="https://aptura.local"
SUPPORT_URL="https://aptura.local/support"
BUG_REPORT_URL="https://aptura.local/issues"
PRIVACY_POLICY_URL="https://aptura.local/privacy"
EOF

cat > /etc/lsb-release <<'EOF'
DISTRIB_ID=Aptura
DISTRIB_RELEASE=0.1
DISTRIB_CODENAME=trixie
DISTRIB_DESCRIPTION="Aptura OS 0.1 Classic XFCE"
EOF

cat > /etc/issue <<'EOF'
Aptura OS 0.1 Classic XFCE \n \l
EOF

cat > /etc/issue.net <<'EOF'
Aptura OS 0.1 Classic XFCE
EOF

cat > /etc/machine-info <<'EOF'
PRETTY_HOSTNAME=Aptura OS
ICON_NAME=distributor-logo-aptura
CHASSIS=desktop
EOF

install -d -m 0755 /etc/aptura
cat > /etc/aptura/branding.conf <<'EOF'
DISTRO_NAME="Aptura OS"
DESKTOP_NAME="Aptura Classic XFCE"
DISTRO_VERSION="0.1"
DISTRO_CODENAME="trixie"
THEME_NAME="Aptura-Classic"
ICON_THEME_NAME="Aptura-Classic"
LOGO_NAME="distributor-logo-aptura"
ACCENT_COLOR="#000080"
SECONDARY_ACCENT_COLOR="#008080"
WARNING_COLOR="#ffff00"
SURFACE_COLOR="#c0c0c0"
HOME_URL="https://aptura.local"
SUPPORT_URL="https://aptura.local/support"
DEFAULT_MODE="classic"
EOF

install -d -m 0755 /etc/motd.d /etc/profile.d
cat > /etc/motd.d/00-aptura <<'EOF'
Aptura OS 0.1 Classic XFCE
Debian-compatible workstation with Aptura branding, defaults, and tooling.
EOF

cat > /etc/profile.d/aptura-branding.sh <<'EOF'
export APTURA_BRAND_NAME="Aptura OS"
export APTURA_BRAND_EDITION="Classic XFCE"
export APTURA_BRAND_ACCENT="#000080"
EOF

if command -v update-alternatives >/dev/null 2>&1 && [[ -f /usr/share/backgrounds/aptura/aptura-default.svg ]]; then
  update-alternatives --install /usr/share/images/desktop-base/desktop-background desktop-background /usr/share/backgrounds/aptura/aptura-default.svg 80 || true
fi

if command -v plymouth-set-default-theme >/dev/null 2>&1 && [[ -d /usr/share/plymouth/themes/aptura ]]; then
  plymouth-set-default-theme aptura || true
fi

log "Branding complete"
