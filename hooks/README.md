# Chroot hooks

Canonical sources for the hooks that run **inside the live-build chroot** as
root, in numeric order. `scripts/build-iso.sh` copies each `0xx-name.sh` into
the live-build tree as `config/hooks/normal/0xx-name.hook.chroot`.

| Hook                     | Purpose                                              |
|--------------------------|------------------------------------------------------|
| `010-base-system.sh`     | Locale, hostname, remove snapd (prefer Flatpak).     |
| `020-users-and-groups.sh`| Groups + sudo policy (install-time user via Calamares).|
| `030-branding.sh`        | Plymouth default theme, logo raster, `update-grub`.  |
| `040-installer.sh`       | Install Calamares config/branding + launcher.        |
| `050-flatpak-apps.sh`    | Flathub remote + first-boot Spotify Flatpak unit.    |
| `060-security.sh`        | Remove SSH/telemetry, enable AppArmor/auto-updates.  |
| `070-cleanup.sh`         | Trim caches, reset machine-id.                       |

Keep hooks POSIX `sh`, idempotent, and tolerant of missing tools (use
`|| true`) — the chroot environment is minimal. They read exported build
variables such as `PREFER_FLATPAK_OVER_SNAP` and `ENABLE_FLATPAK` from
`config/distro.env`, which `build-iso.sh` passes through.
