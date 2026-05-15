# Aptura OS

Aptura OS is a Debian-based Linux distribution project scaffold for building a bootable live ISO with APT, local `.deb` packages, Calamares installer configuration, custom branding, and an Aptura-owned Wayland desktop called Aptura Shell.

This repository is an MVP foundation, not a finished public distribution. It is structured so you can grow it into a real derivative with signed package repositories, release engineering, QA, security review, and visual identity work.

## Why Debian Stable

Aptura OS uses Debian Stable as the default base. As of May 2026, Debian Stable is Debian 13 `trixie`. Debian is chosen because APT and `.deb` packages are first-class, live-build is the established Debian image construction tool, and Debian explicitly supports derivative distributions with their own identity, goals, and package customizations.

Ubuntu LTS can be added later by changing the base suite, mirrors, package names, and live image tooling. The first MVP stays on Debian to keep the build path reproducible and close to upstream Debian Live.

Relevant upstream references:

- Debian Live Manual: https://live-team.pages.debian.net/live-manual/html/live-manual.en.html
- Debian derivatives overview: https://www.debian.org/derivatives/
- Debian derivatives guidelines: https://wiki.debian.org/Derivatives/Guidelines
- Debian releases: https://www.debian.org/releases/
- Calamares documentation: https://calamares.io/docs/

## Target Users

Aptura OS targets technically curious desktop users, developers, and distribution builders who want a clean Debian-compatible desktop with practical workstation defaults, transparent package management, and a cohesive Aptura Shell experience.

## Features

- Debian Stable `trixie` base with APT.
- Reproducible live ISO workflow using live-build.
- Local APT repository generation for custom packages.
- Debian package skeletons for:
  - `aptura-meta`
  - `aptura-branding`
  - `aptura-desktop`
  - `aptura-settings`
- Calamares installer configuration with Aptura branding.
- Aptura Shell visual identity: custom Aptura logo assets, context-grid and retro-shell wallpapers, Aptura color assets, GTK fallback theme, pixel-like icons, Plymouth branding, Calamares branding, and shell identity metadata.
- Aptura System Check for local update, firmware, power, security, and disk status.
- Aptura Journey for local-only system events and user-visible system memory.
- Aptura Context for live/installed, VM, laptop, battery, network, boot, and storage cues.
- Aptura Shift for code, study, create, game, travel, and focus workstation rituals.
- Aptura Aftercare for post-update and post-install next steps.
- Aptura Live Bridge for live-session install readiness and local readiness reports.
- Aptura Safe Update for best-effort Timeshift snapshots before package upgrades.
- Aptura Rescue Center for boot, EFI, GRUB, disk, and installer recovery context.
- Aptura Privacy Check for firewall, exposed services, MAC privacy, and sockets.
- Aptura Modes for quick balanced, performance, battery, studio, and focus profiles.
- Aptura Support Bundle for redacted diagnostics archives that are easier to share.
- Useful desktop differentiators installed by default: Aptura Shell session, labwc, waybar, wofi, SDDM, Dolphin, Konsole, Kate, Synaptic, Flatpak support, firmware updates, power profiles, archive handling, backups, disk tools, Bluetooth, audio controls, and hardware switching support.
- Security defaults for AppArmor, UFW, signed APT repositories, no telemetry, and no SSH server by default.
- VM test helper for QEMU/KVM.
- Documentation for architecture, build, package management, security, releases, and roadmap.

## Requirements

Build on a Debian or Ubuntu host or in a clean VM/container with enough privileges for live-build.

Recommended host packages:

```bash
sudo apt update
sudo apt install --no-install-recommends \
  live-build \
  dpkg-dev \
  devscripts \
  debhelper \
  equivs \
  apt-utils \
  reprepro \
  squashfs-tools \
  xorriso \
  isolinux \
  syslinux-common \
  dosfstools \
  mtools \
  efibootmgr \
  cryptsetup \
  cryptsetup-initramfs \
  grub-common \
  grub2-common \
  grub-pc-bin \
  grub-efi-amd64-bin \
  qemu-system-x86 \
  qemu-utils \
  git \
  curl \
  wget \
  gnupg \
  ca-certificates
```

## Build

From the repository root:

```bash
./build.sh
```

The build performs these steps:

1. Render branding from `config/distro.env`, `config/branding.conf`, and optional local overrides.
2. Validate tools, config, package metadata, and repository layout.
3. Build the Aptura `.deb` packages.
4. Create a local APT repository under `build/localrepo`.
5. Optionally sign the repository if `SIGN_REPO=true`.
6. Build the live ISO with live-build.
7. Write the ISO and checksum to `dist/`.

The expected output is:

```text
dist/aptura-os-0.1.4.1-adeline-amd64.iso
dist/aptura-os-0.1.4.1-adeline-amd64.iso.sha256
```

## Branding

Tracked branding defaults live in `config/branding.conf`; tracked build identity
defaults live in `config/distro.env`. For private or machine-local overrides,
create `config/distro.local.env` or `config/branding.local.env`.

Run `./scripts/render-branding.sh` after changing names, URLs, colors, icon
theme names, wallpaper paths, Plymouth themes, or Calamares theme IDs. Full
builds run the renderer automatically before validation and package builds.

## Test In A VM

After building:

```bash
./scripts/test-vm.sh
```

Or pass a custom ISO path:

```bash
./scripts/test-vm.sh dist/aptura-os-0.1.4.1-adeline-amd64.iso
```

The helper uses QEMU/KVM if available and falls back to QEMU's configured acceleration chain.

## Validate

```bash
./scripts/validate.sh
./tests/smoke-test.sh
./tests/package-test.sh
```

On non-Linux hosts, validation can inspect the repository structure, but full ISO creation requires Linux because live-build needs Linux filesystem semantics, loop devices, and root privileges.

## Clean

```bash
./clean.sh
```

This removes only `build/` and `dist/` after checking that the resolved paths are inside the project root.

## Install ISO

The live ISO includes Calamares configuration for:

- Welcome and language selection.
- Keyboard and timezone.
- Automatic or manual partitioning.
- Optional encryption in the partitioning module.
- User creation.
- Bootloader installation with Debian-compatible GRUB EFI path handling.
- Summary and finish screens.

Partitioning is destructive when the user selects whole-disk installation. Always test in a VM first.

## Aptura Shell Desktop

Aptura Shell is the distro-owned default session. It uses `labwc` as a modern
Wayland stacking compositor and layers Aptura defaults around it: `waybar` for
the panel, `wofi` for the launcher, `swaybg` for the wallpaper, `mako` for
notifications, and Aptura scripts for session startup, mode switching, power
actions, and screenshots.

KDE Plasma stays installed from Debian `trixie` as a fallback session and as a
source of mature desktop applications such as Dolphin, Konsole, Kate, Discover,
Spectacle, and System Settings. This keeps the custom Aptura session small and
maintainable while preserving familiar tools.

## Project Structure

```text
config/       Distribution, APT, branding, and live-build templates.
hooks/        Chroot hooks run by live-build.
desktop/      Desktop branding notes, greeter notes, and wallpaper policy.
installer/    Calamares settings, module configs, and branding.
packages/     Debian source package skeletons for Aptura packages.
scripts/      Build, repository, signing, VM, and validation helpers.
docs/         Architecture, build, desktop, security, package, and release docs.
tests/        Repository smoke tests and manual ISO test checklist.
```

## Known Limitations

- This is an MVP scaffold. It has not produced a verified release ISO in this Windows-hosted workspace.
- Secure Boot is documented but not implemented.
- Repository signing requires a real GPG key and release infrastructure.
- Aptura Shell uses Debian `trixie` labwc/wlroots ecosystem packages; production still needs signed Aptura repository infrastructure for Aptura-owned packages.
- Aptura Shell branding, GTK fallback theme, icon theme, panel, launcher, and wallpaper still need visual QA on a real booted ISO.
- Calamares module paths and package names may need adjustment for the exact Debian point release.
- Proprietary firmware is not bundled beyond Debian's `non-free-firmware` archive area.

## Roadmap

The roadmap is documented in `docs/roadmap.md`. The next practical milestones are:

- Build the ISO in a clean Debian 13 VM.
- Verify Calamares installation end to end.
- Verify Aptura Shell defaults, contextual UX tools, firmware tooling, and power profiles in a live session.
- Add signed public package repository infrastructure.
- Add automated VM boot tests.
- Add more wallpaper, icon, and accessibility variants under an open license.
