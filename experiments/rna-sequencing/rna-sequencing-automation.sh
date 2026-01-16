#!/bin/bash

# RNA Sequencing Automation Script
# This script automates the workflow described at https://build.nvidia.com/spark/single-cell

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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: Verify Environment
verify_environment() {
    log "Step 1: Verifying environment..."
    
    # Check for nvidia-smi
    if ! command_exists nvidia-smi; then
        error "nvidia-smi not found. GPU is not properly configured."
    fi
    
    # Check for git
    if ! command_exists git; then
        error "git not found. Please install git."
    fi
    
    # Check for docker
    if ! command_exists docker; then
        error "docker not found. Please install Docker."
    fi
    
    # Run checks
    log "Checking nvidia-smi..."
    nvidia-smi --query-gpu=name --format=csv,noheader,nounits | head -1 > /dev/null || error "nvidia-smi failed"
    
    log "Checking git version..."
    git --version
    
    log "Checking docker version..."
    docker --version
    
    log "Environment verification completed successfully."
}

# Step 2: Installation
install_playbook() {
    log "Step 2: Installing playbook..."
    
    # Clone the repository if it doesn't exist
    if [ ! -d "dgx-spark-playbooks" ]; then
        log "Cloning dgx-spark-playbooks repository..."
        git clone https://github.com/NVIDIA/dgx-spark-playbooks || error "Failed to clone dgx-spark-playbooks"
    else
        log "dgx-spark-playbooks already exists, pulling latest changes..."
        cd dgx-spark-playbooks
        git pull origin main || warn "Failed to pull latest changes"
        cd ..
    fi
    
    # Navigate to the assets directory
    if [ ! -d "dgx-spark-playbooks/nvidia/single-cell/assets" ]; then
        error "Assets directory not found in dgx-spark-playbooks"
    fi
    
    cd dgx-spark-playbooks/nvidia/single-cell/assets
    
    # Run the setup script
    if [ ! -f "setup/start_playbook.sh" ]; then
        error "setup/start_playbook.sh not found"
    fi
    
    log "Running start_playbook.sh to set up the environment..."
    ./setup/start_playbook.sh
    
    log "Installation completed."
}

# Step 3: Run the notebook (simulated - in practice this would involve JupyterLab)
run_notebook() {
    log "Step 3: Running the notebook..."
    log "Notebook execution is simulated. In practice, you would open JupyterLab and run scRNA_analysis_preprocessing.ipynb"
    log "You can access JupyterLab at http://127.0.0.1:8888"
    log "Use Shift + Enter to manually run each cell, or Run > Run All to run all cells."
}

# Step 4: Download work (simulated)
download_work() {
    log "Step 4: Downloading work..."
    log "In practice, download files from JupyterLab by right-clicking and selecting Download"
    log "This step is simulated in the automation script."
}

# Step 5: Cleanup
cleanup() {
    log "Step 5: Cleaning up..."
    log "To clean up, press Ctrl+C in the terminal where start_playbook.sh is running"
    log "Then confirm shutdown when prompted"
    log "WARNING: This will delete ALL data that wasn't downloaded from the Docker container"
}

# Main execution function
main() {
    log "Starting RNA Sequencing Automation Workflow"
    log "============================================"
    
    # Verify environment first
    verify_environment
    
    # Install playbook
    install_playbook
    
    # Run notebook
    run_notebook
    
    # Download work
    download_work
    
    # Cleanup
    cleanup
    
    log "RNA Sequencing Automation Workflow completed."
}

# Parse command line arguments
case "${1:-}" in
    --verify)
        verify_environment
        ;;
    --install)
        install_playbook
        ;;
    --run)
        run_notebook
        ;;
    --download)
        download_work
        ;;
    --cleanup)
        cleanup
        ;;
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --verify     Verify environment (nvidia-smi, git, docker)"
        echo "  --install    Install playbook"
        echo "  --run        Run the notebook (simulated)"
        echo "  --download   Download work (simulated)"
        echo "  --cleanup    Cleanup"
        echo "  --help, -h   Show this help message"
        echo ""
        echo "If no options are provided, the full workflow will be executed."
        ;;
    *)
        # Run full workflow
        main
        ;;
esac