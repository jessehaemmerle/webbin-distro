# Roadmap

## MVP

- Repository scaffold.
- Debian Stable live-build ISO path.
- Aptura metapackages.
- Local APT repository generation.
- Calamares configuration.
- Aptura Plasma defaults and System Check.
- Security and release documentation.
- Manual VM test checklist.

## Alpha

- Build a booting ISO in a clean Debian VM.
- Fix live-build and Calamares path issues.
- Verify Calamares install in QEMU.
- Verify Plasma session, greeter, accent palettes, icon theme, wallpaper, and Aptura branding.
- Verify System Check output in live and installed sessions.
- Confirm firmware, Flatpak, power profile, backup, and disk tools install cleanly.
- Add repository signing key workflow.
- Add lintian and shellcheck CI.
- Add accessibility review for the classic palette, bevel contrast, and focus rings.

## Beta

- Public signed repository.
- Automated VM boot test.
- Calamares install test automation where practical.
- Upgrade tests from previous beta.
- First-run checklist for updates, firmware, backups, privacy, and restore media.
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

- Native Plasma integration only where it improves a concrete workflow.
- Aptura Settings Center with narrow D-Bus backends.
- Local-only assistant surface.
- Edition-specific metapackages.
- arm64 images.
- OEM/preinstall mode.
- Snapshot-based rollback option.
- Btrfs install profile.
- Full reproducible-build pipeline.
