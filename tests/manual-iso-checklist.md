# Manual ISO test checklist

Run on a Linux host after `./build.sh` produces an ISO, using
`scripts/test-vm.sh` (boots a throwaway QEMU disk).

## Boot & branding
- [ ] GRUB shows the Aptura theme and "Aptura OS" entry.
- [ ] Plymouth shows the Aptura splash.
- [ ] SDDM greeter shows Aptura theme; default session is "Aptura Shell".
- [ ] `cat /etc/os-release` shows Aptura NAME/PRETTY_NAME.

## Custom kernel
- [ ] `uname -r` ends in `-aptura`.
- [ ] `uname -v` / `dmesg` show the expected version.

## Aptura Shell desktop
- [ ] labwc session starts; waybar panel, wallpaper, notifications present.
- [ ] Super+D launcher, Super+Return terminal, Print screenshot work.
- [ ] Tray shows network/Bluetooth/audio; power menu works.

## Everyday apps
- [ ] LibreOffice, Thunderbird launch.
- [ ] Firefox launches and is the **.deb** build (Help → About; not snap).
- [ ] GNOME Software opens; Flathub is configured.
- [ ] After first boot + network, Spotify Flatpak auto-installs.

## Install (Calamares)
- [ ] "Install Aptura OS" launcher opens Calamares with Aptura branding.
- [ ] Erase-disk install completes on the throwaway VM disk.
- [ ] Optional LUKS encryption path completes.
- [ ] Installed system reboots, boots the Aptura kernel, reaches SDDM.

## Security defaults
- [ ] `aa-status` shows AppArmor enforcing.
- [ ] `sudo ufw status` shows active, default-deny incoming.
- [ ] No `openssh-server`, no `snapd`, no telemetry packages installed.
