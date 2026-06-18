# Aptura custom kernel

Aptura OS ships its **own** mainline Linux kernel, built as Debian-format `.deb`
packages and served from the local Aptura APT repository. The image is built
with `--linux-flavours none`, so the Aptura kernel is the only kernel installed.

## What "custom" means here

- **Version**: `KERNEL_VERSION` in `config/distro.env` selects the mainline
  release. There is no "Linux 7" release as of early 2026 — the newest line is
  6.x. When 7.0 ships, set `KERNEL_VERSION="7.0"` and rebuild; nothing else
  changes.
- **Branding**: `LOCALVERSION=-aptura` makes `uname -r` report e.g.
  `6.12.30-aptura`. This is the most reliable, supportable form of kernel
  branding. Cosmetic boot-logo changes are possible but fragile and are left
  out by default.
- **Config**: `kernel/aptura-kernel.config` layers desktop-oriented overrides
  (PREEMPT, 1000 Hz, AppArmor default LSM, Btrfs/F2FS modules, zstd) on top of
  the host/Ubuntu config. `kernel/apply-aptura-config.sh` merges them, then
  `make olddefconfig` resolves dependencies.

## Build

Linux host only (Ubuntu recommended):

```bash
sudo apt install build-essential bc bison flex libssl-dev libelf-dev \
  dwarves rsync kmod cpio xz-utils
kernel/build-kernel.sh
```

Artifacts land in `build/kernel/*.deb` and are folded into the local repo by
`scripts/create-local-repo.sh`. The full `./build.sh` runs this automatically
when `BUILD_CUSTOM_KERNEL=true`.

## Why a custom kernel is heavier to maintain

You take on security backporting cadence and hardware-regression triage that
you would otherwise inherit from Ubuntu's kernel team. For a daily-driver distro
this is a real commitment; `BUILD_CUSTOM_KERNEL=false` falls back to shipping an
archive kernel flavour if you ever want to reduce that burden.
