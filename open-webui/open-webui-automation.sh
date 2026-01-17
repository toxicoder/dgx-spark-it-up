#!/bin/bash

# Open WebUI Automation Script
# This script automates the setup of Open WebUI with Ollama on DGX Spark

set -e  # Exit on any error

# Function to log messages
log() {
    echo "[INFO] $1"
}

# Function to error messages and exit
error() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Function to check if docker is installed and accessible
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

# Function to pull the Open WebUI container image
pull_container() {
    log "Pulling Open WebUI container image with Ollama..."
    docker pull ghcr.io/open-webui/open-webui:ollama
}

# Function to start the Open WebUI container
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

# Function to download and configure a model
download_model() {
    log "Downloading gpt-oss:20b model..."
    
    # This would typically be done through the web interface
    # For automation, we can use ollama directly
    docker exec open-webui ollama pull gpt-oss:20b
    
    log "Model gpt-oss:20b downloaded successfully"
}

# Function to verify the setup
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

# Function to cleanup resources
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

# Main function
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