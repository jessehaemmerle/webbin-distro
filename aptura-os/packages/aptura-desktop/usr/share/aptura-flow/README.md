# Aptura Flow Runtime Placeholder

This package installs the launcher and integration points for Aptura Flow.

The React prototype lives in `desktop/shell`. A production build should copy the
compiled Vite output into this directory as `index.html` and static assets.

TODO:

- Build `desktop/shell` during package creation.
- Wrap the frontend in Tauri, WebKitGTK, or a GNOME Shell extension companion.
- Add D-Bus services for update status, power profile, quick settings, and search.
