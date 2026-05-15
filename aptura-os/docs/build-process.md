# Build Process

## Host Setup

Use a Debian or Ubuntu build host. A clean Debian 13 VM is recommended.

Install dependencies:

```bash
sudo apt update
sudo apt install --no-install-recommends \
  live-build dpkg-dev devscripts debhelper equivs apt-utils reprepro \
  squashfs-tools xorriso isolinux syslinux-common dosfstools mtools \
  cryptsetup cryptsetup-initramfs \
  grub-common grub2-common grub-pc-bin grub-efi-amd64-bin efibootmgr \
  qemu-system-x86 qemu-utils git curl wget gnupg ca-certificates
```

## Build Steps

From the project root:

```bash
./scripts/validate.sh
./scripts/build-packages.sh
./scripts/create-local-repo.sh
./scripts/build-iso.sh
```

Or run everything:

```bash
./build.sh
```

## Configuration

Edit `config/distro.env` for:

- Distribution name and version.
- Base suite.
- Architecture.
- Mirror URLs.
- ISO name and volume ID.
- Repository signing settings.

Edit `config/packages.list` for package selection.

Edit `config/apt-sources.list` for APT sources copied into the live image.

## live-build Layout

The editable template is `config/live-build/config`.

The generated working copy is `build/live-build/config`.

Generated files include:

- `config/package-lists/aptura.list.chroot`
- `config/packages.chroot/*.deb`
- `config/hooks/normal/*.hook.chroot`
- `config/includes.chroot/etc/calamares`
- `config/includes.chroot/etc/apt/sources.list`

## Logs

`build.sh` writes logs to:

```text
build/logs/
```

Each major phase has its own log file.

## Troubleshooting

### Missing `lb`

Install `live-build`.

```bash
sudo apt install live-build
```

### `debian/rules` not executable

On Linux:

```bash
chmod +x build.sh clean.sh scripts/*.sh tests/*.sh hooks/*.sh packages/*/debian/rules packages/aptura-desktop/usr/bin/aptura-*
```

### Calamares cannot find squashfs

Check the live media path after boot:

```bash
find /run/live -name '*.squashfs' -print
```

Update `installer/calamares/modules/unpackfs.conf`.

### Bootloader fails in VM

Verify whether the VM booted in BIOS or UEFI mode and whether the partition
table matches that mode. Aptura's automatic partitioning lets Calamares choose
GPT for UEFI and msdos for BIOS so GRUB has a valid target in both modes. Test
both paths before release.

For UEFI installs on Debian-derived images, keep `efiBootloaderId: "debian"` in
`installer/calamares/modules/bootloader.conf`. Debian's GRUB EFI binary expects
its configuration below `/EFI/debian`; Aptura branding is applied to the GRUB
menu and OS metadata instead.

Keep `bootloader.conf` on the current Calamares bootloader keys
(`kernelSearchPath`, `kernelPattern`, `loaderEntries`) instead of the older
`kernel`, `img`, `fallback`, and `timeout` keys.

Encrypted installs require `grubcfg`, `luksbootkeyfile`, `initramfscfg`, and
`initramfs` in the Calamares exec sequence. Keep `cryptsetup-initramfs` in the
live package list and metapackage so the installed system can boot encrypted
root filesystems after the live packages are removed.

Do not enable XFS for the root filesystem unless the installer also creates a
separate GRUB-readable `/boot` partition. With root and `/boot` on XFS, GRUB
installation can fail on current Debian/Calamares combinations.

### APT rejects repositories

Check:

- `config/apt-sources.list`
- Debian archive keyring package presence.
- Aptura repository `Release`, `Release.gpg`, and `InRelease`.
- System time in the VM.

### Build host is not Linux

Use a Debian VM or WSL2 with proper privileges. Full live-build ISO generation
needs Linux loop mounts and filesystem behavior.

## Reproducibility Notes

For stronger reproducibility:

- Pin Debian snapshot URLs.
- Capture package versions in a build manifest.
- Build in a clean container or VM.
- Publish checksums for packages and ISO artifacts.
- Avoid time-dependent generated content inside packages.
