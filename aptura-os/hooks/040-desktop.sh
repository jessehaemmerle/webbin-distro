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

log "Configuring Aptura COSMIC session and installer launcher"

enable_service NetworkManager.service
enable_service bluetooth.service
enable_service power-profiles-daemon.service
enable_service switcheroo-control.service
enable_service fwupd-refresh.timer
enable_service cups.service
enable_service cups-browsed.service
enable_service ipp-usb.service

if [[ -f /usr/lib/systemd/system/cosmic-greeter.service || -f /lib/systemd/system/cosmic-greeter.service ]]; then
  enable_service cosmic-greeter.service
  enable_service cosmic-greeter-daemon.service
else
  enable_service greetd.service
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl set-default graphical.target >/dev/null 2>&1 || true
fi

install -d -m 0755 /usr/share/applications
cat > /usr/share/applications/calamares.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Install Aptura OS
Comment=Install Aptura OS to disk
Exec=pkexec calamares
Icon=distributor-logo-aptura
Terminal=false
Categories=System;
StartupNotify=true
EOF

install -d -m 0755 /etc/greetd
cat > /etc/greetd/cosmic-greeter.toml <<'EOF'
[terminal]
vt = "1"

[general]
service = "cosmic-greeter"

[default_session]
command = "cosmic-greeter-start"
user = "cosmic-greeter"
EOF

if [[ -f /usr/share/wayland-sessions/cosmic.desktop || -f /usr/share/xsessions/cosmic.desktop ]]; then
  install -d -m 0755 /var/lib/AccountsService/users
  cat > /var/lib/AccountsService/users/aptura <<'EOF'
[User]
Session=cosmic
Icon=/usr/share/pixmaps/aptura.svg
SystemAccount=false
EOF
fi

log "COSMIC desktop configuration complete"
