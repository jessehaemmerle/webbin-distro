#!/bin/bash

# Custom Debian Distribution Build Script
# This script uses live-build to create a custom Debian ISO

set -e

# Configuration
DISTRO_NAME="CustomDebian"
DISTRO_VERSION="1.0"
BUILD_DIR="build"
OUTPUT_DIR="output"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root for security reasons"
        log_info "Use sudo only when prompted"
        exit 1
    fi
}

# Check dependencies
check_dependencies() {
    log_info "Checking build dependencies..."
    
    local deps=("live-build" "debootstrap" "squashfs-tools" "xorriso" "isolinux" "syslinux-efi")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! dpkg -l | grep -q "^ii  $dep "; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Install them with: sudo apt install ${missing_deps[*]}"
        exit 1
    fi
    
    log_info "All dependencies satisfied"
}

# Clean previous builds
clean_build() {
    log_info "Cleaning previous build..."
    
    if [[ -d "$BUILD_DIR" ]]; then
        sudo rm -rf "$BUILD_DIR"
    fi
    
    mkdir -p "$BUILD_DIR"
    mkdir -p "$OUTPUT_DIR"
}

# Setup live-build configuration
setup_config() {
    log_info "Setting up live-build configuration..."
    
    cd "$BUILD_DIR"
    
    # Initialize live-build configuration
    lb config \
        --distribution bookworm \
        --package-lists minimal \
        --architectures amd64 \
        --linux-flavours amd64 \
        --debian-installer live \
        --debian-installer-gui true \
        --bootappend-live "boot=live components locales=en_US.UTF-8 keyboard-layouts=us" \
        --bootloaders "syslinux,grub-efi" \
        --binary-images iso-hybrid \
        --iso-application "$DISTRO_NAME" \
        --iso-preparer "$DISTRO_NAME Build System" \
        --iso-publisher "$DISTRO_NAME Team" \
        --iso-volume "$DISTRO_NAME $DISTRO_VERSION" \
        --memtest memtest86+ \
        --win32-loader false
    
    cd ..
}

# Copy custom configurations
copy_configs() {
    log_info "Copying custom configurations..."
    
    # Copy package lists
    if [[ -d "config/package-lists" ]]; then
        cp -r config/package-lists "$BUILD_DIR/config/"
    fi
    
    # Copy includes (files to be included in the live system)
    if [[ -d "config/includes.chroot" ]]; then
        cp -r config/includes.chroot "$BUILD_DIR/config/"
    fi
    
    # Copy hooks
    if [[ -d "hooks" ]]; then
        mkdir -p "$BUILD_DIR/config/hooks/live"
        cp hooks/*.hook.chroot "$BUILD_DIR/config/hooks/live/" 2>/dev/null || true
    fi
    
    # Copy preseed file for installer
    if [[ -f "config/preseed.cfg" ]]; then
        mkdir -p "$BUILD_DIR/config/includes.installer"
        cp config/preseed.cfg "$BUILD_DIR/config/includes.installer/"
    fi
}

# Build the ISO
build_iso() {
    log_info "Building ISO image..."
    
    cd "$BUILD_DIR"
    
    # Build the live system
    sudo lb build
    
    if [[ $? -eq 0 ]]; then
        log_info "Build completed successfully"
        
        # Move the ISO to output directory
        if [[ -f "live-image-amd64.hybrid.iso" ]]; then
            mv live-image-amd64.hybrid.iso "../$OUTPUT_DIR/${DISTRO_NAME,,}-${DISTRO_VERSION}.iso"
            log_info "ISO created: $OUTPUT_DIR/${DISTRO_NAME,,}-${DISTRO_VERSION}.iso"
        else
            log_error "ISO file not found after build"
            exit 1
        fi
    else
        log_error "Build failed"
        exit 1
    fi
    
    cd ..
}

# Generate checksums
generate_checksums() {
    log_info "Generating checksums..."
    
    cd "$OUTPUT_DIR"
    
    for file in *.iso; do
        if [[ -f "$file" ]]; then
            sha256sum "$file" > "$file.sha256"
            md5sum "$file" > "$file.md5"
            log_info "Checksums generated for $file"
        fi
    done
    
    cd ..
}

# Show build summary
show_summary() {
    log_info "Build Summary:"
    echo "=============="
    echo "Distribution: $DISTRO_NAME $DISTRO_VERSION"
    echo "Architecture: amd64"
    echo "Base: Debian Bookworm"
    
    if [[ -f "$OUTPUT_DIR/${DISTRO_NAME,,}-${DISTRO_VERSION}.iso" ]]; then
        local iso_size=$(du -h "$OUTPUT_DIR/${DISTRO_NAME,,}-${DISTRO_VERSION}.iso" | cut -f1)
        echo "ISO Size: $iso_size"
        echo "ISO Location: $OUTPUT_DIR/${DISTRO_NAME,,}-${DISTRO_VERSION}.iso"
    fi
    
    echo ""
    log_info "Next steps:"
    echo "  1. Test the ISO: ./scripts/test-vm.sh"
    echo "  2. Create bootable USB: dd if=$OUTPUT_DIR/${DISTRO_NAME,,}-${DISTRO_VERSION}.iso of=/dev/sdX bs=4M"
    echo "  3. Boot and test on real hardware"
}

# Main execution
main() {
    log_info "Starting $DISTRO_NAME build process..."
    
    check_root
    check_dependencies
    clean_build
    setup_config
    copy_configs
    build_iso
    generate_checksums
    show_summary
    
    log_info "Build process completed successfully!"
}

# Execute main function
main "$@"
