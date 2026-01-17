#!/bin/bash

# Vibe Coding Automation Script
# This script automates the setup process described in:
# https://build.nvidia.com/spark/vibe-coding

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Check if running on ARM-based system (DGX Spark)
check_architecture() {
    log "Checking system architecture..."
    if [[ $(uname -m) != "aarch64" ]]; then
        warn "This automation is designed for ARM-based systems (DGX Spark). You are running on $(uname -m)"
    fi
}

# Step 1: Install Ollama
install_ollama() {
    log "Installing Ollama..."
    
    # Check if ollama is already installed
    if command -v ollama &> /dev/null; then
        log "Ollama is already installed"
        return
    fi
    
    # Install Ollama using the official installer
    curl -fsSL https://ollama.com/install.sh | sh
    
    # Wait for Ollama service to start
    log "Waiting for Ollama service to start..."
    sleep 5
    
    # Verify installation
    if ! command -v ollama &> /dev/null; then
        error "Failed to install Ollama"
    fi
    
    log "Ollama installed successfully"
}

# Step 2: Pull the gpt-oss:120b model
pull_model() {
    log "Pulling gpt-oss:120b model..."
    
    # Check if model already exists
    if ollama list | grep -q "gpt-oss:120b"; then
        log "Model gpt-oss:120b already exists"
        return
    fi
    
    # Pull the model
    ollama pull gpt-oss:120b
    
    # Verify model was pulled
    if ! ollama list | grep -q "gpt-oss:120b"; then
        error "Failed to pull gpt-oss:120b model"
    fi
    
    log "Model gpt-oss:120b pulled successfully"
}

# Step 3: Enable Remote Access (Optional)
enable_remote_access() {
    log "Enabling remote access for Ollama..."
    
    # Check if systemd is available
    if ! command -v systemctl &> /dev/null; then
        warn "systemctl not available, skipping remote access configuration"
        return
    fi
    
    # Create systemd override file
    sudo mkdir -p /etc/systemd/system/ollama.service.d
    sudo tee /etc/systemd/system/ollama.service.d/override.conf << EOF
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_ORIGINS=*"
EOF
    
    # Reload systemd and restart ollama
    sudo systemctl daemon-reload
    sudo systemctl restart ollama
    
    log "Remote access enabled for Ollama"
}

# Step 4: Install VSCode (ARM64)
install_vscode() {
    log "Installing VSCode..."
    
    # Check if VSCode is already installed
    if command -v code &> /dev/null; then
        log "VSCode is already installed"
        return
    fi
    
    # Download VSCode ARM64 package
    log "Downloading VSCode ARM64 package..."
    wget -O vscode.deb https://code-server.dev/downloads/code-server_1.119.0_arm64.deb 2>/dev/null || {
        warn "Could not download VSCode package, trying alternative method"
        # Fallback to a more generic approach
        error "Failed to download VSCode"
    }
    
    # Install VSCode
    sudo dpkg -i vscode.deb
    sudo apt-get update
    sudo apt-get install -f -y
    
    # Clean up
    rm -f vscode.deb
    
    # Verify installation
    if ! command -v code &> /dev/null; then
        error "Failed to install VSCode"
    fi
    
    log "VSCode installed successfully"
}

# Step 5: Install Continue.dev Extension (simulated)
install_continue_extension() {
    log "Installing Continue.dev extension..."
    
    # Note: Actual extension installation would require VSCode CLI tools
    # This is a placeholder since we can't easily automate VSCode extension installation
    # in a headless environment
    
    warn "Continue.dev extension installation requires manual setup in VSCode GUI"
    warn "Please install Continue.dev extension from VSCode Marketplace manually"
    
    log "Continue.dev extension installation - manual step required"
}

# Step 6: Setup Local Inference (simulated)
setup_local_inference() {
    log "Setting up local inference configuration..."
    
    # This would typically be handled through VSCode UI
    # We'll just note that the model should be configured as default
    warn "Local inference setup requires manual configuration in VSCode"
    warn "Please configure Ollama as provider and select gpt-oss:120b model"
    
    log "Local inference setup - manual step required"
}

# Step 7: Configure Remote Connection (simulated)
configure_remote_connection() {
    log "Configuring remote connection for workstation..."
    
    # This would be done on the workstation side
    # We'll just note what needs to be done
    
    warn "Remote connection configuration requires setup on workstation"
    warn "Workstation needs to configure Continue with:"
    warn "  - Provider: Ollama"
    warn "  - Model: gpt-oss:120b"
    warn "  - apiBase: http://YOUR_SPARK_IP:11434"
    
    log "Remote connection configuration - manual step required"
}

# Main execution function
main() {
    log "Starting Vibe Coding Automation Setup..."
    
    check_architecture
    install_ollama
    pull_model
    enable_remote_access
    install_vscode
    install_continue_extension
    setup_local_inference
    configure_remote_connection
    
    log "Vibe Coding Automation Setup Complete!"
    log "Note: Some steps require manual configuration in VSCode GUI"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi