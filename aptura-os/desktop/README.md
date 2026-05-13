# Aptura Desktop

Aptura's desktop is a branded, tuned XFCE experience with a classic workstation
visual identity.

- XFCE provides the session, panel, desktop icons, window manager, and classic desktop workflow.
- Aptura Classic branding is applied through wallpaper, LightDM styling, icon assets, GTK theme files, XFWM4 borders, and xfconf defaults.
- GTK apps should use square frames, chunky titlebars, bevel controls, and hard shadows where theming is honored.
- XFWM4 window borders should carry the Aptura Classic feeling directly.
- Aptura-specific tools should solve concrete system workflows, starting with Aptura System Check.
- Extra XFCE plugins or native apps should be added only after they are useful, testable, and maintainable.

Subdirectories:

- `settings-center/`: design notes for a native settings center.
- `greeter-theme/`: login/greeter theme notes.
- `wallpapers/`: wallpaper source notes and open asset policy.

TODO:

- Validate XFCE defaults, the Aptura Classic GTK theme, and XFWM4 borders on a booted ISO.
- Add D-Bus service boundaries before exposing privileged settings.
- Add native XFCE integration only for workflows that cannot be solved well with existing tools.
