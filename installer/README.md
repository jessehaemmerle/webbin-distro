# Aptura OS installer (Calamares)

Calamares is configured for an **Ubuntu** live image with Aptura branding.

## Layout

- `settings.conf` — module sequence (show/exec) and active branding.
- `modules/*.conf` — per-module configuration, tuned for Ubuntu paths:
  - `unpackfs.conf` sources `/cdrom/casper/filesystem.squashfs` (casper, not
    Debian live-boot).
  - `bootloader.conf` / `grubcfg.conf` install GRUB with the Aptura EFI id and
    the Aptura GRUB theme.
  - `displaymanager.conf` selects SDDM + the `aptura-session` desktop.
  - `services-systemd.conf` enables SDDM, NetworkManager, AppArmor, UFW,
    power-profiles-daemon, fwupd.
  - `packages.conf` removes the live-only tooling after install (APT backend).
  - `partition.conf` offers erase/manual, optional LUKS2, ext4 or Btrfs.
- `branding/aptura/` — `branding.desc`, slideshow (`show.qml`), `stylesheet.qss`,
  `welcome.svg`. `logo.svg` is copied in from `branding/assets/logo.svg` by the
  build.

## How it reaches the live system

`hooks/040-installer.sh` copies this directory into the live filesystem at
`/etc/calamares/` (settings + modules) and
`/usr/share/calamares/branding/aptura/` (branding), and drops a desktop launcher
so the installer is one click away in the live session.

## Destructive operations

Whole-disk installs erase the target disk. Always test in a throwaway VM disk
(`scripts/test-vm.sh`) before installing on real hardware.
