# Wallpapers

Canonical wallpaper assets live in `packages/aptura-branding/usr/share/backgrounds`.
The active wallpaper set is selected through `config/branding.conf`:

- `WALLPAPER_DIR` points at the installed wallpaper directory.
- `DEFAULT_WALLPAPER` is used by Aptura Shell, live-build alternatives, and the
  About dialog.
- `WALLPAPER_ALTERNATIVES` lists additional packaged wallpapers for
  `update-alternatives`.

Run `./scripts/render-branding.sh` after changing these values or adding a local
override in `config/branding.local.env`. Full builds run the renderer
automatically.

The default direction is Aptura Shell: a retro-space scene with neon horizon
grid, the Aptura mark, high-contrast silhouettes, teal/magenta accents, and a
clear link to the Aptura desktop palette.

Policy:

- Use only original artwork, permissively licensed assets, or generated assets with clear provenance.
- Keep source files editable.
- Do not embed proprietary logos, fonts, or photographs.

TODO:

- Add light and dark wallpaper variants.
- Add high contrast wallpaper.
- Generate thumbnails for installer and settings previews.
