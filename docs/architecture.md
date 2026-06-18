# Architecture

Aptura OS is a Ubuntu derivative built around APT, Debian-format packages,
live-build images, a custom kernel, Calamares installation, and the Aptura Shell
desktop.

## Layered model

1. **Upstream Ubuntu LTS** provides the base system, APT, systemd, archive, and
   security updates.
2. **Aptura custom kernel** replaces the archive kernel flavour (`*-aptura`).
3. **Aptura packages** add identity, the desktop, policy defaults, and the app set.
4. **live-build (Ubuntu mode)** composes a bootable live ISO from the Ubuntu
   archive plus the local Aptura repository.
5. **Calamares** installs the live system to disk.
6. **Aptura Shell** provides the default session and consistent branding.

## Base distribution

- Family: Ubuntu · Suite: `noble` (24.04 LTS) by default · Arch: `amd64`
- Package manager: APT · Format: `.deb`
- Mirrors: `archive.ubuntu.com`, `security.ubuntu.com`

The suite is the `BASE_SUITE` variable in `config/distro.env`; moving to a newer
LTS is a config change plus package-name validation.

## Packages

Native Debian metapackages (see `packages/`): `aptura-meta` (top-level),
`aptura-branding`, `aptura-desktop`, `aptura-settings`, `aptura-apps`, and
`aptura-kernel`. Defaults evolve by editing dependencies, not installer scripts.

## Build flow

`build.sh` → `render-branding.sh` → `validate.sh` → `kernel/build-kernel.sh` →
`build-packages.sh` → `create-local-repo.sh` → (`sign-repo.sh`) →
`build-iso.sh`. See [build-process.md](build-process.md).

## Update model

- MVP: Ubuntu `noble` + `noble-updates` + `noble-security` + `noble-backports`,
  Mozilla APT repo for Firefox, and the local Aptura repo at build time.
- Production: a signed public Aptura repository with release channels, pinning
  policy for Aptura packages, and published checksums.

## Trust boundaries

APT repository signatures · Calamares privileged steps · PolicyKit actions ·
the Mozilla repo key · user session vs. system services. Privileged desktop
actions go through PolicyKit, never directly from the shell frontend.
