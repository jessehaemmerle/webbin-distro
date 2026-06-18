# Custom kernel

See also `kernel/README.md` for the build commands.

## Goals

A mainline kernel, branded as Aptura and tuned for a responsive desktop, shipped
as `.deb` packages from the local Aptura repo so it is the only kernel installed
(`lb --linux-flavours none`).

## "Linux 7"

There is **no Linux 7 release as of early 2026** — the newest line is 6.x.
`KERNEL_VERSION` in `config/distro.env` selects the mainline tarball. When 7.0
ships, set `KERNEL_VERSION="7.0"` (or a 7.x point release) and rebuild; the
download path (`vX.x/linux-<ver>.tar.xz`) and packaging are already generic.

## What is customised

- **Version string**: `LOCALVERSION=-aptura` and `CONFIG_LOCALVERSION` →
  `uname -r` reports e.g. `6.12.30-aptura`. This is the durable, supportable form
  of kernel branding.
- **Config** (`kernel/aptura-kernel.config`): `PREEMPT`, `HZ_1000`, AppArmor as
  default LSM, Btrfs/F2FS modules, zstd compression. Layered on top of the host
  Ubuntu config (`/boot/config-$(uname -r)`), then `make olddefconfig`.

## Trade-offs

A custom kernel transfers security-backport cadence and hardware-regression
triage from Ubuntu's kernel team to you. For a daily driver this is a real
ongoing commitment. Set `BUILD_CUSTOM_KERNEL=false` to ship an Ubuntu archive
kernel instead (the meta/`aptura-kernel` dependency would then point at a stock
flavour).

## Secure Boot

A custom unsigned kernel will not boot with Secure Boot enabled. Either disable
Secure Boot, or sign the kernel with an enrolled MOK. Implementing a signing
flow is on the roadmap and currently out of scope.
