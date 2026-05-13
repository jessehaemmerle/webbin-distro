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

log "Configuring Aptura Classic XFCE session and installer launcher"

enable_service NetworkManager.service
enable_service bluetooth.service
enable_service lightdm.service
enable_service power-profiles-daemon.service
enable_service switcheroo-control.service
enable_service fwupd-refresh.timer

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

install -d -m 0755 /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/50-aptura-session.conf <<'EOF'
[Seat:*]
user-session=xfce
greeter-session=lightdm-gtk-greeter
EOF

install -d -m 0755 /etc/lightdm/lightdm-gtk-greeter.conf.d
cat > /etc/lightdm/lightdm-gtk-greeter.conf.d/50-aptura-classic.conf <<'EOF'
[greeter]
theme-name=Aptura-Classic
icon-theme-name=Aptura-Classic
font-name=Sans 10
background=/usr/share/backgrounds/aptura/aptura-default.svg
user-background=false
xft-antialias=false
indicators=~host;~spacer;~clock;~spacer;~language;~session;~a11y;~power
EOF

if [[ -f /usr/share/xsessions/xfce.desktop ]]; then
  install -d -m 0755 /var/lib/AccountsService/users
  cat > /var/lib/AccountsService/users/aptura <<'EOF'
[User]
Session=xfce
Icon=/usr/share/pixmaps/aptura.svg
SystemAccount=false
EOF
fi

log "Desktop configuration complete"
