# Aptura Desktop

Aptura's desktop is a branded, tuned Wayland shell with a retro workstation
visual identity.

- Aptura Shell provides the default session through labwc, waybar, wofi, swaybg, mako, and Aptura control scripts.
- KDE Plasma remains installed as a fallback session and as a source of mature applications and settings tools.
- Aptura branding is applied through the context-grid wallpaper, Aptura color assets, logo assets, icon assets, GTK fallback theme files, Plymouth, Calamares, and SDDM defaults.
- GTK apps should remain visually compatible through the Aptura fallback theme where theming is honored.
- Panel, launcher, notifications, and settings should carry Aptura colors where upstream configuration allows it.
- Aptura-specific tools should solve concrete system workflows: System Check, Journey, Context, Shift, Aftercare, Live Bridge, Safe Update, Rescue Center, Privacy Check, Modes, and Support Bundle.
- Extra shell widgets or native apps should be added only after they are useful, testable, and maintainable.

Subdirectories:

- `settings-center/`: design notes for a native settings center.
- `greeter-theme/`: login/greeter theme notes.
- `wallpapers/`: wallpaper source notes and open asset policy.

TODO:

- Validate Aptura Shell defaults, the Aptura accent palettes, context-grid wallpaper, panel, launcher, and GTK skeleton settings on a booted ISO.
- Add D-Bus service boundaries before exposing privileged settings.
- Add native shell integration only for workflows that cannot be solved well with existing tools.
