# Aptura OS

Aptura OS is a Debian-based Linux distribution project scaffold for building a bootable live ISO with APT, local `.deb` packages, Calamares installer configuration, custom branding, and a prototype desktop layer named **Aptura Flow**.

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

Aptura OS targets technically curious desktop users, developers, and distribution builders who want a clean Debian-based desktop with a productivity-oriented interface and transparent package management. The project also serves as a learning and prototyping base for derivative distribution engineering.

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
- Aptura Flow packaged as a local system app, plus a Vite/React prototype for iteration.
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

For the Aptura Flow prototype:

```bash
sudo apt install nodejs npm
```

## Build

From the repository root:

```bash
./build.sh
```

The build performs these steps:

1. Validate tools, config, package metadata, and repository layout.
2. Build the Aptura `.deb` packages.
3. Create a local APT repository under `build/localrepo`.
4. Optionally sign the repository if `SIGN_REPO=true`.
5. Build the live ISO with live-build.
6. Write the ISO and checksum to `dist/`.

The expected output is:

```text
dist/aptura-os-0.1.0-trixie-amd64.iso
dist/aptura-os-0.1.0-trixie-amd64.iso.sha256
```

## Test In A VM

After building:

```bash
./scripts/test-vm.sh
```

Or pass a custom ISO path:

```bash
./scripts/test-vm.sh dist/aptura-os-0.1.0-trixie-amd64.iso
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

## Aptura Flow

Aptura Flow is the custom UX layer. The MVP uses GNOME Shell as the stable compositor/session base and installs Aptura Flow as a packaged system app under `/usr/share/aptura-flow`. The Vite/React shell remains available for faster UX iteration and can later replace the static runtime or move into a native WebView/Tauri component, GNOME extension companion app, or system settings surface.

Run the prototype:

```bash
cd desktop/shell
npm install
npm run dev
```

## Project Structure

```text
config/       Distribution, APT, branding, and live-build templates.
hooks/        Chroot hooks run by live-build.
desktop/      Aptura Flow shell prototype and desktop assets.
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
- Aptura Flow is packaged as an unprivileged system app, not yet a privileged desktop shell.
- Calamares module paths and package names may need adjustment for the exact Debian point release.
- Proprietary firmware is not bundled beyond Debian's `non-free-firmware` archive area.

## Roadmap

The roadmap is documented in `docs/roadmap.md`. The next practical milestones are:

- Build the ISO in a clean Debian 13 VM.
- Verify Calamares installation end to end.
- Promote the Aptura Flow prototype into the packaged runtime build.
- Add signed public package repository infrastructure.
- Add automated VM boot tests.
- Complete branding assets under an open license.
