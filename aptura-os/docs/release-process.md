# Release Process

## Versioning

Aptura OS versions use semantic project versions:

```text
MAJOR.MINOR.PATCH
```

Examples:

- `0.1.4` Adeline Shell MVP
- `0.2.0` Alpha
- `1.0.0` Stable

The Aptura codename remains explicit in filenames. Debian base suite remains
explicit in release notes.

## ISO Naming

Pattern:

```text
aptura-os-<version>-<codename>-<arch>.iso
```

Example:

```text
aptura-os-0.1.4-adeline-amd64.iso
```

## Release Artifacts

Each release should publish:

- ISO file.
- SHA256 checksum.
- Detached signature for checksum file.
- Package repository snapshot.
- Release notes.
- Known issues.
- Build manifest.

## Checksums

Generate:

```bash
sha256sum aptura-os-0.1.4-adeline-amd64.iso > aptura-os-0.1.4-adeline-amd64.iso.sha256
```

Sign:

```bash
gpg --detach-sign --armor aptura-os-0.1.4-adeline-amd64.iso.sha256
```

## Release Notes

Include:

- Base Debian version.
- Kernel version.
- Desktop version.
- Installer changes.
- Security changes.
- Known issues.
- Upgrade notes.

## Test Matrix

Minimum release test matrix:

- QEMU BIOS boot.
- QEMU UEFI boot.
- Live desktop start.
- Network via NAT.
- Calamares automatic partitioning.
- Calamares manual partitioning.
- Optional encryption install.
- Reboot into installed system.
- APT update and package install.
- AppArmor status.
- UFW status.
- Branding check.
- Accessibility smoke check.

## Promotion

Suggested channels:

- `nightly`: automated, may break.
- `alpha`: feature validation.
- `beta`: release candidate hardening.
- `stable`: public releases.

Do not promote from beta to stable without rebuilding or proving artifact
immutability through signatures and manifests.

## Rollback

For package repositories:

- Keep previous repository snapshots.
- Keep previous ISO artifacts.
- Document downgrade risk.
- Avoid package maintainer scripts that cannot tolerate downgrade unless noted.
