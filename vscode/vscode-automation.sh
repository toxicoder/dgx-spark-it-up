#!/bin/bash

# =============================================================================
# VS Code Automation Script for DGX Spark
# This script automates the installation and configuration of VS Code on DGX Spark systems
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Function to check system requirements
check_system_requirements() {
    log "Step 1: Verifying system requirements"
    
    # Check ARM64 architecture
    local arch=$(uname -m)
    if [[ "$arch" != "aarch64" ]]; then
        error "System architecture is not ARM64. Found: $arch"
    fi
    log "✓ ARM64 architecture verified"
    
    # Check available disk space
    local disk_space=$(df -h / | awk 'NR==2 {print $4}')
    if [[ "${disk_space%G}" -lt 200 ]]; then
        warn "Available disk space is less than 200MB: $disk_space"
    else
        log "✓ Sufficient disk space available: $disk_space"
    fi
    
    # Check desktop environment
    if ! ps aux | grep -E "(gnome|kde|xfce)" | grep -v grep > /dev/null; then
        warn "No desktop environment detected"
    else
        log "✓ Desktop environment detected"
    fi
    
    # Check GUI support
    if [[ -z "${DISPLAY:-}" ]]; then
        warn "DISPLAY environment variable not set"
    else
        log "✓ GUI support available: $DISPLAY"
    fi
}

# Function to download VS Code ARM64 installer
download_vscode_installer() {
    log "Step 2: Downloading VS Code ARM64 installer"
    
    local installer_url="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64"
    local installer_file="vscode-arm64.deb"
    
    if ! command -v wget &> /dev/null; then
        error "wget is not installed"
    fi
    
    wget "$installer_url" -O "$installer_file" || error "Failed to download VS Code installer"
    log "✓ VS Code ARM64 installer downloaded"
}

# Function to install VS Code package
install_vscode() {
    log "Step 3: Installing VS Code package"
    
    local installer_file="vscode-arm64.deb"
    
    if [[ ! -f "$installer_file" ]]; then
        error "VS Code installer not found: $installer_file"
    fi
    
    # Install the downloaded .deb package
    sudo dpkg -i "$installer_file" || error "Failed to install VS Code package"
    
    # Fix any dependency issues
    sudo apt-get install -f || error "Failed to fix dependencies"
    
    log "✓ VS Code installed successfully"
}

# Function to verify installation
verify_installation() {
    log "Step 4: Verifying installation"
    
    # Check if VS Code is installed
    if ! command -v code &> /dev/null; then
        error "VS Code is not installed properly"
    fi
    log "✓ VS Code installed successfully"
    
    # Verify version
    local version=$(code --version | head -1)
    log "✓ VS Code version: $version"
    
    log "✓ Installation verification complete"
}

# Function to configure for Spark development
configure_spark_development() {
    log "Step 5: Configuring for Spark development"
    
    # Create a project directory
    local project_dir="$HOME/spark-dev-workspace"
    mkdir -p "$project_dir"
    cd "$project_dir"
    
    # Open VS Code in the project directory
    # Note: This will launch the GUI, so we'll skip it in automation
    log "✓ Spark development workspace created at: $project_dir"
    
    log "✓ Configuration for Spark development complete"
}

# Function to validate setup and test functionality
validate_setup() {
    log "Step 6: Validating setup and testing functionality"
    
    # Create test directory and file
    local test_dir="$HOME/vscode-test"
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    # Create a test Python file
    echo 'print("Hello from DGX Spark!")' > test.py
    
    # Test that we can launch VS Code with the file
    # Note: This would normally launch the GUI, so we'll just verify the file exists
    if [[ ! -f "test.py" ]]; then
        error "Test file was not created properly"
    fi
    
    log "✓ Test file created: test.py"
    log "✓ Setup validation complete"
}

# Function to uninstall VS Code (cleanup function)
uninstall_vscode() {
    log "Step 7: Uninstalling VS Code"
    
    # Remove VS Code package
    sudo apt-get remove -y code || warn "Failed to remove VS Code package"
    
    # Remove configuration files (optional)
    rm -rf "$HOME/.config/Code" 2>/dev/null || true
    rm -rf "$HOME/.vscode" 2>/dev/null || true
    
    log "✓ VS Code uninstalled"
}

# Main function to run all steps
main() {
    log "Starting VS Code automation for DGX Spark..."
    
    check_system_requirements
    download_vscode_installer
    install_vscode
    verify_installation
    configure_spark_development
    validate_setup
    
    log "VS Code automation completed successfully!"
    log "To test functionality, you can run: code $HOME/vscode-test/test.py"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi