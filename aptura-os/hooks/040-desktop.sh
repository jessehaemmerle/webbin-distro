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

configure_cosmic_greeter() {
  local service_path=""
  local candidate

  [[ -x /usr/bin/cosmic-greeter-start ]] || return 0

  for candidate in /lib/systemd/system/cosmic-greeter.service /usr/lib/systemd/system/cosmic-greeter.service; do
    if [[ -f "${candidate}" ]]; then
      service_path="${candidate}"
      break
    fi
  done

  [[ -n "${service_path}" ]] || return 0

  install -d -m 0755 /etc/X11 /etc/greetd /etc/systemd/system
  printf 'cosmic-greeter\n' > /etc/X11/default-display-manager
  ln -sf "${service_path}" /etc/systemd/system/display-manager.service

  cat > /etc/greetd/cosmic-greeter.toml <<'EOF'
[terminal]
vt = "1"

[general]
service = "cosmic-greeter"

[default_session]
command = "cosmic-greeter-start"
user = "cosmic-greeter"
EOF

  enable_service cosmic-greeter-daemon.service
  enable_service display-manager.service
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

configure_cosmic_greeter

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
