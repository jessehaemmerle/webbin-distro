# Aptura Desktop

Aptura's desktop is a branded, tuned COSMIC experience with a retro workstation
visual identity.

- COSMIC provides the session, compositor, panel, launcher, app library, settings, and core applications.
- Aptura branding is applied through wallpaper, COSMIC accent palettes, logo assets, icon assets, GTK fallback theme files, Plymouth, Calamares, and greeter defaults.
- GTK apps should remain visually compatible through the Aptura fallback theme where theming is honored.
- COSMIC applets and settings should carry Aptura colors where upstream configuration allows it.
- Aptura-specific tools should solve concrete system workflows, starting with Aptura System Check.
- Extra COSMIC applets or native apps should be added only after they are useful, testable, and maintainable.

Subdirectories:

- `settings-center/`: design notes for a native settings center.
- `greeter-theme/`: login/greeter theme notes.
- `wallpapers/`: wallpaper source notes and open asset policy.

TODO:

- Validate COSMIC defaults, the Aptura accent palettes, and wallpaper on a booted ISO.
- Add D-Bus service boundaries before exposing privileged settings.
- Add native COSMIC integration only for workflows that cannot be solved well with existing tools.
