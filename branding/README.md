# Aptura branding

One visual identity rendered consistently from boot to desktop.

- `assets/` — source artwork (logo, wallpapers). SVG is the source of truth;
  PNGs needed by Plymouth/GRUB are rasterised during the build hook.
- `templates/` — files with `@VAR@` placeholders. `scripts/render-branding.sh`
  expands them from `config/distro.env` + `config/branding.conf` into
  `build/branding/`.

Rendered surfaces:

| Surface     | Template                          | Installed by            |
|-------------|-----------------------------------|-------------------------|
| os-release  | `os-release.in`                   | `aptura-branding` pkg   |
| lsb-release | `lsb-release.in`                  | `aptura-branding` pkg   |
| Boot splash | `plymouth/aptura.*.in`            | `aptura-branding` pkg   |
| Bootloader  | `grub/theme.txt.in`               | `aptura-branding` pkg   |
| Greeter     | `sddm/theme.conf.in`              | `aptura-branding` pkg   |
| Installer   | `installer/calamares/branding/`   | `calamares-settings-*`  |
| Wallpaper   | `assets/wallpaper-*.svg`          | `aptura-branding` pkg   |

Run `scripts/render-branding.sh` after editing any name, URL, colour, or theme
id. Full builds run it automatically before validation and packaging.
