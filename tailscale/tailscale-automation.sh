#!/bin/bash

# =============================================================================
# Tailscale Automation Script for NVIDIA DGX Spark
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Success function
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Warning function
warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Error function
error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root"
        exit 1
    fi
}

# Verifying system requirements
verify_requirements() {
    log "Verifying system requirements..."
    
    # Check Ubuntu version (should be 20.04 or newer)
    if ! command -v lsb_release &> /dev/null; then
        error "lsb_release not found. Cannot verify Ubuntu version."
        exit 1
    fi
    
    UBUNTU_VERSION=$(lsb_release -rs)
    log "Ubuntu version: $UBUNTU_VERSION"
    
    # Check if version is 20.04 or newer
    if [[ $(echo "$UBUNTU_VERSION >= 20.04" | bc -l) -eq 1 ]]; then
        success "Ubuntu version is supported"
    else
        warning "Ubuntu version $UBUNTU_VERSION is older than 20.04. Some features may not work as expected."
    fi
    
    # Test internet connectivity
    log "Testing internet connectivity..."
    if ping -c 3 google.com &> /dev/null; then
        success "Internet connectivity verified"
    else
        error "No internet connectivity detected"
        exit 1
    fi
    
    # Verify sudo access
    if sudo -v &> /dev/null; then
        success "Sudo access verified"
    else
        error "No sudo access available"
        exit 1
    fi
    
    success "System requirements verified"
}

# Installing SSH server
install_ssh() {
    log "Installing SSH server if needed..."
    
    # Check if SSH is running
    if systemctl is-active --quiet ssh; then
        success "SSH server is already running"
        return
    fi
    
    log "SSH server not found or not running, installing..."
    
    # Install OpenSSH server
    sudo apt update
    sudo apt install -y openssh-server
    
    # Enable and start SSH service
    sudo systemctl enable ssh --now --no-pager
    
    # Verify SSH is running
    if systemctl is-active --quiet ssh; then
        success "SSH server installed and running"
    else
        error "Failed to start SSH server"
        exit 1
    fi
}

# Installing Tailscale
install_tailscale() {
    log "Installing Tailscale on NVIDIA DGX Spark..."
    
    # Update package list
    sudo apt update
    
    # Install required tools for adding external repositories
    sudo apt install -y curl gnupg
    
    # Add Tailscale signing key
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | \
      sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
    
    # Add Tailscale repository
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | \
      sudo tee /etc/apt/sources.list.d/tailscale.list
    
    # Update package list with new repository
    sudo apt update
    
    # Install Tailscale
    sudo apt install -y tailscale
    
    success "Tailscale installed successfully"
}

# Verifying Tailscale installation
verify_tailscale() {
    log "Verifying Tailscale installation..."
    
    # Check Tailscale version
    if tailscale version &> /dev/null; then
        TAILSCALE_VERSION=$(tailscale version | head -1)
        log "Tailscale version: $TAILSCALE_VERSION"
    else
        error "Failed to get Tailscale version"
        exit 1
    fi
    
    # Check Tailscale service status
    if sudo systemctl is-active --quiet tailscaled; then
        success "Tailscale service is running"
    else
        error "Tailscale service is not running"
        exit 1
    fi
    
    success "Tailscale installation verified"
}

# Connecting DGX Spark to Tailscale network
connect_tailscale() {
    log "Connecting DGX Spark to Tailscale network..."
    
    log "Starting Tailscale and beginning authentication..."
    sudo tailscale up
    
    log "Please follow the URL displayed in the output to complete login in your browser."
    log "Choose from: Google, GitHub, Microsoft, or other supported providers"
    log "Press any key to continue once authentication is complete..."
    read -r _
}

# Instructions for installing Tailscale on client devices
client_installation() {
    log "Instructions for installing Tailscale on client devices..."
    
    cat << 'EOF'
For client devices, install Tailscale using one of these methods:

On macOS:
Option 1: Install from Mac App Store by searching for "Tailscale" and then clicking Get → Install
Option 2: Download the .pkg installer from the Tailscale website

On Windows:
Download installer from the Tailscale website
Run the .msi file and follow installation prompts
Launch Tailscale from Start Menu or system tray

On Linux:
# Update package list
sudo apt update

# Install required tools for adding external repositories
sudo apt install -y curl gnupg

# Add Tailscale signing key
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | \
  sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null

# Add Tailscale repository
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | \
  sudo tee /etc/apt/sources.list.d/tailscale.list

# Update package list with new repository
sudo apt update

# Install Tailscale
sudo apt install -y tailscale

EOF
    
    success "Client installation instructions provided"
}

# Instructions for connecting client devices to tailnet
client_connect() {
    log "Instructions for connecting client devices to tailnet..."
    
    cat << 'EOF'
To connect client devices to the tailnet:
On macOS/Windows (GUI):
Launch Tailscale app
Click "Log in" button
Sign in with same account used on DGX Spark

On Linux (CLI):
# Start Tailscale on client
sudo tailscale up

# Complete authentication in browser using same account
EOF
    
    success "Client connection instructions provided"
}

# Verifying network connectivity
verify_connectivity() {
    log "Verifying network connectivity..."
    
    cat << 'EOF'
To verify network connectivity:
# On any device, check tailnet status
tailscale status

# Test ping to Spark device (use hostname or IP from status output)
tailscale ping <SPARK_HOSTNAME>

# Example output should show successful pings
EOF
    
    success "Network connectivity verification instructions provided"
}

# Configuring SSH authentication
configure_ssh() {
    log "Configuring SSH authentication..."
    
    # Check if SSH keys exist
    if [[ -f ~/.ssh/tailscale_spark ]]; then
        log "SSH key ~/.ssh/tailscale_spark already exists"
    else
        log "Generating new SSH key pair..."
        ssh-keygen -t ed25519 -f ~/.ssh/tailscale_spark -N ""
        success "SSH key generated"
    fi
    
    # Display public key
    if [[ -f ~/.ssh/tailscale_spark.pub ]]; then
        log "Public key (copy this to add to Spark device):"
        cat ~/.ssh/tailscale_spark.pub
    else
        error "Public key file not found"
        exit 1
    fi
    
    success "SSH configuration instructions provided"
    log "Please add the public key above to your DGX Spark device's ~/.ssh/authorized_keys file"
}

# Testing SSH connection
test_ssh() {
    log "Testing SSH connection..."
    
    cat << 'EOF'
To test SSH connection:
# Connect using Tailscale hostname (preferred)
ssh -i ~/.ssh/tailscale_spark <USERNAME>@<SPARK_HOSTNAME>

# Or connect using Tailscale IP address
ssh -i ~/.ssh/tailscale_spark <USERNAME>@<TAILSCALE_IP>

# Example:
# ssh -i ~/.ssh/tailscale_spark nvidia@my-spark-device
EOF
    
    success "SSH connection test instructions provided"
}

# Validating installation
validate_installation() {
    log "Validating installation..."
    
    cat << 'EOF'
To validate the installation:
# From client device, check connection status
tailscale status

# Create a test file on the client device
echo "test file for the spark" > test.txt

# Test file transfer over SSH
scp -i ~/.ssh/tailscale_spark test.txt <USERNAME>@<SPARK_HOSTNAME>:~/

# Verify you can run commands remotely
ssh -i ~/.ssh/tailscale_spark <USERNAME>@<SPARK_HOSTNAME> 'nvidia-smi'
EOF
    
    success "Installation validation instructions provided"
}

# Cleanup and rollback
cleanup() {
    log "Cleanup and rollback instructions..."
    
    cat << 'EOF'
To remove Tailscale completely:
# Stop Tailscale service
sudo tailscale down

# Remove Tailscale package
sudo apt remove --purge tailscale

# Remove repository and keys (optional)
sudo rm /etc/apt/sources.list.d/tailscale.list
sudo rm /usr/share/keyrings/tailscale-archive-keyring.gpg

# Update package list
sudo apt update

To restore: Re-run installation steps 3-5.
EOF
    
    success "Cleanup instructions provided"
}

# Next steps
next_steps() {
    log "Next steps..."
    
    cat << 'EOF'
Your Tailscale setup is complete. You can now:
Access your DGX Spark device from any network with: ssh <USERNAME>@<SPARK_HOSTNAME>
Transfer files securely: scp file.txt <USERNAME>@<SPARK_HOSTNAME>:~/
Open the DGX Dashboard and start JupyterLab, then connect with: ssh -L 8888:localhost:1102 <USERNAME>@<SPARK_HOSTNAME>
EOF
    
    success "Next steps provided"
}

# Main function
main() {
    echo "==========================================="
    echo "  NVIDIA DGX Spark Tailscale Automation"
    echo "==========================================="
    
    check_root
    
    verify_requirements
    install_ssh
    install_tailscale
    verify_tailscale
    connect_tailscale
    client_installation
    client_connect
    verify_connectivity
    configure_ssh
    test_ssh
    validate_installation
    cleanup
    next_steps
    
    success "Tailscale setup automation completed!"
    echo "Please review the instructions and follow the steps as needed."
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi