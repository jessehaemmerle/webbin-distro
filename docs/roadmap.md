# Roadmap

## MVP (this scaffold)
- Ubuntu live-build ISO path (Ubuntu mode).
- Custom mainline kernel built as `.deb`.
- Aptura metapackages (meta, branding, desktop, settings, apps, kernel).
- Aptura Shell (labwc) desktop defaults.
- Everyday app set (LibreOffice, Thunderbird, Firefox .deb, Spotify Flatpak).
- Consistent branding (os-release, Plymouth, GRUB, SDDM, Calamares).
- Calamares installer config for Ubuntu.
- Security/policy defaults.
- Structural validation, smoke/package tests, shellcheck, manual ISO checklist.

## Alpha
- Build a booting ISO in a clean Ubuntu VM; fix live-build/Calamares path issues.
- Verify Calamares install (erase + LUKS) in QEMU.
- Verify Aptura Shell session, greeter, panel, launcher, wallpaper, branding.
- Confirm custom kernel boots and `uname -r` shows `-aptura`.
- Confirm Firefox is the Mozilla `.deb`, Spotify Flatpak installs first boot.
- Add lintian + shellcheck CI.

## Beta
- Signed public Aptura repository + release channels.
- Automated VM boot test; install-test automation where practical.
- Secure Boot decision (MOK-signed kernel or documented disable).
- Accessibility/contrast review; translation workflow.
- Hardware smoke tests on ≥3 machines.

## Stable
- Signed release artifacts + published checksums.
- Documented support policy and security response process.
- Stable update channel; verified installs across BIOS and UEFI.

## Long-term
- Btrfs install profile + snapshot rollback (Timeshift/snapper).
- OEM/preinstall mode; arm64 images.
- Aptura Settings Center with narrow D-Bus/PolicyKit backends.
- Reproducible kernel + package builds.
- Decision on tracking the newest LTS vs. a rolling-ish HWE stack.
