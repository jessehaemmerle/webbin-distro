# Aptura GNOME Desktop Concept

## UX Philosophy

Aptura uses GNOME as the desktop foundation and adds practical distribution
defaults plus a retro workstation visual language instead of maintaining a
custom shell surface.

Principles:

- Stay close to upstream GNOME for stability, accessibility, Wayland support,
  and hardware integration.
- Make useful system state visible without telemetry or cloud accounts.
- Prefer real installed tools over mock dashboards.
- Keep privacy defaults conservative.
- Use Aptura Retro branding consistently across boot, login, wallpaper, icons,
  GTK theme files, and GNOME defaults.
- Evoke late 80s and early 90s workstations with square frames, bevel controls,
  hard shadows, dithered surfaces, and restrained teal/magenta/amber accents.
- Make first boot feel ready for work: updates, firmware, power, storage,
  backups, and installer access should be discoverable.

## Technical Choice

The MVP uses:

- GNOME Shell and Mutter for the session.
- GDM for login.
- GNOME Control Center for broad settings coverage.
- dconf defaults for Aptura appearance, privacy, favorites, and workflow.
- `Aptura-Retro` GTK theme files for GTK 3 and GTK 4 surfaces.
- Aptura System Check for local status reporting.

This avoids the maintenance cost of a custom desktop shell while still giving
Aptura OS a recognizable identity and useful default behavior.

## Core Defaults

### Aptura Retro Branding

- Dithered workbench wallpaper with layered retro application windows.
- Aptura logo on the GNOME login screen.
- Dark color scheme by default.
- Teal accent color where supported by the GNOME version.
- Magenta and amber secondary accents for focus and attention states.
- Square GTK controls, visible titlebars, bevel borders, and hard shadows.
- Aptura icon reused for distro utilities.

### Useful Launcher Baseline

Default favorites should expose the tasks a new user actually needs:

- Browser.
- Files.
- Terminal.
- Settings.
- Software.
- Aptura System Check.
- Installer in the live session.

### System Check

Aptura System Check is a local terminal utility. It reports:

- APT upgrade count.
- Unattended upgrade timer state.
- Firmware readiness through fwupd.
- AppArmor, firewall, and SSH server state.
- Power profile.
- Network and Bluetooth service state.
- Root and home filesystem usage.

It deliberately avoids remote APIs and does not send telemetry.

### Workstation Tools

The default desktop should include practical packages that make the system feel
complete:

- GNOME Software with Flatpak plugin.
- fwupd for firmware updates.
- power-profiles-daemon for battery/performance modes.
- GNOME Disk Utility and Baobab for storage inspection.
- Deja Dup for backups.
- Evince, File Roller, Seahorse, and GNOME System Monitor.
- switcheroo-control for hybrid graphics support where available.

## Design System

Visual style:

- Late 80s and early 90s workstation inspiration without fake nostalgia text.
- Square window frames and titlebars.
- Raised buttons and inset entries using 1px/2px bevels.
- Hard black shadows instead of soft blur.
- Dither/checker textures in wallpaper and login surfaces.
- Aptura teal as the primary accent, with magenta and amber as secondary accents.
- Dark desktop base with light workbench panels.
- 0px radii where custom UI is introduced.
- No decorative dashboard layer unless it solves a real system workflow.

Typography:

- Cantarell/Adwaita defaults.
- No viewport-scaled type.
- Clear hierarchy between system surfaces and compact controls.

Interaction:

- Standard GNOME keyboard, workspace, and search behavior.
- Minimize, maximize, and menu buttons enabled for a more classic window model.
- Edge tiling and dynamic workspaces enabled.
- File chooser sorts directories first.

## Future Extensions

Only add Aptura-specific GNOME extensions or services when they provide a clear
workflow improvement:

- Native update status integration backed by PackageKit or a narrow APT
  service.
- Search provider for system documentation, settings, and local packages.
- First-run checklist for privacy, updates, backups, firmware, and restore
  media.
- Snapshot-based rollback profile when the installer supports Btrfs.
- Accessibility and high-contrast validation before public beta.
