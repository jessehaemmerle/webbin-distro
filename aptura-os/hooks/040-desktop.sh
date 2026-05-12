#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[040-desktop] %s\n' "$*"
}

enable_service() {
  local service="$1"
  if command -v systemctl >/dev/null 2>&1; then
    systemctl enable "${service}" >/dev/null 2>&1 || true
  fi
}

log "Configuring desktop session and installer launcher"

enable_service NetworkManager.service
enable_service bluetooth.service
enable_service gdm3.service

install -d -m 0755 /usr/share/applications
cat > /usr/share/applications/calamares.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Install Aptura OS
Comment=Install Aptura OS to disk
Exec=pkexec calamares
Icon=calamares
Terminal=false
Categories=System;
StartupNotify=true
EOF

install -d -m 0755 /etc/xdg/autostart
cat > /etc/xdg/autostart/aptura-flow.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Aptura Flow
Exec=aptura-flow --dashboard
OnlyShowIn=GNOME;
X-GNOME-Autostart-enabled=true
EOF

if [[ -f /usr/share/xsessions/gnome.desktop ]]; then
  install -d -m 0755 /var/lib/AccountsService/users
  cat > /var/lib/AccountsService/users/aptura <<'EOF'
[User]
Session=gnome
Icon=/usr/share/pixmaps/aptura.svg
SystemAccount=false
EOF
fi

log "Desktop configuration complete"
