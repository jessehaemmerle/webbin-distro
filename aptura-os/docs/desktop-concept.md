# Aptura Flow Desktop Concept

## UX Philosophy

Aptura Flow is a reduced, productivity-focused desktop layer. It should make
common desktop actions visible without burying users in control panels.

Principles:

- Fast launch, search, and switching.
- Clear system state.
- Keyboard and touchpad first, pointer friendly.
- Dark and light modes with configurable accent color.
- No telemetry or cloud dependency by default.
- Calm visuals with useful motion, not decorative excess.

## Technical Choice

The MVP uses GNOME Shell as the base session and Aptura Flow as a custom
companion surface.

Reasoning:

- GNOME Shell already provides Wayland, accessibility, input handling, workspace
  management, session integration, and hardware support.
- Debian Stable packages GNOME well.
- A React prototype can be packaged quickly and later moved into WebKitGTK,
  Tauri, Electron, or a GNOME Shell extension.
- A custom Wayland compositor would be a multi-year project and is outside the
  MVP boundary.

## Core Components

### Dashboard

Central overview with session state, upcoming work, and launch entry points.

### App Launcher

Searchable app grid with room for files, settings, and commands.

### Workspace Overview

Visual workspace cards for switching and organizing work.

### Notification Center

Unified notification list with severity and time.

### Quick Settings

Controls for:

- Wi-Fi
- Bluetooth
- VPN
- Dark/light mode
- Updates
- Power profile
- Brightness
- Volume

### Settings Center

Modern system settings surface. In the MVP it is part of the frontend prototype.
Later it should call privileged system services through D-Bus and PolicyKit.

### Update Status

APT-aware update summary that separates security updates from regular updates.

### Welcome Wizard

First-run onboarding for network, language, privacy, appearance, and update
preferences.

### Local Assistant Placeholder

A local-only assistant can be added later as a placeholder interface. It must
not call external APIs by default and must clearly expose what local data it can
read.

## Design System

Visual style:

- Minimal panels.
- 8px card radius.
- Strong contrast.
- Accent color defaults to teal.
- Warm secondary color for attention states.
- Light and dark themes.
- Responsive layout down to small laptop screens.

Typography:

- Cantarell or Inter.
- No viewport-scaled type.
- Clear hierarchy between dashboard headings and compact panel titles.

Interaction:

- Search at the top level.
- Icon buttons with tooltips through `title`.
- Segmented controls for binary/limited choices.
- Swatches for accent color.
- Sliders for continuous values.

## Implementation

Prototype path:

```text
desktop/shell
```

Technology:

- Vite
- React
- CSS
- lucide-react icons

Run locally:

```bash
cd desktop/shell
npm install
npm run dev
```

Packaging path:

1. Build static assets with `npm run build`.
2. Replace the packaged static runtime in `packages/aptura-desktop/usr/share/aptura-flow/` with the Vite `dist/` output.
3. Replace the launcher with a WebKitGTK/Tauri wrapper.
4. Add D-Bus services for update and settings state.

## Future Extensions

- GNOME Shell extension for native overview integration.
- Search provider for files, settings, and APT packages.
- Power profile integration with `power-profiles-daemon`.
- Update backend using PackageKit or aptdaemon-style service.
- Accessibility review with screen readers and high contrast mode.
