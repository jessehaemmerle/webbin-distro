# Aptura GNOME Desktop Concept

## UX Philosophy

Aptura uses GNOME as the desktop foundation and adds practical distribution
defaults instead of maintaining a custom shell surface.

Principles:

- Stay close to upstream GNOME for stability, accessibility, Wayland support,
  and hardware integration.
- Make useful system state visible without telemetry or cloud accounts.
- Prefer real installed tools over mock dashboards.
- Keep privacy defaults conservative.
- Use Aptura branding consistently across boot, login, wallpaper, icons, and
  GNOME defaults.
- Make first boot feel ready for work: updates, firmware, power, storage,
  backups, and installer access should be discoverable.

## Technical Choice

The MVP uses:

- GNOME Shell and Mutter for the session.
- GDM for login.
- GNOME Control Center for broad settings coverage.
- dconf defaults for Aptura appearance, privacy, favorites, and workflow.
- Aptura System Check for local status reporting.

This avoids the maintenance cost of a custom desktop shell while still giving
Aptura OS a recognizable identity and useful default behavior.

## Core Defaults

### Aptura Branding

- Aptura wallpaper for light and dark backgrounds.
- Aptura logo on the GNOME login screen.
- Dark color scheme by default.
- Teal accent color where supported by the GNOME version.
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

- Calm, high-contrast GNOME defaults.
- Aptura teal as the primary accent.
- Dark mode by default, with light mode available.
- 8px or smaller radii where custom UI is introduced.
- No decorative dashboard layer unless it solves a real system workflow.

Typography:

- Cantarell/Adwaita defaults.
- No viewport-scaled type.
- Clear hierarchy between system surfaces and compact controls.

Interaction:

- Standard GNOME keyboard, workspace, and search behavior.
- Minimize and maximize buttons enabled for broader desktop expectations.
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
