#!/bin/bash

# JAX on Spark Automation Script
# This script automates the setup and execution of the JAX tutorial from NVIDIA's guide

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

# Check system prerequisites
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

# Clone the playbook repository
clone_playbook() {
    log "Cloning dgx-spark-playbooks repository..."
    
    if [ ! -d "dgx-spark-playbooks" ]; then
        git clone https://github.com/NVIDIA/dgx-spark-playbooks || error "Failed to clone dgx-spark-playbooks repository"
    else
        log "dgx-spark-playbooks repository already exists"
    fi
}

# Build the Docker image
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

# Launch Docker container
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

# Main execution function
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