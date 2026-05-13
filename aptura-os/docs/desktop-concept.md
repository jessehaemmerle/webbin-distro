# Aptura COSMIC Desktop Concept

## UX Philosophy

Aptura uses System76 COSMIC as the desktop foundation and gives it a deliberate
retro workstation identity. The design should feel like a coherent distribution
from the first boot screen through the installed desktop, not a generic COSMIC
session with one swapped wallpaper.

Principles:

- Use COSMIC for a modern Wayland session, tiling-friendly workflow, applets,
  launcher, app library, settings, and first-party core applications.
- Make the whole shell feel Aptura-native: wallpaper, logo, greeter, installer,
  icons, accent palettes, boot splash, and first-run tools should share one
  visual language.
- Prefer useful local tools over mock surfaces.
- Keep privacy defaults conservative.
- Keep the retro direction crisp: hard silhouettes, grid perspective, neon
  accents, pixel-inspired icons, and restrained typography.

## Technical Choice

The MVP uses:

- COSMIC session with COSMIC compositor, panel, launcher, app library, settings,
  notifications, OSD, screenshot tool, workspaces, and portal integration.
- COSMIC Greeter when packaged, with `greetd` as the underlying login service.
- Aptura COSMIC accent palettes under the COSMIC settings namespace.
- `Aptura-COSMIC` GTK fallback theme for GTK applications that honor it.
- `Aptura-COSMIC` icon theme with hicolor and Adwaita fallback.
- Aptura System Check for local status reporting.

## Visual Direction

### Aptura Retro-COSMIC Palette

- Deep space: `#12142b`
- Electric teal: `#00d9c0`
- Solar magenta: `#ff4fd8`
- Grid violet: `#7a4dff`
- Warm sun: `#ffb14a`
- Workbench gray: `#c0c0c0`
- Signal yellow: `#ffe45c`

### Shell

- COSMIC panel and applets should use Aptura accent colors where COSMIC allows
  distribution defaults.
- Launcher, app library, settings, and greeter should carry the Aptura mark.
- The default wallpaper is `aptura-retro-cosmic.svg`.
- Plymouth, GRUB, Calamares, Welcome, About, and System Check should present
  the same Aptura COSMIC naming.

### Icons

The custom icon theme starts small and falls back to hicolor/Adwaita. Aptura
should expand it over time with simple pixel-like icons for core actions:

- Folder and home.
- Computer and disk.
- Terminal.
- File manager.
- Settings.
- Aptura System Check.

## Workstation Tools

The default desktop should include practical packages that make the system feel
complete:

- COSMIC Files, COSMIC Terminal, COSMIC Edit, COSMIC Settings, COSMIC App
  Library, and COSMIC Store when packaged.
- Synaptic for package management.
- fwupd for firmware updates.
- power-profiles-daemon for battery/performance modes.
- Blueman, NetworkManager applet, pavucontrol, and PipeWire/PulseAudio tools.
- Flatpak support for users who want app sandboxing.

## Future Extensions

Only add Aptura-specific COSMIC applets or services when they provide a clear
workflow improvement:

- First-run checklist for updates, firmware, backups, privacy, and restore
  media.
- Native update status plugin backed by PackageKit or a narrow APT service.
- Snapshot-based rollback profile when the installer supports Btrfs.
- More complete Aptura icon coverage.
- Accessibility and high-contrast validation before public beta.
