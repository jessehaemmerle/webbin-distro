# Custom Debian Distribution

A modern, Wayland-based Linux distribution built on Debian foundations, optimized for laptop and desktop use.

## 🚀 Features

- **Base**: Debian 12 (Bookworm) Stable
- **Desktop**: Sway (Wayland compositor) with Waybar
- **Security**: Full disk encryption, AppArmor, UFW firewall
- **Modern**: Latest Wayland technologies and PipeWire audio
- **Development Ready**: VS Code, Git, build tools pre-installed
- **Multimedia**: Complete codec support and media applications
- **Minimal**: Clean, focused package selection (82 packages)

## Quick Start

### Building the Distribution

1. **Set up build environment** (on Debian/Ubuntu):
```bash
sudo apt update
sudo apt install live-build debootstrap squashfs-tools xorriso isolinux syslinux-efi
```

2. **Build the ISO**:
```bash
./scripts/build.sh
```

3. **Test the ISO**:
```bash
./scripts/test-vm.sh
```

4. **Maintenance**:
```bash
./scripts/maintenance.sh validate  # Check configuration
./scripts/maintenance.sh stats     # Show project statistics
./scripts/maintenance.sh clean     # Clean build artifacts
```

### Installation

1. Download the latest ISO from releases
2. Create bootable USB: `dd if=customdebian-1.0.iso of=/dev/sdX bs=4M status=progress`
3. Boot from USB and follow the Calamares installer

## 📋 What's Included

### Desktop Environment
- **Sway**: Tiling Wayland compositor
- **Waybar**: Modern status bar
- **Rofi**: Application launcher
- **GDM3**: Display manager
- **Nautilus**: File manager

### Applications
- **Firefox ESR**: Web browser
- **Thunderbird**: Email client
- **LibreOffice**: Office suite
- **GIMP**: Image editor
- **Inkscape**: Vector graphics
- **VLC**: Media player
- **VS Code**: Code editor

### System Tools
- **PipeWire**: Modern audio system
- **NetworkManager**: Network management
- **UFW**: Firewall
- **AppArmor**: Security framework
- **Timeshift**: System snapshots

## Documentation

- [Design Document](DESIGN.md) - Technical architecture and specifications
- [Build Guide](docs/BUILD.md) - Detailed build instructions
- [User Guide](docs/USER.md) - Installation and usage guide

## Development

### Project Structure
```
/
├── scripts/          # Build and utility scripts
├── config/           # Live-build configuration
├── docs/            # Documentation
├── tests/           # Testing scripts
└── hooks/           # Custom build hooks
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the GPL v3 - see the [LICENSE](LICENSE) file for details.

## Support

- Issues: GitHub Issues
- Documentation: [Wiki](../../wiki)
- Community: [Discussions](../../discussions)
