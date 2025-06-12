#!/bin/bash

# Modern Sway Autostart Script

# Kill any existing instances
killall -q waybar
killall -q mako

# Wait for processes to shut down
while pgrep -x waybar >/dev/null; do sleep 1; done
while pgrep -x mako >/dev/null; do sleep 1; done

# Start compositor features
swaybg -m fill -i ~/.config/sway/wallpapers/modern-gradient.jpg &

# Start notification daemon
mako &

# Start waybar
waybar &

# Start network manager applet
nm-applet --indicator &

# Start bluetooth manager
blueman-applet &

# Set cursor theme
gsettings set org.gnome.desktop.interface cursor-theme 'Breeze_Snow'

# Set GTK theme
gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark'
gsettings set org.gnome.desktop.wm.preferences theme 'Arc-Dark'

# Set icon theme
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# Set font
gsettings set org.gnome.desktop.interface font-name 'Inter 11'
gsettings set org.gnome.desktop.interface document-font-name 'Inter 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'FiraCode Nerd Font 10'

# Night light (blue light filter)
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000

echo "Autostart completed"
