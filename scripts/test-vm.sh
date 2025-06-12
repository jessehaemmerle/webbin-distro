#!/bin/bash

# VM Testing Script for Custom Debian Distribution
# Tests the built ISO in QEMU virtual machine

set -e

# Configuration
ISO_PATH="output"
ISO_NAME=""
VM_NAME="Webbin-Test"
VM_MEMORY="2048"
VM_DISK_SIZE="20G"
VM_CPUS="2"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check dependencies
check_dependencies() {
    log_info "Checking VM testing dependencies..."
    
    local deps=("qemu-system-x86-64" "qemu-utils")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "${dep}" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Install them with: sudo apt install qemu-system-x86 qemu-utils"
        exit 1
    fi
}

# Find the ISO file
find_iso() {
    log_info "Looking for ISO file..."
    
    # Find the most recent ISO file
    ISO_FILE=$(find "$ISO_PATH" -name "*.iso" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)
    
    if [[ -z "$ISO_FILE" ]]; then
        log_error "No ISO file found in $ISO_PATH"
        log_info "Run ./scripts/build.sh first to create an ISO"
        exit 1
    fi
    
    log_info "Found ISO: $ISO_FILE"
}

# Create VM disk
create_vm_disk() {
    log_info "Creating VM disk image..."
    
    local disk_path="/tmp/${VM_NAME}.qcow2"
    
    if [[ -f "$disk_path" ]]; then
        log_warn "Removing existing disk image"
        rm "$disk_path"
    fi
    
    qemu-img create -f qcow2 "$disk_path" "$VM_DISK_SIZE"
    echo "$disk_path"
}

# Test UEFI boot
test_uefi_boot() {
    log_info "Testing UEFI boot..."
    
    local disk_path=$(create_vm_disk)
    
    log_info "Starting QEMU with UEFI firmware..."
    log_info "VM Configuration:"
    echo "  Memory: ${VM_MEMORY}MB"
    echo "  CPUs: $VM_CPUS"
    echo "  Disk: $VM_DISK_SIZE"
    echo "  Boot: UEFI"
    echo ""
    log_info "QEMU will start shortly. Test the live system and installer."
    log_info "Press Ctrl+Alt+G to release mouse, Ctrl+Alt+F to toggle fullscreen"
    echo ""
    
    # Check if OVMF is available
    OVMF_PATH=""
    if [[ -f "/usr/share/OVMF/OVMF_CODE.fd" ]]; then
        OVMF_PATH="/usr/share/OVMF/OVMF_CODE.fd"
    elif [[ -f "/usr/share/ovmf/OVMF.fd" ]]; then
        OVMF_PATH="/usr/share/ovmf/OVMF.fd"
    else
        log_warn "OVMF firmware not found, testing with BIOS instead"
        test_bios_boot
        return
    fi
    
    qemu-system-x86_64 \
        -name "$VM_NAME" \
        -machine type=pc,accel=kvm \
        -cpu host \
        -smp "$VM_CPUS" \
        -m "$VM_MEMORY" \
        -drive if=pflash,format=raw,readonly=on,file="$OVMF_PATH" \
        -drive file="$disk_path",format=qcow2,if=virtio \
        -cdrom "$ISO_FILE" \
        -boot order=d \
        -netdev user,id=net0 \
        -device virtio-net,netdev=net0 \
        -vga virtio \
        -display gtk,gl=on \
        -usb \
        -device usb-tablet
    
    # Cleanup
    rm -f "$disk_path"
}

# Test BIOS boot
test_bios_boot() {
    log_info "Testing BIOS boot..."
    
    local disk_path=$(create_vm_disk)
    
    log_info "Starting QEMU with BIOS firmware..."
    
    qemu-system-x86_64 \
        -name "$VM_NAME" \
        -machine type=pc,accel=kvm \
        -cpu host \
        -smp "$VM_CPUS" \
        -m "$VM_MEMORY" \
        -drive file="$disk_path",format=qcow2,if=virtio \
        -cdrom "$ISO_FILE" \
        -boot order=d \
        -netdev user,id=net0 \
        -device virtio-net,netdev=net0 \
        -vga virtio \
        -display gtk \
        -usb \
        -device usb-tablet
    
    # Cleanup
    rm -f "$disk_path"
}

# Show testing menu
show_menu() {
    echo ""
    log_info "VM Testing Options:"
    echo "1) Test UEFI boot"
    echo "2) Test BIOS boot"
    echo "3) Exit"
    echo ""
    read -p "Select option (1-3): " choice
    
    case $choice in
        1) test_uefi_boot ;;
        2) test_bios_boot ;;
        3) log_info "Exiting..."; exit 0 ;;
        *) log_error "Invalid option"; show_menu ;;
    esac
}

# Main execution
main() {
    log_info "VM Testing for Custom Debian Distribution"
    
    check_dependencies
    find_iso
    
    # Check if KVM is available
    if [[ -w /dev/kvm ]]; then
        log_info "KVM acceleration available"
    else
        log_warn "KVM not available, using software emulation (slower)"
    fi
    
    show_menu
}

main "$@"
