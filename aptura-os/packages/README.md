# Aptura Native Packages

This directory contains Aptura OS native packages in Debian `.deb` format.

Packages:

- `aptura-meta`: pulls in the distribution's core package set.
- `aptura-branding`: installs the Aptura visual identity, distributor logos, wallpaper, accent palettes, GTK fallback theme, icon theme, Plymouth theme, shell branding, and derivative metadata.
- `aptura-desktop`: installs Aptura Shell integration and useful desktop packages.
- `aptura-settings`: installs system defaults for APT, security, NetworkManager privacy, update behavior, and policy documentation.

Branding assets and generated package metadata are driven by
`config/distro.env`, `config/branding.conf`, and optional untracked
`config/*.local.env` overrides. After changing branding names, colors, icon
themes, wallpaper paths, Plymouth themes, or Calamares theme IDs, run
`./scripts/render-branding.sh`; full builds call it automatically.

Build all packages:

```bash
./scripts/build-packages.sh
```

TODO:

- Split edition-specific metapackages after workstation/server/media editions exist.
- Add shell widgets or integration packages only when they provide tested user value.
- Add lintian overrides only after reviewing real lintian output.
- Add autopkgtest coverage for package upgrade and removal behavior.
