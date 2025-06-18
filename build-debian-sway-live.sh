#!/bin/bash
# Debian Sway Live System Build Script
# Creates a bootable Debian live system with Sway window manager

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "This script must be run as root"
    exit 1
fi

# Check if live-build is installed
if ! command -v lb >/dev/null 2>&1; then
    error "live-build is not installed. Please install it first:"
    error "apt update && apt install -y live-build live-config live-boot debootstrap"
    exit 1
fi

# Set working directory
WORK_DIR="/app/debian-sway-live"
BUILD_START=$(date +%s)

log "Starting Debian Sway Live System build..."
log "Working directory: $WORK_DIR"

# Check if directory exists
if [ ! -d "$WORK_DIR" ]; then
    error "Build directory does not exist: $WORK_DIR"
    exit 1
fi

# Change to working directory
cd "$WORK_DIR"

# Check disk space
AVAILABLE_SPACE=$(df . | tail -1 | awk '{print $4}')
REQUIRED_SPACE=4000000  # 4GB in KB

if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
    warning "Available disk space: $(($AVAILABLE_SPACE / 1024))MB"
    warning "Recommended space: $(($REQUIRED_SPACE / 1024))MB"
    warning "Build may fail due to insufficient disk space"
fi

# Clean previous builds
log "Cleaning previous builds..."
lb clean --all || true

# Configuration
log "Running live-build configuration..."
lb config \
    --distribution bookworm \
    --architectures arm64 \
    --linux-flavours generic \
    --debian-installer live \
    --debian-installer-gui false \
    --bootappend-live "boot=live locales=de_DE.UTF-8 keyboard-layouts=de timezone=Europe/Vienna" \
    --bootappend-install "locales=de_DE.UTF-8 keyboard-layouts=de timezone=Europe/Vienna" \
    --mirror-bootstrap "http://deb.debian.org/debian" \
    --mirror-chroot "http://deb.debian.org/debian" \
    --mirror-chroot-security "http://deb.debian.org/debian-security" \
    --mirror-binary "http://deb.debian.org/debian" \
    --mirror-binary-security "http://deb.debian.org/debian-security" \
    --archive-areas "main contrib non-free non-free-firmware" \
    --security true \
    --updates true \
    --backports false \
    --parent-mirror-bootstrap "http://deb.debian.org/debian" \
    --parent-mirror-chroot "http://deb.debian.org/debian" \
    --parent-mirror-binary "http://deb.debian.org/debian" \
    --parent-archive-areas "main contrib non-free non-free-firmware" \
    --mode debian \
    --system live \
    --image-name "debian-sway-live" \
    --iso-volume "Debian Sway Live" \
    --iso-publisher "Custom Debian Live Build" \
    --win32-loader false

if [ $? -ne 0 ]; then
    error "Configuration phase failed"
    exit 1
fi

success "Configuration phase completed"

# Bootstrap
log "Starting bootstrap phase..."
lb bootstrap

if [ $? -ne 0 ]; then
    error "Bootstrap phase failed"
    exit 1
fi

success "Bootstrap phase completed"

# Chroot
log "Starting chroot phase..."
lb chroot

if [ $? -ne 0 ]; then
    error "Chroot phase failed"
    exit 1
fi

success "Chroot phase completed"

# Installer
log "Starting installer phase..."
lb installer

if [ $? -ne 0 ]; then
    error "Installer phase failed"
    exit 1
fi

success "Installer phase completed"

# Binary
log "Starting binary phase (ISO creation)..."
lb binary

if [ $? -ne 0 ]; then
    error "Binary phase failed"
    exit 1
fi

success "Binary phase completed"

# Calculate build time
BUILD_END=$(date +%s)
BUILD_TIME=$((BUILD_END - BUILD_START))
BUILD_TIME_MIN=$((BUILD_TIME / 60))
BUILD_TIME_SEC=$((BUILD_TIME % 60))

# Check if ISO was created
if [ -f "live-image-arm64.hybrid.iso" ]; then
    ISO_SIZE=$(ls -lh live-image-arm64.hybrid.iso | awk '{print $5}')
    ISO_PATH=$(readlink -f live-image-arm64.hybrid.iso)
    
    success "Build completed successfully!"
    log "Build time: ${BUILD_TIME_MIN}m ${BUILD_TIME_SEC}s"
    log "ISO file: $ISO_PATH"
    log "ISO size: $ISO_SIZE"
    
    # Create a more user-friendly filename
    FRIENDLY_NAME="debian-sway-live-$(date +%Y%m%d).iso"
    cp "live-image-arm64.hybrid.iso" "$FRIENDLY_NAME"
    success "ISO also saved as: $(readlink -f $FRIENDLY_NAME)"
    
    log ""
    log "=== BUILD SUMMARY ==="
    log "Distribution: Debian bookworm (stable)"
    log "Architecture: ARM64"
    log "Window Manager: Sway (Wayland)"
    log "Localization: German (DE keyboard, Vienna timezone)"
    log "Build time: ${BUILD_TIME_MIN}m ${BUILD_TIME_SEC}s"
    log "ISO size: $ISO_SIZE"
    log ""
    log "=== INCLUDED SOFTWARE ==="
    log "• Sway tiling window manager with custom configuration"
    log "• Waybar status bar with system information"
    log "• Foot terminal with Nord theme"
    log "• Mako notification daemon"
    log "• Chromium and Firefox browsers"
    log "• Thunar file manager"
    log "• Development tools (git, nano, python3, nodejs)"
    log "• Graphics drivers and firmware"
    log "• German localization"
    log ""
    log "=== USAGE ==="
    log "1. Write the ISO to a USB drive:"
    log "   dd if=$FRIENDLY_NAME of=/dev/sdX bs=4M status=progress"
    log "2. Boot from USB drive"
    log "3. Login automatically as 'user' (password: 'live')"
    log "4. Sway will start automatically"
    log "5. Use Super+Return to open terminal"
    log "6. Use Super+d to open application launcher"
    log ""
    log "=== KEY BINDINGS ==="
    log "Super+Return    - Open terminal"
    log "Super+d         - Application launcher"
    log "Super+Shift+q   - Close window"
    log "Super+f         - Fullscreen"
    log "Super+1-0       - Switch workspaces"
    log "Super+Shift+w   - Open Chromium"
    log "Super+Shift+f   - Open file manager"
    log "Print           - Screenshot"
    log ""
    
else
    error "Build failed - ISO file not found"
    exit 1
fi