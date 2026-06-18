# Build process

The full build runs on a **Linux host**. Off-Linux, the OS-independent steps
(branding, validation, package staging) still run via `./build.sh --no-iso`.

## Stages

1. **Render branding** (`scripts/render-branding.sh`) — expand `@VAR@`
   templates from `config/*` into `build/branding/`. Any OS.
2. **Validate** (`scripts/validate.sh`) — structure/config/package metadata.
   Any OS.
3. **Custom kernel** (`kernel/build-kernel.sh`) — download mainline
   `KERNEL_VERSION`, apply Aptura config, `make bindeb-pkg`. Linux only.
4. **Packages** (`scripts/build-packages.sh`) — stage each `packages/<pkg>` to
   `build/packages-src/<pkg>`, generate boilerplate, render `control.in`, stage
   dynamic payloads, `dpkg-buildpackage`. Builds `.deb` on Linux; stages only
   elsewhere.
5. **Local repo** (`scripts/create-local-repo.sh`) — collect kernel + Aptura
   `.deb`s into `build/localrepo` with a `Packages`/`Release` index.
6. **Sign** (`scripts/sign-repo.sh`) — optional, when `SIGN_REPO=true`.
7. **ISO** (`scripts/build-iso.sh`) — seed live-build, inject hooks, Calamares
   config, branding, the local repo and the Mozilla key; `lb config` (Ubuntu
   mode) + `lb build`; emit `dist/<ISO_NAME>` + `.sha256`. Linux + root.

## Why off-Linux is limited

live-build needs Linux filesystem semantics, loop devices, and root; the kernel
and `.deb` builds need the Debian/Ubuntu toolchain. The repository is structured
so design, configuration, and validation happen anywhere, while image creation
happens on Ubuntu.

## Configuration knobs

All in `config/distro.env` (override locally in `config/distro.local.env`):
`BASE_SUITE`, `KERNEL_VERSION`, `BUILD_CUSTOM_KERNEL`, `ENABLE_FLATPAK`,
`PREFER_FLATPAK_OVER_SNAP`, `ENABLE_UNATTENDED_UPGRADES`, `SIGN_REPO`,
`REPO_GPG_KEY_ID`.
