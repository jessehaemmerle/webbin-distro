# Aptura Debian Packages

This directory contains native Debian package skeletons for Aptura OS.

Packages:

- `aptura-meta`: pulls in the distribution's core package set.
- `aptura-branding`: installs visual identity, wallpaper, login theme placeholders, Plymouth theme, and derivative metadata.
- `aptura-desktop`: installs the Aptura Flow launcher and desktop integration.
- `aptura-settings`: installs system defaults for APT, security, dconf, update behavior, and policy documentation.

Build all packages:

```bash
./scripts/build-packages.sh
```

TODO:

- Split edition-specific metapackages after workstation/server/media editions exist.
- Move large compiled frontend assets into `aptura-desktop` during CI.
- Add lintian overrides only after reviewing real lintian output.
- Add autopkgtest coverage for package upgrade and removal behavior.
