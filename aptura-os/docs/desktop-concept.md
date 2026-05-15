# Aptura Shell Desktop Concept

## UX Philosophy

Aptura Shell is the distro-owned default desktop session. It should feel like a
coherent operating system from the first boot screen through the installed
desktop, not a generic labwc setup with one swapped wallpaper.

Principles:

- Use labwc for a modern Wayland stacking compositor with familiar window
  behavior, low overhead, and simple configuration.
- Keep the primary workflow obvious: top panel, app launcher, window task list,
  tray, clock, network/audio/battery status, mode switcher, and power menu.
- Make the whole shell feel Aptura-native: wallpaper, logo, greeter, installer,
  icons, accent palettes, boot splash, and first-run tools should share one
  visual language.
- Keep KDE Plasma installed as a fallback session and as a mature application
  base, not as the default user shell.
- Prefer useful local tools over mock surfaces.
- Keep privacy defaults conservative.
- Keep the retro direction crisp: hard silhouettes, grid perspective, neon
  accents, pixel-inspired icons, and restrained typography.

## Technical Choice

The MVP uses:

- Aptura Shell session file in `/usr/share/wayland-sessions/aptura.desktop`.
- `aptura-session` to export session identity and start labwc.
- labwc for window management and compositor duties.
- waybar for the panel and task list.
- wofi for launcher and quick menus.
- swaybg for the default wallpaper.
- mako for notifications.
- grim, slurp, wl-clipboard, and `aptura-screenshot` for screenshots.
- SDDM as the display manager.
- xdg-desktop-portal-wlr for wlroots portal integration.
- Aptura color assets and GTK skeleton settings for applications that honor
  them.
- `Aptura-Shell` GTK fallback theme for GTK applications that honor it.
- `Aptura-Shell` icon theme with hicolor and Adwaita fallback.

## Visual Direction

### Aptura Shell Palette

- Deep space: `#12142b`
- Electric teal: `#00d9c0`
- Solar magenta: `#ff4fd8`
- Grid violet: `#7a4dff`
- Warm sun: `#ffb14a`
- Workbench gray: `#c0c0c0`
- Signal yellow: `#ffe45c`

### Shell

- The top panel should expose the main controls without feeling busy.
- The launcher should be fast, keyboard-friendly, and visually tied to the
  Aptura palette.
- The contextual default wallpaper is `aptura-context-grid.svg`; the retro
  wallpaper remains available as a classic fallback.
- Plymouth, GRUB, Calamares, and the shell session should present the same
  Aptura Shell naming.

### Icons

The custom icon theme starts small and falls back to hicolor/Adwaita. Aptura
should expand it over time with simple pixel-like icons for core actions:

- Folder and home.
- Computer and disk.
- Terminal.
- File manager.
- Settings.

## Workstation Tools

The default desktop should include practical packages that make the system feel
complete:

- Dolphin, Konsole, Kate, System Settings, Discover, and Spectacle as mature
  applications available from the Aptura Shell launcher.
- Synaptic for package management.
- fwupd for firmware updates.
- power-profiles-daemon for battery/performance modes.
- Blueman, NetworkManager applet, pavucontrol, and PipeWire/PulseAudio tools.
- Flatpak support for users who want app sandboxing.

## Future Extensions

Only add Aptura-specific shell widgets or services when they provide a clear
workflow improvement:

- Native update status plugin backed by PackageKit or a narrow APT service.
- Snapshot-based rollback profile when the installer supports Btrfs.
- More complete Aptura icon coverage.
- Accessibility and high-contrast validation before public beta.
