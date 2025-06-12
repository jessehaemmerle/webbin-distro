# Build Guide

This guide provides detailed instructions for building the Custom Debian distribution from source.

## Prerequisites

### Build Environment
- **Operating System**: Debian 12 (Bookworm) or Ubuntu 22.04+
- **RAM**: 4GB minimum, 8GB recommended
- **Disk Space**: 20GB free space minimum
- **Network**: Stable internet connection for package downloads

### Required Packages

Install the build dependencies:

```bash
sudo apt update
sudo apt install -y \
    live-build \
    debootstrap \
    squashfs-tools \
    xorriso \
    isolinux \
    syslinux-efi \
    ovmf \
    qemu-system-x86 \
    qemu-utils
```

## Building the Distribution

### 1. Clone the Repository

```bash
git clone <repository-url>
cd custom-debian-distribution
```

### 2. Review Configuration

Before building, you may want to customize the configuration:

- **Package Lists**: Edit files in `config/package-lists/` to add or remove packages
- **Sway Configuration**: Modify `config/includes.chroot/etc/sway/config`
- **Hooks**: Add custom setup scripts in `hooks/`

### 3. Build the ISO

Run the build script:

```bash
./scripts/build.sh
```

The build process will:
1. Check dependencies
2. Set up live-build configuration
3. Download and configure packages
4. Create the ISO image
5. Generate checksums

### 4. Build Output

Upon successful completion, you'll find:
- `output/customdebian-1.0.iso` - The bootable ISO image
- `output/customdebian-1.0.iso.sha256` - SHA256 checksum
- `output/customdebian-1.0.iso.md5` - MD5 checksum

## Testing the Build

### Virtual Machine Testing

Test the ISO in a virtual machine:

```bash
./scripts/test-vm.sh
```

This script will:
- Detect available QEMU/KVM
- Create a test VM
- Boot from the ISO
- Allow testing both UEFI and BIOS modes

### Test Checklist

Verify the following functionality:
- [ ] System boots successfully
- [ ] Sway desktop environment starts
- [ ] Network connectivity works
- [ ] Audio functions properly
- [ ] USB devices are recognized
- [ ] Installation process completes
- [ ] Installed system boots correctly

## Customization

### Adding Packages

1. Edit the appropriate package list in `config/package-lists/`:
   - `desktop.list.chroot` - Desktop applications
   - `multimedia.list.chroot` - Media codecs and tools
   - `system.list.chroot` - System utilities

2. Rebuild the ISO:
   ```bash
   ./scripts/build.sh
   ```

### Custom Configuration Files

1. Add files to `config/includes.chroot/` following the filesystem hierarchy
2. Files will be copied to the live system during build

### Build Hooks

1. Create shell scripts in `hooks/` with `.hook.chroot` extension
2. Scripts run in the chroot environment during build
3. Use for system configuration and setup tasks

## Troubleshooting

### Build Fails with Permission Errors

Ensure the build script is not run as root:
```bash
# Wrong - don't do this
sudo ./scripts/build.sh

# Correct
./scripts/build.sh
```

### Missing Dependencies

If packages are missing:
```bash
sudo apt install --fix-missing
sudo apt install -f
```

### Disk Space Issues

Check available space:
```bash
df -h .
```

Clean previous builds:
```bash
sudo rm -rf build/
```

### Package Download Failures

Check internet connectivity and try again:
```bash
ping -c 4 deb.debian.org
```

### QEMU Testing Issues

Install additional QEMU packages:
```bash
sudo apt install qemu-system-gui ovmf
```

## Advanced Configuration

### Custom Kernel

To use a custom kernel:
1. Add kernel packages to `system.list.chroot`
2. Create a hook to configure the kernel
3. Update the live-build configuration

### Custom Installer

To modify the installer:
1. Edit `config/preseed.cfg`
2. Add custom installer packages
3. Create installer hooks

### Branding

To customize branding:
1. Replace files in `config/includes.chroot/usr/share/`
2. Update splash screens and wallpapers
3. Modify GDM themes

## Performance Tips

### Faster Builds

- Use local package mirror
- Enable parallel downloads
- Use SSD storage for build directory
- Increase available RAM

### Build Cache

Live-build caches packages automatically. To clean cache:
```bash
sudo lb clean --cache
```

## CI/CD Integration

For automated builds, see the GitHub Actions workflow in `.github/workflows/build.yml`.

The workflow:
- Builds on multiple architectures
- Runs automated tests
- Publishes releases
- Generates build artifacts

## Build Logs

Build logs are stored in:
- `build/build.log` - Main build log
- `build/config/` - Live-build configuration
- `build/cache/` - Package cache

For verbose output:
```bash
LB_DEBUG=true ./scripts/build.sh
```
