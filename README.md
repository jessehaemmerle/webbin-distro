# Aptura OS

Aptura OS is a **Ubuntu-based** Linux distribution focused on **everyday work** —
office, mail, web and music that just work out of the box — wrapped in a single,
consistent identity from the bootloader to the desktop. It ships its own
**custom-built kernel**, its own **Aptura Shell** Wayland desktop, and uses
**APT** for package management.

> Status: MVP scaffold. This repository builds the distribution; it has not yet
> produced a verified release ISO. The full build runs only on a Linux host
> (see [Build](#build)).

## Highlights

- **Base:** Ubuntu LTS (`noble` by default; the suite is a config variable).
- **Custom kernel:** the newest mainline kernel, built as a local `.deb` with
  Aptura branding (`uname -r` → `…-aptura`) and a desktop-tuned config. See
  [docs/kernel.md](docs/kernel.md). *(Note: there is no "Linux 7" release as of
  early 2026; the version is a variable and bumps to 7.x the day it ships.)*
- **Aptura Shell:** a labwc Wayland session (waybar, wofi, swaybg, mako) with
  Aptura keybindings, screenshot and power helpers. See [desktop/](desktop/).
- **Everyday apps:** LibreOffice, Thunderbird, Firefox (real `.deb`, not snap),
  Spotify (Flatpak), GNOME Software + Flathub, codecs, backups, printing.
- **Consistent branding:** os-release, Plymouth, GRUB, SDDM and Calamares all
  rendered from one palette and identity. See [branding/](branding/).
- **Installer:** Calamares, branded, tuned for Ubuntu paths. See [installer/](installer/).
- **Security defaults:** AppArmor enforcing, UFW default-deny, automatic security
  updates, no SSH server, no telemetry, Flatpak preferred over Snap.

## Project structure

```text
config/     Build + branding configuration and the live-build (Ubuntu) skeleton.
kernel/     Custom mainline kernel build script, config overrides, branding.
branding/   Source artwork + templates; rendered into a single visual identity.
desktop/    Aptura Shell session, labwc/waybar/wofi/mako config, helper scripts.
packages/   Native Debian metapackages (meta, branding, desktop, settings, apps, kernel).
installer/  Calamares settings, modules, and Aptura branding.
hooks/      Chroot hooks run during image construction.
scripts/    build/validate/kernel/packages/repo/iso/vm helpers (+ shared lib).
tests/      Structural smoke test, package metadata test, shellcheck, ISO checklist.
docs/       Architecture, build, kernel, desktop, apps, branding, security, roadmap.
```

## Build

Requires a **Debian/Ubuntu Linux host** (or clean VM/container) with privileges
for live-build and the kernel toolchain.

```bash
sudo apt update
sudo apt install --no-install-recommends \
  live-build debootstrap squashfs-tools xorriso \
  grub-efi-amd64-bin grub-pc-bin mtools dosfstools isolinux \
  dpkg-dev debhelper devscripts \
  build-essential bc bison flex libssl-dev libelf-dev dwarves rsync kmod cpio xz-utils \
  reprepro gnupg ca-certificates curl rsvg-convert \
  qemu-system-x86 qemu-utils ovmf

./build.sh
```

`build.sh` runs: render branding → validate → build custom kernel → build
`.deb` packages → create local APT repo → (optional sign) → build live ISO.
Output:

```text
dist/aptura-os-0.1.0-aurora-amd64.iso
dist/aptura-os-0.1.0-aurora-amd64.iso.sha256
```

On a non-Linux host you can still run the OS-independent steps:

```bash
./build.sh --no-iso        # renders branding, validates, stages packages
./scripts/render-branding.sh
./scripts/validate.sh
./tests/smoke-test.sh
./tests/package-test.sh
./tests/shellcheck.sh
```

## Test in a VM

```bash
./scripts/test-vm.sh                 # boots dist/<iso> in QEMU on a throwaway disk
./scripts/test-vm.sh path/to.iso
```

Then work through [tests/manual-iso-checklist.md](tests/manual-iso-checklist.md).

## Clean

```bash
./clean.sh    # removes only build/ and dist/
```

## Known limitations

- MVP scaffold; no verified release ISO produced yet, and never on the
  Windows-hosted workspace this was authored in.
- **There is no "Linux 7" kernel** as of early 2026; Aptura builds the newest
  available mainline and is structured to bump to 7.x when released.
- A custom kernel means owning security-backport cadence and hardware-regression
  triage; `BUILD_CUSTOM_KERNEL=false` falls back to an archive kernel.
- Secure Boot is documented but not implemented; signed public repo infrastructure
  is not set up (`SIGN_REPO=false`).
- Branding assets and the Aptura Shell still need visual QA on a booted ISO.
- Exact Ubuntu package names / Calamares module paths may need point-release tweaks.

## History

The original Debian-based prototype of this project is preserved on the
`legacy-debian` git branch. `main` is the Ubuntu-based rebuild.

## License

MIT — see [LICENSE](LICENSE).
