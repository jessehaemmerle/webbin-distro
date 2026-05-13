# Aptura Desktop

Aptura's desktop is a branded, tuned Plasma experience with a retro workstation
visual identity.

- KDE Plasma provides the session, compositor, panel, launcher, settings, and core applications.
- Aptura branding is applied through the context-grid wallpaper, Aptura color assets, logo assets, icon assets, GTK fallback theme files, Plymouth, Calamares, and SDDM defaults.
- GTK apps should remain visually compatible through the Aptura fallback theme where theming is honored.
- Plasma widgets and settings should carry Aptura colors where upstream configuration allows it.
- Aptura-specific tools should solve concrete system workflows: System Check, Journey, Context, Shift, Aftercare, Live Bridge, Safe Update, Rescue Center, Privacy Check, Modes, and Support Bundle.
- Extra Plasma widgets or native apps should be added only after they are useful, testable, and maintainable.

Subdirectories:

- `settings-center/`: design notes for a native settings center.
- `greeter-theme/`: login/greeter theme notes.
- `wallpapers/`: wallpaper source notes and open asset policy.

TODO:

- Validate Plasma defaults, the Aptura accent palettes, context-grid wallpaper, and GTK skeleton settings on a booted ISO.
- Add D-Bus service boundaries before exposing privileged settings.
- Add native Plasma integration only for workflows that cannot be solved well with existing tools.
