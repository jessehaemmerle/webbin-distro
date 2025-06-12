# User Guide

Welcome to WebbinOS! This guide will help you install and use your new Linux distribution.

## System Requirements

### Minimum Requirements
- **CPU**: 64-bit x86 processor (Intel/AMD)
- **RAM**: 2GB (4GB recommended)
- **Storage**: 20GB (50GB recommended)
- **Graphics**: DirectX 9 compatible
- **Network**: Ethernet or WiFi

### Recommended Requirements
- **CPU**: Dual-core 2GHz or faster
- **RAM**: 8GB or more
- **Storage**: 100GB or more (SSD preferred)
- **Graphics**: Modern integrated or dedicated GPU

## Installation

### Creating Installation Media

#### USB Drive (Recommended)

1. Download the ISO file
2. Create bootable USB:
   ```bash
   # Linux/macOS
   sudo dd if=customdebian-1.0.iso of=/dev/sdX bs=4M status=progress
   
   # Windows (use Rufus or similar tool)
   ```

3. Replace `/dev/sdX` with your USB device (be careful!)

#### DVD

Burn the ISO to a DVD using your preferred burning software.

### Installation Process

1. **Boot from Installation Media**
   - Restart your computer
   - Access boot menu (usually F12, F8, or ESC)
   - Select USB/DVD drive

2. **Choose Installation Mode**
   - **Live Mode**: Try the system without installing
   - **Install**: Proceed directly to installation
   - **Advanced Options**: Additional boot parameters

3. **Installation Steps**
   - Select language and region
   - Configure keyboard layout
   - Set up network connection
   - Partition hard drive
   - Create user account
   - Install system files
   - Configure bootloader

4. **First Boot**
   - Remove installation media
   - Restart computer
   - Complete initial setup

## Desktop Environment

Custom Debian uses Sway, a modern Wayland-based window manager.

### Key Bindings

#### Basic Navigation
- `Super + Enter` - Open terminal
- `Super + D` - Application launcher
- `Super + Shift + Q` - Close window
- `Super + Shift + E` - Exit Sway

#### Window Management
- `Super + Arrow Keys` - Move focus
- `Super + Shift + Arrow Keys` - Move window
- `Super + F` - Toggle fullscreen
- `Super + Shift + Space` - Toggle floating

#### Workspaces
- `Super + 1-9` - Switch to workspace
- `Super + Shift + 1-9` - Move window to workspace

#### Layouts
- `Super + S` - Stacking layout
- `Super + W` - Tabbed layout
- `Super + E` - Split layout
- `Super + B` - Horizontal split
- `Super + V` - Vertical split

### Status Bar

The top bar shows:
- Workspaces (left)
- Current window title (center)
- System information (right)
  - Audio volume
  - Network status
  - Battery level
  - Date and time

## Applications

### Pre-installed Software

#### Web and Communication
- **Firefox ESR** - Web browser
- **Thunderbird** - Email client

#### Office and Productivity
- **LibreOffice** - Office suite
- **Document Viewer** - PDF reader
- **Text Editor** - Simple text editing

#### Multimedia
- **VLC** - Media player
- **Rhythmbox** - Music player
- **Image Viewer** - Photo viewing

#### Graphics and Design
- **GIMP** - Image editing
- **Inkscape** - Vector graphics

#### Development
- **Visual Studio Code** - Code editor
- **Terminal** - Command line interface
- **Git** - Version control

### Installing Additional Software

#### Using GUI (Synaptic)
1. Open application launcher (`Super + D`)
2. Type "Synaptic Package Manager"
3. Search for desired software
4. Mark for installation
5. Apply changes

#### Using Command Line
```bash
# Update package lists
sudo apt update

# Install software
sudo apt install package-name

# Search for packages
apt search keyword

# Remove software
sudo apt remove package-name
```

#### Flatpak Support
```bash
# Install Flatpak
sudo apt install flatpak

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install applications
flatpak install flathub org.application.name
```

## System Configuration

### Network Setup

#### WiFi
1. Click network icon in status bar
2. Select your network
3. Enter password
4. Connect

#### Command Line WiFi
```bash
# List available networks
nmcli device wifi list

# Connect to network
nmcli device wifi connect "NetworkName" password "password"
```

### Audio Configuration

Audio is managed by PipeWire with PulseAudio compatibility.

#### Volume Control
- Use volume keys on keyboard
- Or run: `pavucontrol` for GUI mixer

### Display Configuration

#### Single Monitor
Automatic configuration should work out of the box.

#### Multiple Monitors
Edit Sway configuration:
```bash
nano ~/.config/sway/config

# Add output configuration
output HDMI-A-1 resolution 1920x1080 position 1920,0
output eDP-1 resolution 1920x1080 position 0,0
```

#### Resolution and Scaling
```bash
# List available outputs
swaymsg -t get_outputs

# Set resolution
output DP-1 resolution 2560x1440

# Set scaling
output DP-1 scale 1.5
```

### Keyboard and Input

#### Keyboard Layout
```bash
# Temporary change
setxkbmap layout

# Permanent change - edit Sway config
input "type:keyboard" {
    xkb_layout us,de
    xkb_options grp:alt_shift_toggle
}
```

#### Touchpad Settings
```bash
# Edit Sway config
input "type:touchpad" {
    dwt enabled
    tap enabled
    natural_scroll enabled
    middle_emulation enabled
}
```

## Customization

### Themes and Appearance

#### GTK Themes
```bash
# Install additional themes
sudo apt install arc-theme adapta-gtk-theme

# Set theme
gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark"
```

#### Icon Themes
```bash
# Install icon themes
sudo apt install papirus-icon-theme

# Set icons
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
```

### Sway Configuration

Edit `~/.config/sway/config` to customize:
- Key bindings
- Startup applications
- Window rules
- Visual effects

### Waybar Customization

Edit `~/.config/waybar/config` and `~/.config/waybar/style.css` to customize the status bar.

## System Maintenance

### Updates

#### Automatic Updates
Security updates are installed automatically. For full system updates:

```bash
sudo apt update && sudo apt upgrade
```

#### Managing Automatic Updates
```bash
# Configure unattended upgrades
sudo dpkg-reconfigure unattended-upgrades
```

### System Cleanup

```bash
# Remove unnecessary packages
sudo apt autoremove

# Clean package cache
sudo apt autoclean

# Using BleachBit (GUI)
bleachbit
```

### Backup and Recovery

#### Timeshift (System Snapshots)
```bash
# Install if not present
sudo apt install timeshift

# Create snapshot
sudo timeshift --create --comments "Before major change"

# Restore snapshot
sudo timeshift --restore
```

#### Home Directory Backup
```bash
# Backup to external drive
rsync -avh /home/username/ /media/backup/

# Restore from backup
rsync -avh /media/backup/ /home/username/
```

## Troubleshooting

### Boot Issues

#### GRUB Menu Not Showing
```bash
# Boot from live USB, mount system, and run:
sudo update-grub
sudo grub-install /dev/sda
```

#### System Won't Boot
1. Boot from live USB
2. Mount system partition
3. Chroot into system
4. Repair bootloader or system files

### Display Issues

#### Black Screen After Login
1. Switch to TTY: `Ctrl + Alt + F2`
2. Login and check logs: `journalctl -xe`
3. Restart display manager: `sudo systemctl restart gdm`

#### Sway Won't Start
```bash
# Check Sway logs
journalctl --user -u sway

# Start Sway manually
sway
```

### Network Issues

#### No WiFi Networks Visible
```bash
# Restart NetworkManager
sudo systemctl restart NetworkManager

# Check wireless interface
ip link show

# Check for missing firmware
dmesg | grep firmware
```

### Audio Issues

#### No Sound
```bash
# Check audio devices
pactl list sinks

# Restart audio
systemctl --user restart pipewire
```

### Getting Help

- **Documentation**: `/usr/share/doc/`
- **Man Pages**: `man command-name`
- **System Logs**: `journalctl`
- **Community Forums**: [Links to forums]
- **Bug Reports**: [Links to issue tracker]

## Advanced Usage

### Command Line Productivity

#### Terminal Multiplexer
```bash
# Install tmux
sudo apt install tmux

# Basic usage
tmux new-session
tmux attach-session
```

#### Shell Enhancements
```bash
# Install zsh and oh-my-zsh
sudo apt install zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Development Setup

#### Programming Languages
```bash
# Python
sudo apt install python3-dev python3-venv

# Node.js (latest)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install nodejs

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

#### Containers
```bash
# Docker
sudo apt install docker.io
sudo usermod -aG docker $USER

# Podman (rootless alternative)
sudo apt install podman
```

This completes the user guide. The system is designed to be intuitive while providing powerful customization options for advanced users.
