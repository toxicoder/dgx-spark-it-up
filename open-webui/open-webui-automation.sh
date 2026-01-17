#!/bin/bash

# Open WebUI Automation Script.
#
# This script automates the setup of Open WebUI with Ollama on DGX Spark, including Docker setup, container management, model downloading, and verification.

set -e  # Exit on any error

# log - Log informational messages.
#
# Logs informational messages to stdout with [INFO] prefix.
#
# Parameters:
#   $1 (String) - Message to log.
#
# Returns:
#   0 - Success.
log() {
    echo "[INFO] $1"
}

# error - Log error messages and exit.
#
# Logs error messages to stderr with [ERROR] prefix and exits with code 1.
#
# Parameters:
#   $1 (String) - Error message to log.
#
# Returns:
#   1 - Error occurred.
error() {
    echo "[ERROR] $1" >&2
    exit 1
}

# check_docker - Check Docker installation and accessibility.
#
# Checks if Docker is installed and accessible, and verifies user has proper permissions.
#
# Returns:
#   0 - Docker is accessible.
#   1 - Docker not installed or inaccessible.
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first."
    fi
    
    # Test docker access
    if ! docker ps &> /dev/null; then
        log "Docker daemon not accessible. Checking if user is in docker group..."
        if ! groups | grep -q docker; then
            log "User is not in docker group. Adding user to docker group..."
            sudo usermod -aG docker $USER
            log "Please log out and back in for the group changes to take effect, or run 'newgrp docker'"
            error "Please re-run this script after logging in again"
        fi
    fi
}

# pull_container - Pull Open WebUI container image.
#
# Pulls the Open WebUI container image with Ollama from the remote registry.
#
# Returns:
#   0 - Container image pulled successfully.
#   1 - Failed to pull container image.
pull_container() {
    log "Pulling Open WebUI container image with Ollama..."
    docker pull ghcr.io/open-webui/open-webui:ollama
}

# start_container - Start Open WebUI container.
#
# Starts the Open WebUI container with required configurations and GPU access.
#
# Returns:
#   0 - Container started successfully.
#   1 - Failed to start container.
start_container() {
    log "Starting Open WebUI container..."
    
    # Remove existing container if it exists
    if docker ps -a --format '{{.Names}}' | grep -q open-webui; then
        log "Stopping existing Open WebUI container..."
        docker stop open-webui &> /dev/null || true
        docker rm open-webui &> /dev/null || true
    fi
    
    # Start the new container
    docker run -d -p 8080:8080 --gpus=all \
        -v open-webui:/app/backend/data \
        -v open-webui-ollama:/root/.ollama \
        --name open-webui ghcr.io/open-webui/open-webui:ollama
    
    # Wait for container to be ready
    log "Waiting for Open WebUI to start..."
    sleep 10
    
    # Check if container is running
    if ! docker ps --format '{{.Names}}' | grep -q open-webui; then
        error "Open WebUI container failed to start"
    fi
    
    log "Open WebUI container is running at http://localhost:8080"
}

# download_model - Download and configure model.
#
# Downloads a specified model (gpt-oss:20b) using Ollama within the container.
#
# Returns:
#   0 - Model downloaded successfully.
#   1 - Failed to download model.
download_model() {
    log "Downloading gpt-oss:20b model..."
    
    # This would typically be done through the web interface
    # For automation, we can use ollama directly
    docker exec open-webui ollama pull gpt-oss:20b
    
    log "Model gpt-oss:20b downloaded successfully"
}

# verify_setup - Verify Open WebUI setup.
#
# Verifies that the Open WebUI container is running and required volumes exist.
#
# Returns:
#   0 - Setup verified successfully.
#   1 - Setup verification failed.
verify_setup() {
    log "Verifying Open WebUI setup..."
    
    # Check if container is running
    if ! docker ps --format '{{.Names}}' | grep -q open-webui; then
        error "Open WebUI container is not running"
    fi
    
    # Check if volumes exist
    if ! docker volume ls --format '{{.Name}}' | grep -q open-webui; then
        error "Open WebUI data volume not found"
    fi
    
    if ! docker volume ls --format '{{.Name}}' | grep -q open-webui-ollama; then
        error "Open WebUI Ollama volume not found"
    fi
    
    log "Open WebUI setup verified successfully"
}

# cleanup - Cleanup Open WebUI resources.
#
# Cleans up all Open WebUI resources including containers, images, and volumes.
#
# Returns:
#   0 - Cleanup completed successfully.
cleanup() {
    log "Cleaning up Open WebUI resources..."
    
    # Stop and remove container
    if docker ps -a --format '{{.Names}}' | grep -q open-webui; then
        docker stop open-webui &> /dev/null || true
        docker rm open-webui &> /dev/null || true
    fi
    
    # Remove images
    docker rmi ghcr.io/open-webui/open-webui:ollama &> /dev/null || true
    
    # Remove volumes
    docker volume rm open-webui &> /dev/null || true
    docker volume rm open-webui-ollama &> /dev/null || true
    
    log "Cleanup completed successfully"
}

# main - Main execution function.
#
# Main execution function that orchestrates the complete Open WebUI setup process.
#
# Returns:
#   0 - Script completed successfully.
#   1 - Script failed at some point.
main() {
    log "Starting Open WebUI automation setup..."
    
    # Check prerequisites
    check_docker
    
    # Pull container image
    pull_container
    
    # Start container
    start_container
    
    # Download model
    download_model
    
    # Verify setup
    verify_setup
    
    log "Open WebUI setup completed successfully!"
    log "Access Open WebUI at http://localhost:8080"
    log "Create admin account at http://localhost:8080"
}

# Parse command line arguments
case "$1" in
    --cleanup)
        cleanup
        ;;
    --verify)
        verify_setup
        ;;
    --install)
        check_docker
        pull_container
        start_container
        download_model
        verify_setup
        ;;
    *)
        main
        ;;
esac