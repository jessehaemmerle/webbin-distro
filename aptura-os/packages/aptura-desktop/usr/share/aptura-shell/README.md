# Aptura Shell

Aptura Shell is the distro-owned default desktop session for Aptura OS. It uses
`labwc` as the Wayland compositor and layers Aptura defaults around it:

- `aptura-session` exports the session identity and starts `labwc`.
- `aptura-panel` starts the Aptura `waybar` panel.
- `aptura-launcher` starts the Aptura `wofi` launcher.
- `aptura-control` provides launcher, mode, terminal, settings, and power menus.
- `aptura-screenshot` saves full-screen or region screenshots and copies them
  to the Wayland clipboard when available.

The session configuration lives below `/usr/share/aptura-shell/xdg/labwc` and
is added to `XDG_CONFIG_DIRS` by `aptura-session`. User configuration in
`~/.config/labwc` still wins, so the default can be customized without editing
package-owned files.
