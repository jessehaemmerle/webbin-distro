# Architecture

## Overview

Aptura OS is a Debian Stable derivative built around APT, Debian packages,
live-build images, Calamares installation, and an Aptura-tuned XFCE desktop.

The project follows a layered model:

1. Upstream Debian Stable provides kernel, base system, APT, systemd, XFCE, and security updates.
2. Aptura packages add identity, defaults, desktop integration, and release policy.
3. live-build composes a bootable live ISO using Debian package repositories and local Aptura packages.
4. Calamares installs the live system to disk.
5. Aptura's XFCE defaults provide classic branding, privacy posture, useful workstation tools, and local status visibility.

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
- `aptura-branding`: classic wallpaper, GTK theme, XFWM4 borders, icon theme, Plymouth, login theme, and derivative identity metadata.
- `aptura-desktop`: Aptura Classic XFCE integration, System Check launcher, and desktop package set.
- `aptura-settings`: security, update, privacy, XFCE, and policy defaults.

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

- XFCE session, xfwm4, xfdesktop, xfce4-panel, and LightDM.
- Aptura Classic branding through wallpaper, GTK theme, XFWM4 window borders,
  icon theme, LightDM styling, bottom panel, and XFCE defaults.
- Aptura System Check as a local status tool for updates, firmware, power,
  security, and storage.
- Thunar, Synaptic, Flatpak support, firmware updates, power profiles, archive,
  image, task, audio, Bluetooth, and hardware switching tools.

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
- `bootloader`
- `finished`

The installer supports whole-disk installation, manual partitioning, and a
documented encryption path. Every partitioning mode must be tested in disposable
VM disks before a public release.

## Update Model

MVP update sources:

- Debian `trixie`
- Debian `trixie-updates`
- Debian `trixie-security`
- Local Aptura packages during ISO build

Production update model:

- Signed Aptura repository.
- Release channels such as stable, testing, and nightly.
- Explicit pinning policy for Aptura packages.
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
