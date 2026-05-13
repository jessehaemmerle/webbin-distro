# Aptura Desktop

Aptura's desktop is a branded, tuned GNOME experience with a late 80s and early
90s workstation-inspired visual identity.

- GNOME Shell provides the compositor, session management, Wayland support, accessibility, and hardware integration.
- Aptura Retro branding is applied through wallpaper, login logo/banner, icon assets, GTK theme files, GNOME favorites, and dconf defaults.
- GTK apps should use square frames, chunky titlebars, bevel controls, and hard shadows where theming is honored.
- Aptura-specific tools should solve concrete system workflows, starting with Aptura System Check.
- Extra GNOME extensions or native apps should be added only after they are useful, testable, and maintainable.

Subdirectories:

- `settings-center/`: design notes for a native settings center.
- `greeter-theme/`: login/greeter theme notes.
- `wallpapers/`: wallpaper source notes and open asset policy.

TODO:

- Validate GNOME defaults and the Aptura Retro GTK theme on a booted ISO.
- Add D-Bus service boundaries before exposing privileged settings.
- Add native GNOME integration only for workflows that cannot be solved well with existing tools.
