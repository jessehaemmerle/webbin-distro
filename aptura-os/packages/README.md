# Aptura Native Packages

This directory contains Aptura OS native packages in Debian `.deb` format.

Packages:

- `aptura-meta`: pulls in the distribution's core package set.
- `aptura-branding`: installs the Aptura visual identity, distributor logos, wallpaper, COSMIC palettes, GTK fallback theme, icon theme, Plymouth theme, shell branding, and derivative metadata.
- `aptura-desktop`: installs Aptura Plasma integration, Welcome, System Check, and useful desktop packages.
- `aptura-settings`: installs system defaults for APT, security, NetworkManager privacy, update behavior, and policy documentation.

Build all packages:

```bash
./scripts/build-packages.sh
```

TODO:

- Split edition-specific metapackages after workstation/server/media editions exist.
- Add Plasma widgets or integration packages only when they provide tested user value.
- Add lintian overrides only after reviewing real lintian output.
- Add autopkgtest coverage for package upgrade and removal behavior.
