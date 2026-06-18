# Aptura Shell desktop concept

Aptura Shell is the distro-owned default session: a coherent desktop from boot
splash to installed system, not a generic labwc setup with a new wallpaper. See
`desktop/README.md` for the concrete component list and keybindings.

## Principles

- **Familiar and fast**: labwc as a low-overhead Wayland stacking compositor;
  top panel with launcher, task list, tray, clock, and status.
- **Everyday first**: the default workflow targets office, mail, web, music — the
  things a daily user actually opens.
- **One identity**: wallpaper, logo, greeter, installer, panel and boot splash
  share the Aptura palette (`config/branding.conf`).
- **Useful over flashy**: real local tools (files, store, settings, screenshots,
  power menu), not mock surfaces.
- **Conservative privacy**: lock on idle, MAC randomisation, no telemetry.

## Palette

Deep space `#12142b` · electric teal `#00d9c0` · grid violet `#7a4dff` ·
solar magenta `#ff4fd8` · warm sun `#ffb14a` · workbench gray `#c0c0c0` ·
text `#eef1ff`.

## Future extensions (only when they earn their place)

- Native update status backed by PackageKit / a narrow APT service.
- Snapshot rollback profile once the Btrfs install profile lands.
- Expanded Aptura icon coverage; high-contrast/accessibility validation.
