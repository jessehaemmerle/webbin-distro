# Secure Boot

The Aptura kernel is built locally and is **not** signed by a key in the UEFI db,
so with Secure Boot enabled it will not boot unsigned. Aptura handles this with a
**per-machine Machine Owner Key (MOK)** — the standard approach used by DKMS and
akmods — implemented by the `aptura-secureboot` package.

## How it works

1. **First boot** (`aptura-secureboot.service` → `aptura-secureboot auto`):
   if Secure Boot is enabled, a per-machine MOK is generated in
   `/var/lib/aptura/mok/` (root-only, never shipped in the image), all installed
   `/boot/vmlinuz-*-aptura` are signed with it, and the user is notified.
2. **Enrollment** (interactive, once): the user runs
   ```bash
   sudo aptura-secureboot enroll
   ```
   sets a one-time password, reboots, and confirms **Enroll MOK → Continue** in
   the blue MOK Manager firmware screen. This step is interactive by design —
   enrolling a key requires physical presence at the firmware.
3. **Kernel updates**: `/etc/kernel/postinst.d/zz-aptura-secureboot` re-signs each
   new Aptura kernel with the existing MOK automatically.

Check state anytime with `aptura-secureboot status`.

## If you don't use Secure Boot

Nothing to do — `auto` detects Secure Boot is off and exits. The kernel boots
normally.

## Alternatives

- Disable Secure Boot in firmware (simplest; lower assurance).
- A future signed public Aptura kernel via a shim + vendor key is a larger,
  roadmap-level effort (a CA relationship / shim review) and is out of scope here.

## Build-time signing (optional)

`SIGN_KERNEL` is reserved in `config/distro.env` for a future build-host signing
flow. The supported path today is the per-machine MOK above, which keeps the
private key on the user's machine rather than in the build pipeline or image.
