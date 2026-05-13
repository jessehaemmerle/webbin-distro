# Aptura Desktop

Aptura's desktop is a branded, tuned GNOME experience.

- GNOME Shell provides the compositor, session management, Wayland support, accessibility, and hardware integration.
- Aptura branding is applied through wallpaper, login logo/banner, icon assets, GNOME favorites, and dconf defaults.
- Aptura-specific tools should solve concrete system workflows, starting with Aptura System Check.
- Extra GNOME extensions or native apps should be added only after they are useful, testable, and maintainable.

Subdirectories:

- `settings-center/`: design notes for a native settings center.
- `greeter-theme/`: login/greeter theme notes.
- `wallpapers/`: wallpaper source notes and open asset policy.

TODO:

- Validate GNOME defaults on a booted ISO.
- Add D-Bus service boundaries before exposing privileged settings.
- Add native GNOME integration only for workflows that cannot be solved well with existing tools.
