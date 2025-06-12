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
sudo apt install live-build debootstrap
```

2. **Build the ISO**:
```bash
./scripts/build.sh
```

3. **Test the ISO**:
```bash
./scripts/test-vm.sh
```

### Installation

1. Download the latest ISO from releases
2. Create bootable USB: `dd if=custom-debian.iso of=/dev/sdX bs=4M`
3. Boot from USB and follow installer

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
