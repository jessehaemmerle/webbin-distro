# Aptura Desktop

The desktop layer is named **Aptura Flow**.

MVP architecture:

- GNOME Shell provides the compositor, session management, Wayland support, accessibility, and hardware integration.
- Aptura Flow is a custom UX layer packaged as a shell companion dashboard and settings surface.
- The prototype in `desktop/shell` uses Vite + React and can later be wrapped with Tauri, WebKitGTK, Electron, or split into a GNOME extension plus native settings app.

Subdirectories:

- `shell/`: interactive Aptura Flow prototype.
- `settings-center/`: design notes for a native settings center.
- `greeter-theme/`: login/greeter theme notes.
- `wallpapers/`: wallpaper source notes and open asset policy.

TODO:

- Convert the prototype into a packaged runtime artifact.
- Add D-Bus service boundaries for settings and privileged actions.
- Add GNOME extension integration for workspace and quick settings data.
