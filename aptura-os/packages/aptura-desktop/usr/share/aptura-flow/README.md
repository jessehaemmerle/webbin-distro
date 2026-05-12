# Aptura Flow Runtime

This package installs the Aptura Flow system app and desktop integration points.

The React prototype lives in `desktop/shell`. This runtime is the packaged
system-app surface used by the ISO until the prototype is promoted to a native
WebView, Tauri, or GNOME Shell companion.

TODO:

- Wrap the frontend in Tauri, WebKitGTK, or a GNOME Shell extension companion.
- Add D-Bus services for update status, power profile, quick settings, and search.
