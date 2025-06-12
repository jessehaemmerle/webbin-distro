# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure
- Build system using live-build
- Sway Wayland compositor configuration
- Custom package selection for desktop use
- Automated testing in CI/CD
- Comprehensive documentation

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- AppArmor enabled by default
- UFW firewall pre-configured
- LUKS2 disk encryption support

## [1.0.0] - TBD

### Added
- Custom Debian distribution based on Bookworm
- Sway window manager with Waybar status bar
- Modern Wayland-based desktop environment
- Pre-configured multimedia support with PipeWire
- Development tools (VS Code, Git, build tools)
- Office applications (LibreOffice, Thunderbird)
- Graphics applications (GIMP, Inkscape)
- System utilities and package management
- Automated build system
- VM testing capabilities
- Comprehensive user and build documentation
- CI/CD pipeline with GitHub Actions
- Security hardening with AppArmor and firewall
- Network management with NetworkManager
- Hardware support for modern laptops and desktops

### Installation
- Calamares graphical installer
- UEFI and Legacy BIOS support
- Disk encryption options
- Preseed configuration for automation

### Desktop Experience
- Sway tiling window manager
- Custom keybindings for productivity
- Modern status bar with system information
- Application launcher with Rofi
- File manager with Nautilus
- Terminal applications (GNOME Terminal, Alacritty)

### Multimedia
- Firefox ESR web browser
- VLC media player
- Rhythmbox music player
- Image viewer and basic editing tools
- Full codec support for common formats

### Development
- Visual Studio Code editor
- Git version control
- Build tools and compilers
- Python 3 and Node.js runtime
- Package managers (APT, Flatpak support)

### System Management
- Systemd init system
- Automatic security updates
- System snapshot capability with Timeshift
- Hardware detection and driver installation
- Power management for laptops

---

## Release Notes Format

Each release includes:
- **ISO Image**: Bootable installation media
- **Checksums**: SHA256 and MD5 verification files
- **Documentation**: Updated user and build guides
- **Release Notes**: Detailed changelog and known issues

## Versioning Strategy

- **Major versions** (x.0.0): Significant changes, new base Debian version
- **Minor versions** (x.y.0): New features, package updates, improvements
- **Patch versions** (x.y.z): Bug fixes, security updates, minor corrections

## Support Lifecycle

- **Current Release**: Full support with updates and fixes
- **Previous Release**: Security updates for 6 months
- **LTS Releases**: Extended support for 2 years (planned for future)

## Migration Notes

When upgrading between major versions:
1. Backup important data
2. Test in virtual machine first
3. Review breaking changes in release notes
4. Follow migration guide (when applicable)

## Known Issues

### Current
- None reported

### Historical
- Issues resolved in previous versions are documented here
