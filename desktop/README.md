# Aptura Shell desktop

The distro-owned default Wayland session. Built from maintained Ubuntu packages
with Aptura defaults layered on top — not a from-scratch compositor.

## Components

| Role            | Program                          |
|-----------------|----------------------------------|
| Compositor / WM | labwc                            |
| Panel / tasks   | waybar                           |
| Launcher        | wofi                             |
| Wallpaper       | swaybg                           |
| Notifications   | mako                             |
| Terminal        | foot                             |
| Screenshots     | grim + slurp + wl-clipboard      |
| Lock / idle     | swaylock + swayidle              |
| Display manager | SDDM                             |
| Portals         | xdg-desktop-portal-wlr + -gtk    |

## Layout (installed paths, set by the aptura-desktop package)

- `wayland-sessions/aptura.desktop` -> `/usr/share/wayland-sessions/`
- `bin/*` -> `/usr/bin/` (`aptura-session`, `aptura-screenshot`, `aptura-power-menu`)
- `config/labwc/*` -> `/etc/xdg/labwc/`
- `config/waybar/*` -> `/etc/xdg/waybar/`
- `config/wofi/*` -> `/etc/xdg/wofi/`
- `config/mako/*` -> `/etc/xdg/mako/`

System defaults live in `/etc/xdg` so users can override per-account under
`~/.config` without losing the Aptura baseline.

## Keybindings (labwc rc.xml)

- `Super+D` launcher · `Super+Return` terminal · `Super+E` files
- `Super+Q` close · `Super+F` maximize · `Super+Left/Right` snap
- `Print` screenshot · `Super+L` lock · `Alt+Tab` window switch
- Right-click desktop: Aptura root menu

KDE Plasma is **not** installed by default in this build; the session is
intentionally lightweight. Mature GTK apps (Nautilus, GNOME Software,
gnome-control-center) provide the file manager, store, and settings surfaces.
