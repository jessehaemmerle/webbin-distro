# Aptura Classic XFCE Desktop Concept

## UX Philosophy

Aptura uses XFCE as the desktop foundation and gives it a deliberate classic
workstation identity. The design should feel like a coherent system from the
first boot screen through the desktop, not a modern desktop with a retro
wallpaper.

Principles:

- Use XFCE because xfwm4, xfce4-panel, Thunar, and xfconf are lightweight,
  themeable, and close to the classic desktop model.
- Make the whole shell feel period-consistent: window borders, controls, panel,
  wallpaper, login screen, icons, and installer should share one palette.
- Prefer useful local tools over mock surfaces.
- Keep privacy defaults conservative.
- Avoid soft blur, rounded cards, gradients as decoration, and oversized modern
  typography.

## Technical Choice

The MVP uses:

- XFCE session with xfwm4 window management.
- LightDM with lightdm-gtk-greeter for login.
- xfconf defaults for panel, window manager, desktop background, icons, and GTK
  settings.
- `Aptura-Classic` GTK theme for application controls.
- `Aptura-Classic` XFWM4 theme for custom window borders and title buttons.
- `Aptura-Classic` icon theme with hicolor and Adwaita fallback.
- Aptura System Check for local status reporting.

## Visual Direction

### Aptura Classic Palette

- Desktop teal: `#008080`
- Active title blue: `#000080`
- Workbench gray: `#c0c0c0`
- Highlight white: `#ffffff`
- Shadow black: `#000000`
- Mid shadow gray: `#808080`
- Warning yellow: `#ffff00`

### Window Borders

XFWM4 owns the period feel:

- Active windows use navy titlebars.
- Inactive windows use gray titlebars.
- Borders use white top/left and black bottom/right highlights.
- Title buttons are raised square XPM assets with pressed variants.
- Menu, minimize, maximize, close, shade, and stick buttons are provided.

### Desktop Shell

- Bottom XFCE panel acts like a taskbar.
- Application menu button is labeled `Aptura` and uses the distributor logo.
- Task list shows window labels.
- System tray, audio, and clock stay on the right.
- Desktop icons remain visible for filesystem, home, removable media, and trash.

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

- Thunar with archive and volume plugins.
- xfce4-terminal, Mousepad, Ristretto, Xarchiver, and xfce4-taskmanager.
- Synaptic for package management.
- fwupd for firmware updates.
- power-profiles-daemon and xfce4-power-manager for battery/performance modes.
- Blueman, NetworkManager applet, pavucontrol, and the PulseAudio panel plugin.
- Flatpak support for users who want app sandboxing.

## Future Extensions

Only add Aptura-specific XFCE plugins or services when they provide a clear
workflow improvement:

- First-run checklist for updates, firmware, backups, privacy, and restore
  media.
- Native update status plugin backed by PackageKit or a narrow APT service.
- Snapshot-based rollback profile when the installer supports Btrfs.
- More complete Aptura Classic icon coverage.
- Accessibility and high-contrast validation before public beta.
