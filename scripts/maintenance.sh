#!/bin/bash

# Maintenance Script for Custom Debian Distribution
# Provides utilities for maintaining the distribution project

set -e

# Configuration
PROJECT_NAME="WebbinOS"
VERSION="1.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Clean build artifacts
clean_all() {
    log_header "Cleaning Build Artifacts"
    
    if [[ -d "build" ]]; then
        log_info "Removing build directory..."
        sudo rm -rf build/
    fi
    
    if [[ -d "output" ]]; then
        log_info "Removing output directory..."
        rm -rf output/
    fi
    
    log_info "Cleanup completed"
}

# Update package lists
update_packages() {
    log_header "Updating Package Information"
    
    log_info "Checking for package updates..."
    
    # This would check for newer package versions
    # For now, just show current Debian release info
    echo "Current base: Debian $(lsb_release -cs 2>/dev/null || echo 'bookworm')"
    echo "Package lists last updated: $(find config/package-lists -name "*.list.chroot" -printf '%TY-%Tm-%Td %TH:%TM\n' | head -1)"
    
    log_info "To update packages, edit files in config/package-lists/"
}

# Validate configuration
validate_config() {
    log_header "Validating Configuration"
    
    local errors=0
    
    # Check required directories
    local required_dirs=("config" "scripts" "hooks" "docs")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_error "Missing required directory: $dir"
            ((errors++))
        else
            log_info "✓ Directory found: $dir"
        fi
    done
    
    # Check required files
    local required_files=("scripts/build.sh" "scripts/test-vm.sh" "DESIGN.md" "README.md")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Missing required file: $file"
            ((errors++))
        else
            log_info "✓ File found: $file"
        fi
    done
    
    # Check package lists
    if [[ -d "config/package-lists" ]]; then
        local package_files=$(find config/package-lists -name "*.list.chroot" | wc -l)
        if [[ $package_files -gt 0 ]]; then
            log_info "✓ Found $package_files package list(s)"
        else
            log_warn "No package lists found in config/package-lists/"
        fi
    fi
    
    # Check script permissions
    for script in scripts/*.sh; do
        if [[ -f "$script" && -x "$script" ]]; then
            log_info "✓ Script executable: $script"
        elif [[ -f "$script" ]]; then
            log_warn "Script not executable: $script"
            chmod +x "$script"
            log_info "✓ Fixed permissions: $script"
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        log_info "Configuration validation passed"
        return 0
    else
        log_error "Configuration validation failed with $errors error(s)"
        return 1
    fi
}

# Show project statistics
show_stats() {
    log_header "Project Statistics"
    
    echo "Project: $PROJECT_NAME v$VERSION"
    echo "Base: Debian Bookworm"
    echo "Architecture: x86-64"
    echo ""
    
    # File counts
    echo "Files:"
    echo "  Scripts: $(find scripts -name "*.sh" | wc -l)"
    echo "  Package lists: $(find config/package-lists -name "*.list.chroot" 2>/dev/null | wc -l)"
    echo "  Hooks: $(find hooks -name "*.hook.chroot" 2>/dev/null | wc -l)"
    echo "  Documentation: $(find docs -name "*.md" 2>/dev/null | wc -l)"
    echo ""
    
    # Package counts
    if [[ -d "config/package-lists" ]]; then
        local total_packages=0
        for list in config/package-lists/*.list.chroot; do
            if [[ -f "$list" ]]; then
                local count=$(grep -v '^#' "$list" | grep -v '^$' | wc -l)
                total_packages=$((total_packages + count))
                echo "  $(basename "$list"): $count packages"
            fi
        done
        echo "  Total packages: $total_packages"
    fi
    
    echo ""
    
    # Git information
    if [[ -d ".git" ]]; then
        echo "Git:"
        echo "  Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
        echo "  Commits: $(git rev-list --count HEAD 2>/dev/null || echo 'unknown')"
        echo "  Last commit: $(git log -1 --format='%cr' 2>/dev/null || echo 'unknown')"
    fi
}

# Check dependencies
check_deps() {
    log_header "Checking Dependencies"
    
    local deps=("live-build" "debootstrap" "squashfs-tools" "xorriso" "isolinux" "syslinux-efi")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if dpkg -l | grep -q "^ii  $dep "; then
            log_info "✓ $dep installed"
        else
            log_warn "✗ $dep missing"
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_info "Install missing dependencies:"
        echo "sudo apt install ${missing[*]}"
        return 1
    else
        log_info "All dependencies satisfied"
        return 0
    fi
}

# Show help
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Maintenance script for $PROJECT_NAME"
    echo ""
    echo "Commands:"
    echo "  clean      Clean build artifacts and temporary files"
    echo "  validate   Validate project configuration"
    echo "  stats      Show project statistics"
    echo "  deps       Check build dependencies"
    echo "  update     Check for package updates"
    echo "  help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 clean           # Clean build files"
    echo "  $0 validate        # Check configuration"
    echo "  $0 deps           # Check dependencies"
}

# Main function
main() {
    case "${1:-help}" in
        "clean")
            clean_all
            ;;
        "validate")
            validate_config
            ;;
        "stats")
            show_stats
            ;;
        "deps")
            check_deps
            ;;
        "update")
            update_packages
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            log_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
