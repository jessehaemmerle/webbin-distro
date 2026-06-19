# Aptura Debian packages

Native Debian source packages built by `scripts/build-packages.sh` into the
local Aptura APT repository. The default install is declarative: editing
`aptura-meta`'s dependencies (and the leaf metapackages below) changes what a
fresh system gets.

- `aptura-meta` — top-level dependency package for the default install.
- `aptura-branding` — os-release, Plymouth, GRUB, SDDM theme, icon theme, wallpapers.
- `aptura-desktop` — Aptura Shell (labwc) session + GTK/labwc theme + desktop stack.
- `aptura-settings` — security/policy defaults (AppArmor, UFW, auto-updates, …).
- `aptura-apps` — everyday apps (LibreOffice, Thunderbird, Firefox, …) + German langpacks.
- `aptura-kernel` — selector metapackage for the custom `*-aptura` kernel.
- `aptura-welcome` — first-run GTK4 welcome app (update/firmware/backups/region).
- `aptura-secureboot` — per-machine MOK signing + enrollment for the custom kernel.

## Conventions

Tracked per package: `debian/control` (or `control.in`) and, where needed,
`debian/install`, `debian/links`, `debian/postinst`, and a static `payload/`
tree.

Generated at build time by `scripts/build-packages.sh` into a staging copy
under `build/packages-src/<pkg>` (the tracked dirs stay clean):

- Boilerplate `debian/changelog`, `debian/rules`, `debian/source/format`,
  `debian/copyright` when a package does not ship its own.
- Dynamic `payload/`:
  - `aptura-branding` ← rendered files from `build/branding/`.
  - `aptura-desktop`  ← files from the top-level `desktop/` dir.
- `control.in` → `control` with `@KERNEL_VERSION@` (and other vars) substituted
  from `config/distro.env` (used by `aptura-kernel`).

`aptura-meta` ships a complete, hand-written `debian/` as the reference example.
