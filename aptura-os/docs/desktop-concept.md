# Aptura Plasma Desktop Concept

## UX Philosophy

Aptura uses KDE Plasma as the desktop foundation and gives it a deliberate
retro workstation identity. The design should feel like a coherent distribution
from the first boot screen through the installed desktop, not a generic Plasma
session with one swapped wallpaper.

Principles:

- Use KDE Plasma for a modern Wayland session, flexible panels/widgets,
  application launcher, System Settings, and mature first-party applications.
- Make the whole shell feel Aptura-native: wallpaper, logo, greeter, installer,
  icons, accent palettes, boot splash, and first-run tools should share one
  visual language.
- Prefer useful local tools over mock surfaces.
- Keep privacy defaults conservative.
- Keep the retro direction crisp: hard silhouettes, grid perspective, neon
  accents, pixel-inspired icons, and restrained typography.

## Technical Choice

The MVP uses:

- Plasma session with KWin, panel/widgets, launcher, System Settings,
  notifications, screenshot tooling, workspaces, and portal integration.
- SDDM as the display manager.
- Aptura color assets and GTK skeleton settings for applications that honor them.
- `Aptura-COSMIC` GTK fallback theme for GTK applications that honor it.
- `Aptura-COSMIC` icon theme with hicolor and Adwaita fallback.
- Aptura System Check and the contextual Aptura tools for local status,
  Journey history, session context, workstation shifts, aftercare, and live
  install readiness.

## Visual Direction

### Aptura Retro-Plasma Palette

- Deep space: `#12142b`
- Electric teal: `#00d9c0`
- Solar magenta: `#ff4fd8`
- Grid violet: `#7a4dff`
- Warm sun: `#ffb14a`
- Workbench gray: `#c0c0c0`
- Signal yellow: `#ffe45c`

### Shell

- Plasma panels/widgets should use Aptura accent colors where upstream
  configuration allows distribution defaults.
- Launcher, app library, settings, and greeter should carry the Aptura mark.
- The contextual default wallpaper is `aptura-context-grid.svg`; the retro
  wallpaper remains available as a classic fallback.
- Plymouth, GRUB, Calamares, Welcome, About, and System Check should present
  the same Aptura Plasma naming.

### Icons

The custom icon theme starts small and falls back to hicolor/Adwaita. Aptura
should expand it over time with simple pixel-like icons for core actions:

- Folder and home.
- Computer and disk.
- Terminal.
- File manager.
- Settings.
- Aptura System Check, Journey, Context, Shift, Aftercare, and Live Bridge.

## Workstation Tools

The default desktop should include practical packages that make the system feel
complete:

- Dolphin, Konsole, Kate, System Settings, Plasma application launcher, and
  Discover when packaged.
- Synaptic for package management.
- fwupd for firmware updates.
- power-profiles-daemon for battery/performance modes.
- Blueman, NetworkManager applet, pavucontrol, and PipeWire/PulseAudio tools.
- Flatpak support for users who want app sandboxing.

## Future Extensions

Only add Aptura-specific Plasma widgets or services when they provide a clear
workflow improvement:

- A local-only Journey surface that shows what the system has done recently.
- Context-aware live-session and post-update flows that explain next steps.
- Workstation rituals for code, study, create, game, travel, and focus.
- Native update status plugin backed by PackageKit or a narrow APT service.
- Snapshot-based rollback profile when the installer supports Btrfs.
- More complete Aptura icon coverage.
- Accessibility and high-contrast validation before public beta.
