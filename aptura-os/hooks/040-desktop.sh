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

configure_sddm() {
  local service_path=""
  local candidate

  command -v sddm >/dev/null 2>&1 || return 0

  for candidate in /lib/systemd/system/sddm.service /usr/lib/systemd/system/sddm.service; do
    if [[ -f "${candidate}" ]]; then
      service_path="${candidate}"
      break
    fi
  done

  [[ -n "${service_path}" ]] || return 0

  install -d -m 0755 /etc/X11 /etc/sddm.conf.d /etc/systemd/system
  printf '/usr/bin/sddm\n' > /etc/X11/default-display-manager
  ln -sf "${service_path}" /etc/systemd/system/display-manager.service

  cat > /etc/sddm.conf.d/10-aptura.conf <<'EOF'
[General]
Session=aptura

[Theme]
Current=breeze
EOF

  enable_service sddm.service
  enable_service display-manager.service
}

log "Configuring Aptura Shell session and installer launcher"

enable_service NetworkManager.service
enable_service bluetooth.service
enable_service power-profiles-daemon.service
enable_service switcheroo-control.service
enable_service fwupd-refresh.timer
enable_service cups.service
enable_service cups-browsed.service
enable_service ipp-usb.service

configure_sddm

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

if [[ -f /usr/share/wayland-sessions/aptura.desktop ]]; then
  install -d -m 0755 /var/lib/AccountsService/users
  cat > /var/lib/AccountsService/users/aptura <<'EOF'
[User]
Session=aptura
Icon=/usr/share/pixmaps/aptura.svg
SystemAccount=false
EOF
fi

log "Aptura Shell desktop configuration complete"
