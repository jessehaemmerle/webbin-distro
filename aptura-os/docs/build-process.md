# Build Process

## Host Setup

Use a Debian or Ubuntu build host. A clean Debian 13 VM is recommended.

Install dependencies:

```bash
sudo apt update
sudo apt install --no-install-recommends \
  live-build dpkg-dev devscripts debhelper equivs apt-utils reprepro \
  squashfs-tools xorriso isolinux syslinux-common grub-pc-bin \
  grub-efi-amd64-bin qemu-system-x86 qemu-utils git curl wget gnupg \
  ca-certificates
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
chmod +x build.sh clean.sh scripts/*.sh tests/*.sh hooks/*.sh packages/*/debian/rules packages/aptura-desktop/usr/bin/aptura-flow
```

### Calamares cannot find squashfs

Check the live media path after boot:

```bash
find /run/live -name '*.squashfs' -print
```

Update `installer/calamares/modules/unpackfs.conf`.

### Bootloader fails in VM

Verify whether the VM booted in BIOS or UEFI mode and whether the partition
table matches that mode. Test both paths before release.

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
