# Release process

> Pre-1.0: there is no public release channel yet. This documents the intended
> flow as the project matures (see [roadmap.md](roadmap.md)).

## Versioning

`DISTRO_VERSION` + `DISTRO_CODENAME` in `config/distro.env` drive the ISO name,
os-release, and Calamares strings. Bump both for a release.

## Cutting a build

1. Update `DISTRO_VERSION`/`DISTRO_CODENAME` and, if changing kernels,
   `KERNEL_VERSION`.
2. `./scripts/render-branding.sh` then commit the config change.
3. On a clean Ubuntu host: `./build.sh` (set `SIGN_REPO=true` +
   `REPO_GPG_KEY_ID` for signed artifacts).
4. Verify with `./scripts/test-vm.sh` and
   [../tests/manual-iso-checklist.md](../tests/manual-iso-checklist.md).
5. Publish `dist/<iso>` + `.sha256` (and the signed repo) to the release host.

## Checklist before a public release

- Repository signing enabled and key published.
- Secure Boot story decided (signed kernel or documented).
- Install verified on BIOS + UEFI, erase + LUKS.
- First-run: updates, firmware, backups, Flatpak/Spotify, privacy all work.
- Release notes + known-issues written.
