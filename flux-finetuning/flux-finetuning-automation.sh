#!/bin/bash

# Flux Finetuning Automation Script.
#
# This script automates the entire flux-finetuning process from the NVIDIA guide, including environment setup, model downloading, Docker image building, and container launching.

set -e  # Exit on any error

# Colors for output
# RED color code for error messages
RED='\033[0;31m'
# GREEN color code for info messages
GREEN='\033[0;32m'
# YELLOW color code for warning messages
YELLOW='\033[1;33m'
# NC color code for no color (reset)
NC='\033[0m' # No Color

# Logging function.
#
# Print an info message with green color prefix.
#
# Arguments:
#   $1 - Message to log.
#
# Returns:
#   0 - Success.
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Warning function.
#
# Print a warning message with yellow color prefix.
#
# Arguments:
#   $1 - Warning message to log.
#
# Returns:
#   0 - Success.
warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Error function.
#
# Print an error message with red color prefix and exit.
#
# Arguments:
#   $1 - Error message to log.
#
# Returns:
#   1 - Error occurred and script exits.
error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if running on Linux.
#
# Verify that the script is running on a Linux system.
#
# Returns:
#   0 - Running on Linux.
#   1 - Not running on Linux.
#
# Errors:
#   This automation script is designed for Linux systems only: Non-Linux OS detected.
check_os() {
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        error "This automation script is designed for Linux systems only."
    fi
}

# Check Docker permissions.
#
# Verify that Docker is properly configured with user permissions.
#
# Returns:
#   0 - Docker permissions are properly configured.
#   1 - Docker permissions need to be configured.
#
# Errors:
#   Docker requires sudo permissions: User needs to be added to docker group.
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

# Clone the repository (if not already done).
#
# Clone the dgx-spark-playbooks repository from GitHub if it doesn't exist locally.
#
# Returns:
#   0 - Repository cloned or already exists.
clone_repository() {
    if [[ ! -d "dgx-spark-playbooks" ]]; then
        log "Cloning dgx-spark-playbooks repository..."
        git clone https://github.com/NVIDIA/dgx-spark-playbooks
    else
        log "Repository already exists"
    fi
}

# Setup directories.
#
# Create necessary directory structure for flux-finetuning assets.
#
# Returns:
#   0 - Directories created successfully.
setup_directories() {
    log "Setting up directories..."
    mkdir -p flux-finetuning/assets/models/loras
    mkdir -p flux-finetuning/assets/flux_data
    mkdir -p flux-finetuning/assets/models/checkpoints
    mkdir -p flux-finetuning/assets/models/text_encoders
    mkdir -p flux-finetuning/assets/models/vae
}

# Check for API keys.
#
# Verify that required API keys are available from configuration.
#
# Returns:
#   0 - API keys are available.
#   1 - API keys are not available.
check_api_keys() {
    # Source the central configuration to get API keys
    if [[ -f "$HOME/config/export_ports.sh" ]]; then
        source "$HOME/config/export_ports.sh"
    elif [[ -f "/workspaces/dgx-spark-it-up/config/export_ports.sh" ]]; then
        source "/workspaces/dgx-spark-it-up/config/export_ports.sh"
    fi
    
    # Check if HF_TOKEN is available (from config or environment)
    if [[ -z "$hf_token" ]]; then
        if [[ -z "$HF_TOKEN" ]]; then
            error "HF_TOKEN environment variable is not set. Please set it before running this script."
        fi
    else
        # Use the configured HF_TOKEN
        export HF_TOKEN="$hf_token"
    fi
    
    # Check if NVIDIA API key is available (from config or environment)
    if [[ -z "$nvidia_api_key" ]]; then
        if [[ -z "$NGC_API_KEY" ]]; then
            warn "NGC_API_KEY environment variable not set. Some features may be limited."
        fi
    else
        # Use the configured NVIDIA API key
        export NGC_API_KEY="$nvidia_api_key"
    fi
}

# Download model.
#
# Download the FLUX.1-dev model using the download script.
#
# Returns:
#   0 - Model download completed or already exists.
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

# Build inference docker image.
#
# Build the Docker image for inference using the inference Dockerfile.
#
# Returns:
#   0 - Inference Docker image built successfully.
build_inference_image() {
    log "Building inference Docker image..."
    cd flux-finetuning/assets
    docker build -f Dockerfile.inference -t flux-comfyui .
    cd - > /dev/null
}

# Build training docker image.
#
# Build the Docker image for training using the training Dockerfile.
#
# Returns:
#   0 - Training Docker image built successfully
build_training_image() {
    log "Building training Docker image..."
    cd flux-finetuning/assets
    docker build -f Dockerfile.train -t flux-train .
    cd - > /dev/null
}

# Launch ComfyUI.
#
# Launch the ComfyUI container using the launch script.
#
# Returns:
#   0 - ComfyUI container launched successfully.
launch_comfyui() {
    log "Launching ComfyUI container..."
    cd flux-finetuning/assets
    sh launch_comfyui.sh
    cd - > /dev/null
}

# Launch training.
#
# Launch the training process using the training script.
#
# Returns:
#   0 - Training process launched successfully.
launch_training() {
    log "Launching training..."
    cd flux-finetuning/assets
    sh launch_train.sh
    cd - > /dev/null
}

# Prepare dataset.
#
# Create dataset directories and configure data.toml if it exists.
#
# Returns:
#   0 - Dataset preparation completed.
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

# Main execution function.
#
# Execute the main flux-finetuning automation workflow.
#
# Arguments:
#   $@ - All arguments passed to the script.
#
# Returns:
#   0 - Automation process completed successfully.
main() {
    log "Starting Flux Finetuning Automation Process"
    
    # Check prerequisites
    check_os
    check_docker_permissions
    
    # Setup
    setup_directories
    clone_repository
    check_api_keys
    
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