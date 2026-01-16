#!/bin/bash

# Flux Finetuning Automation Script
# This script automates the entire flux-finetuning process from the NVIDIA guide

set -e  # Exit on any error

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

# Check if running on Linux
check_os() {
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        error "This automation script is designed for Linux systems only."
    fi
}

# Check Docker permissions
check_docker_permissions() {
    log "Checking Docker permissions..."
    if ! docker ps >/dev/null 2>&1; then
        warn "Docker requires sudo permissions. Adding user to docker group..."
        sudo usermod -aG docker $USER
        # Note: newgrp docker needs to be run in a new shell
        echo "Please run 'newgrp docker' or re-login for docker permissions to take effect"
        echo "After that, run this script again"
        exit 1
    fi
    log "Docker permissions are properly configured"
}

# Clone the repository (if not already done)
clone_repository() {
    if [[ ! -d "dgx-spark-playbooks" ]]; then
        log "Cloning dgx-spark-playbooks repository..."
        git clone https://github.com/NVIDIA/dgx-spark-playbooks
    else
        log "Repository already exists"
    fi
}

# Setup directories
setup_directories() {
    log "Setting up directories..."
    mkdir -p flux-finetuning/assets/models/loras
    mkdir -p flux-finetuning/assets/flux_data
    mkdir -p flux-finetuning/assets/models/checkpoints
    mkdir -p flux-finetuning/assets/models/text_encoders
    mkdir -p flux-finetuning/assets/models/vae
}

# Check for HF_TOKEN
check_hf_token() {
    if [[ -z "$HF_TOKEN" ]]; then
        error "HF_TOKEN environment variable is not set. Please set it before running this script."
    fi
}

# Download model
download_model() {
    log "Downloading FLUX.1-dev model..."
    cd flux-finetuning/assets
    if [[ ! -f "models/loras/.gitkeep" ]]; then
        export HF_TOKEN=$HF_TOKEN
        sh download.sh
    else
        log "Model already downloaded"
    fi
    cd - > /dev/null
}

# Build inference docker image
build_inference_image() {
    log "Building inference Docker image..."
    cd flux-finetuning/assets
    docker build -f Dockerfile.inference -t flux-comfyui .
    cd - > /dev/null
}

# Build training docker image
build_training_image() {
    log "Building training Docker image..."
    cd flux-finetuning/assets
    docker build -f Dockerfile.train -t flux-train .
    cd - > /dev/null
}

# Launch ComfyUI
launch_comfyui() {
    log "Launching ComfyUI container..."
    cd flux-finetuning/assets
    sh launch_comfyui.sh
    cd - > /dev/null
}

# Launch training
launch_training() {
    log "Launching training..."
    cd flux-finetuning/assets
    sh launch_train.sh
    cd - > /dev/null
}

# Prepare dataset
prepare_dataset() {
    log "Preparing dataset..."
    # Create default dataset directories if they don't exist
    if [[ ! -d "flux-finetuning/assets/flux_data/sparkgpu" ]]; then
        mkdir -p flux-finetuning/assets/flux_data/sparkgpu
    fi
    if [[ ! -d "flux-finetuning/assets/flux_data/tjtoy" ]]; then
        mkdir -p flux-finetuning/assets/flux_data/tjtoy
    fi
    
    # Update data.toml if it exists
    if [[ -f "flux-finetuning/assets/flux_data/data.toml" ]]; then
        log "Updating data.toml with dataset configuration..."
        # The data.toml already has the default configuration for our concepts
        # We can optionally validate or update it here if needed
    fi
}

# Main execution function
main() {
    log "Starting Flux Finetuning Automation Process"
    
    # Check prerequisites
    check_os
    check_docker_permissions
    
    # Setup
    setup_directories
    clone_repository
    check_hf_token
    
    # Download model
    download_model
    
    # Prepare dataset
    prepare_dataset
    
    # Build images
    build_inference_image
    build_training_image
    
    log "Automation process completed successfully"
    log "You can now run training with: sh flux-finetuning/assets/launch_train.sh"
    log "And run inference with: sh flux-finetuning/assets/launch_comfyui.sh"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi