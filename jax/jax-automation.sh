#!/bin/bash

# JAX on Spark Automation Script
# This script automates the setup and execution of the JAX tutorial from NVIDIA's guide

set -euo pipefail

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
    echo -e "${YELLOW}[WARN]${NC} $1"
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

# Check system prerequisites.
#
# Verify that all system prerequisites are met for JAX on Spark.
#
# Returns:
#   0 - All prerequisites met.
#   1 - Missing prerequisite detected.
#
# Errors:
#   nvidia-smi not found: NVIDIA drivers and CUDA required.
#   Docker not found: Docker required for containerization.
check_prerequisites() {
    log "Checking system prerequisites..."
    
    # Verify GPU access
    if ! command -v nvidia-smi &> /dev/null; then
        error "nvidia-smi not found. Please install NVIDIA drivers and CUDA."
    fi
    
    # Verify ARM64 architecture or x86_64
    ARCH=$(uname -m)
    if [[ "$ARCH" != "aarch64" && "$ARCH" != "x86_64" ]]; then
        warn "Unsupported architecture: $ARCH"
    fi
    
    # Check Docker GPU support
    if ! command -v docker &> /dev/null; then
        error "Docker not found. Please install Docker."
    fi
    
    # Test Docker GPU support
    log "Testing Docker GPU support..."
    if ! docker run --gpus all --rm nvcr.io/nvidia/cuda:13.0.1-runtime-ubuntu24.04 nvidia-smi &> /dev/null; then
        warn "Docker GPU support test failed. You may need to add your user to the docker group."
        warn "Run: sudo usermod -aG docker \$USER && newgrp docker"
    fi
    
    log "Prerequisites check completed successfully"
}

# Clone the playbook repository.
#
# Clone the dgx-spark-playbooks repository from GitHub if it doesn't exist locally.
#
# Returns:
#   0 - Repository cloned or already exists.
#   1 - Failed to clone repository.
#
# Errors:
#   Failed to clone dgx-spark-playbooks repository: Repository cloning failed.
clone_playbook() {
    log "Cloning dgx-spark-playbooks repository..."
    
    if [ ! -d "dgx-spark-playbooks" ]; then
        git clone https://github.com/NVIDIA/dgx-spark-playbooks || error "Failed to clone dgx-spark-playbooks repository"
    else
        log "dgx-spark-playbooks repository already exists"
    fi
}

# Build the Docker image.
#
# Build the JAX Docker image for development environment.
#
# Returns:
#   0 - Docker image built successfully.
#   1 - Failed to build Docker image or assets directory not found.
#
# Errors:
#   JAX assets directory not found: Assets directory required for Docker build.
#   Failed to build Docker image: Docker build process failed.
build_docker_image() {
    log "Building JAX Docker image..."
    
    if [ ! -d "dgx-spark-playbooks/nvidia/jax/assets" ]; then
        error "JAX assets directory not found. Please check the repository structure."
    fi
    
    cd dgx-spark-playbooks/nvidia/jax/assets
    
    if ! docker build -t jax-on-spark .; then
        error "Failed to build Docker image"
    fi
    
    cd - > /dev/null
    log "Docker image built successfully"
}

# Launch Docker container.
#
# Launch the JAX development environment in a Docker container with GPU support.
#
# Returns:
#   0 - Docker container launched successfully.
#   1 - Docker image not found or launch failed.
#
# Errors:
#   Docker image jax-on-spark not found: Docker image needs to be built first.
#   Docker container launch failed: Container startup failed.
launch_docker_container() {
    log "Launching JAX development environment in Docker container..."
    
    # Check if the image exists
    if ! docker images | grep -q "jax-on-spark"; then
        error "Docker image jax-on-spark not found. Please build it first."
    fi
    
    log "Starting Docker container with GPU support and port forwarding..."
    docker run --gpus all --rm -it \
        --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864 \
        -p 8080:8080 \
        jax-on-spark
}

# Main execution function.
#
# Execute the main JAX on Spark automation workflow.
#
# Arguments:
#   $1 - Command to execute (prerequisites, clone, build, run, full).
#
# Returns:
#   0 - Automation process completed successfully.
#   1 - Invalid command or process failed.
#
# Errors:
#   Invalid command: Command not recognized.
main() {
    log "Starting JAX on Spark automation..."
    
    case "${1:-help}" in
        "prerequisites")
            check_prerequisites
            ;;
        "clone")
            clone_playbook
            ;;
        "build")
            build_docker_image
            ;;
        "run")
            launch_docker_container
            ;;
        "full")
            check_prerequisites
            clone_playbook
            build_docker_image
            launch_docker_container
            ;;
        *)
            echo "Usage: $0 {prerequisites|clone|build|run|full}"
            echo "  prerequisites - Check system prerequisites"
            echo "  clone - Clone the playbook repository"
            echo "  build - Build the Docker image"
            echo "  run - Launch Docker container"
            echo "  full - Run all steps"
            exit 1
            ;;
    esac
    
    log "JAX on Spark automation completed successfully"
}

# Run main function with all arguments
main "$@"