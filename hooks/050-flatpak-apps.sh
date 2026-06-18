#!/bin/sh
# Chroot hook: wire up Flatpak/Flathub and queue Spotify (not in APT).
set -e

echo "[aptura][hook] 050 flatpak apps"

if [ "${ENABLE_FLATPAK:-true}" != "true" ]; then
  echo "[aptura][hook] flatpak disabled; skipping"
  exit 0
fi

if command -v flatpak >/dev/null 2>&1; then
  flatpak remote-add --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo || true

  # Installing Flatpaks needs a configured network + running session, which is
  # not guaranteed inside the build chroot. Queue Spotify for first boot via a
  # oneshot systemd unit that self-disables once it succeeds.
  cat > /etc/systemd/system/aptura-firstboot-flatpaks.service <<'EOF'
[Unit]
Description=Aptura first-boot Flatpak installation (Spotify)
After=network-online.target
Wants=network-online.target
ConditionPathExists=!/var/lib/aptura/flatpaks-done

[Service]
Type=oneshot
ExecStart=/usr/bin/flatpak install -y --noninteractive flathub com.spotify.Client
ExecStartPost=/bin/sh -c 'mkdir -p /var/lib/aptura && touch /var/lib/aptura/flatpaks-done && systemctl disable aptura-firstboot-flatpaks.service'

[Install]
WantedBy=multi-user.target
EOF
  systemctl enable aptura-firstboot-flatpaks.service || true
else
  echo "[aptura][hook] flatpak not installed; skipping"
fi
