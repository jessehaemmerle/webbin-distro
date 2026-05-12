# Roadmap

## MVP

- Repository scaffold.
- Debian Stable live-build ISO path.
- Aptura metapackages.
- Local APT repository generation.
- Calamares configuration.
- Aptura Flow React prototype.
- Security and release documentation.
- Manual VM test checklist.

## Alpha

- Build a booting ISO in a clean Debian VM.
- Fix live-build and Calamares path issues.
- Verify Calamares install in QEMU.
- Package built Aptura Flow assets.
- Add repository signing key workflow.
- Add lintian and shellcheck CI.
- Add first real branding pass.

## Beta

- Public signed repository.
- Automated VM boot test.
- Calamares install test automation where practical.
- Upgrade tests from previous beta.
- Accessibility review.
- Translation workflow.
- Secure Boot implementation decision.
- Hardware smoke tests on at least three systems.

## Stable

- Signed release artifacts.
- Documented support policy.
- Stable update channel.
- Security response process.
- Public issue tracker and release notes.
- Verified installer behavior across BIOS and UEFI.

## Long-Term Features

- Native Aptura Flow shell integration.
- Aptura Settings Center with D-Bus backends.
- Local-only assistant surface.
- Edition-specific metapackages.
- arm64 images.
- OEM/preinstall mode.
- Snapshot-based rollback option.
- Btrfs install profile.
- Full reproducible-build pipeline.
