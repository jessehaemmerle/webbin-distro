# Architecture

## Overview

Aptura OS is a Debian Stable derivative built around APT, Debian packages,
live-build images, Calamares installation, and an Aptura-tuned Plasma desktop.

The project follows a layered model:

1. Upstream Debian Stable provides kernel, base system, APT, systemd, and security updates.
2. Aptura packages add identity, defaults, desktop integration, and release policy.
3. Aptura uses Debian `trixie` KDE Plasma packages directly for the default desktop.
4. live-build composes a bootable live ISO using Debian package repositories and local Aptura packages.
5. Calamares installs the live system to disk.
6. Aptura's Plasma defaults provide retro branding, privacy posture, useful workstation tools, and local status visibility.

## Base Distribution

Default base:

- Family: Debian
- Suite: `trixie`
- Architecture: `amd64`
- Package manager: APT
- Package format: `.deb`

Debian Stable is preferred because it provides a predictable support window,
signed APT repositories, a mature packaging policy, and live-build support.
Ubuntu LTS remains a possible later target but requires separate package lists,
installer tuning, and image tooling validation.

## Package Structure

Custom packages are native Debian packages:

- `aptura-meta`: top-level dependency package for default installs.
- `aptura-branding`: wallpapers, logo assets, GTK fallback theme, icon theme, Aptura color assets, Plymouth, GRUB, and derivative identity metadata.
- `aptura-desktop`: Aptura Plasma integration, Welcome, System Check launcher, and desktop package set.
- `aptura-settings`: security, update, privacy, NetworkManager, journald, and policy defaults.

The metapackage approach keeps package selection declarative. Instead of
hard-coding every package in installer scripts, Aptura can evolve defaults by
updating package dependencies.

## ISO Build Process

`build.sh` orchestrates:

1. `scripts/validate.sh`
2. `scripts/build-packages.sh`
3. `scripts/create-local-repo.sh`
4. `scripts/sign-repo.sh` when enabled
5. `scripts/build-iso.sh`

`scripts/build-iso.sh` copies `config/live-build/config` to `build/live-build`,
injects package lists, local `.deb` files, hooks, APT sources, and Calamares
configuration, then runs live-build.

Local packages are currently injected with `config/packages.chroot/*.deb`.
The local repository is still generated because it models the future update
infrastructure and can be used by installed systems after signing is complete.

## Desktop Components

Aptura does not ship a full desktop environment from scratch. The MVP uses:

- KDE Plasma session, KWin compositor, Plasma panel/widgets, application
  launcher, System Settings, core KDE apps, and xdg-desktop-portal-kde.
- SDDM as the login/display manager.
- Aptura Plasma branding through wallpaper, logo assets, icon theme, GTK
  fallback theme, Plymouth, Calamares artwork, and Aptura color assets.
- Aptura System Check as a local status tool for updates, firmware, power,
  security, and storage.
- Dolphin, Konsole, Kate, Synaptic, Flatpak support,
  firmware updates, power profiles, archive, backup, disk, audio, Bluetooth,
  and hardware switching tools.

This keeps the system realistic while still giving Aptura OS a distinct visual
language and a useful first-boot workstation baseline.

## Installer

Calamares is configured under `installer/calamares`.

Important modules:

- `welcome`
- `locale`
- `keyboard`
- `timezone`
- `partition`
- `users`
- `summary`
- `mount`
- `unpackfs`
- `fstab`
- `displaymanager`
- `services-systemd`
- `grubcfg`
- `bootloader`
- `packages`
- `luksbootkeyfile`
- `initramfscfg`
- `initramfs`
- `finished`

The installer supports whole-disk installation, manual partitioning, and a
documented encryption path. Every partitioning mode must be tested in disposable
VM disks before a public release.

## Update Model

MVP update sources:

- Debian `trixie`
- Debian `trixie-updates`
- Debian `trixie-security`
- Debian `trixie` KDE Plasma packages
- Local Aptura packages during ISO build

Production update model:

- Signed Aptura repository.
- Release channels such as stable, testing, and nightly.
- Explicit pinning policy for Aptura packages.
- Signed Aptura repository for Aptura-owned packages.
- Reproducible package builds and published checksums.

## Trust Boundaries

Primary trust boundaries:

- APT repository signatures.
- Calamares privileged installation steps.
- PolicyKit administrative actions.
- D-Bus interfaces used by future Aptura services.
- User session versus system services.

Privileged desktop actions should never be performed directly by the frontend.
They must go through audited system services and PolicyKit.
