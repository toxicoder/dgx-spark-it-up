#!/bin/bash

# VSS Automation Script
# This script automates the setup and deployment of NVIDIA Video Search and Summarization (VSS) system

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

# Check if running as root (required for some operations)
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root"
    fi
}

# Verify environment requirements
verify_environment() {
    log "Step 1: Verifying environment requirements"
    
    # Check driver version
    if command -v nvidia-smi &> /dev/null; then
        driver_version=$(nvidia-smi --query-nvidia-driver-version -fo csv,noheader | tr -d ' ')
        log "Driver Version: $driver_version"
        if [[ "$driver_version" < "580.82.09" ]]; then
            warn "Driver version is below recommended 580.82.09"
        fi
    else
        error "nvidia-smi not found - NVIDIA drivers not installed"
    fi
    
    # Check CUDA version
    if command -v nvcc &> /dev/null; then
        cuda_version=$(nvcc --version | grep "Cuda compilation tools" | cut -d' ' -f5)
        log "CUDA Version: $cuda_version"
        if [[ "$cuda_version" < "13.0" ]]; then
            warn "CUDA version is below recommended 13.0"
        fi
    else
        error "nvcc not found - CUDA toolkit not installed"
    fi
    
    # Check Docker
    if command -v docker &> /dev/null; then
        log "Docker version: $(docker --version)"
        if command -v docker-compose &> /dev/null; then
            log "Docker Compose version: $(docker compose version)"
        else
            warn "Docker Compose not found, but Docker is available"
        fi
    else
        error "Docker not found - please install Docker"
    fi
    
    log "Environment verification completed"
}

# Configure Docker
configure_docker() {
    log "Step 2: Configuring Docker"
    
    # Check if user is in docker group
    if groups | grep -q docker; then
        log "User is already in docker group"
    else
        warn "User is not in docker group. Adding user to docker group..."
        sudo usermod -aG docker "$USER" || error "Failed to add user to docker group"
        log "Please log out and back in for group changes to take effect"
    fi
    
    # Configure NVIDIA Container Runtime
    if command -v nvidia-ctk &> /dev/null; then
        log "Configuring NVIDIA Container Runtime"
        sudo nvidia-ctk runtime configure --runtime=docker || error "Failed to configure NVIDIA Container Runtime"
        sudo systemctl restart docker || error "Failed to restart Docker service"
        
        # Test the setup
        log "Testing Docker with NVIDIA runtime"
        sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi || error "Docker test failed"
        log "Docker configuration completed successfully"
    else
        warn "nvidia-ctk not found. NVIDIA Container Runtime configuration skipped."
    fi
}

# Clone repository
clone_repository() {
    log "Step 3: Cloning VSS repository"
    
    if [ -d "video-search-and-summarization" ]; then
        log "Repository already exists, skipping clone"
        return
    fi
    
    git clone https://github.com/NVIDIA-AI-Blueprints/video-search-and-summarization.git || error "Failed to clone repository"
    cd video-search-and-summarization || error "Failed to change directory"
    
    log "Repository cloned successfully"
}

# Start cache cleaner
start_cache_cleaner() {
    log "Step 4: Starting system cache cleaner"
    
    # Start cache cleaner in background
    if command -v sys_cache_cleaner.sh &> /dev/null; then
        sudo sh deploy/scripts/sys_cache_cleaner.sh &
        log "Cache cleaner started in background"
    else
        warn "sys_cache_cleaner.sh not found"
    fi
}

# Create shared Docker network
create_docker_network() {
    log "Step 5: Creating Docker shared network"
    
    if docker network ls | grep -q vss-shared-network; then
        log "Network vss-shared-network already exists"
        return
    fi
    
    docker network create vss-shared-network || error "Failed to create Docker network"
    log "Docker network created successfully"
}

# Authenticate with NVIDIA Container Registry
authenticate_nvc() {
    log "Step 6: Authenticating with NVIDIA Container Registry"
    
    if [ -z "$NGC_API_KEY" ]; then
        error "NGC_API_KEY environment variable not set"
    fi
    
    echo "Logging in to NVIDIA Container Registry..."
    echo "$NGC_API_KEY" | docker login nvcr.io -u '$oauthtoken' --password-stdin || error "Failed to authenticate with NVIDIA Container Registry"
    
    log "Authentication completed"
}

# Set up deployment scenario
setup_deployment_scenario() {
    log "Step 7: Setting up deployment scenario"
    
    echo "Choose deployment scenario:"
    echo "1) VSS Event Reviewer (Completely Local)"
    echo "2) Standard VSS (Hybrid)"
    echo -n "Enter choice (1 or 2): "
    
    read -r choice
    
    case $choice in
        1)
            setup_event_reviewer
            ;;
        2)
            setup_standard_vss
            ;;
        *)
            error "Invalid choice"
            ;;
    esac
}

# Setup Event Reviewer scenario
setup_event_reviewer() {
    log "Setting up VSS Event Reviewer (Completely Local)"
    
    cd deploy/docker/event_reviewer/ || error "Failed to change directory to event reviewer"
    
    # Configure NGC API Key
    if [ -n "$NGC_API_KEY" ]; then
        echo "NGC_API_KEY=$NGC_API_KEY" >> .env
        log "NGC API Key configured"
    else
        warn "NGC_API_KEY not provided, please set it manually in .env file"
    fi
    
    # Update VSS_IMAGE
    echo "VSS_IMAGE=nvcr.io/nvidia/blueprint/vss-engine-sbsa:2.4.0" >> .env
    log "VSS image configured"
    
    # Start VSS Event Reviewer services
    log "Starting VSS Event Reviewer services..."
    IS_SBSA=1 IS_AARCH64=1 ALERT_REVIEW_MEDIA_BASE_DIR=/tmp/alert-media-dir docker compose up -d || error "Failed to start VSS Event Reviewer"
    
    log "VSS Event Reviewer services started"
}

# Setup Standard VSS scenario
setup_standard_vss() {
    log "Setting up Standard VSS (Hybrid Deployment)"
    
    cd deploy/docker/remote_llm_deployment/ || error "Failed to change directory to remote LLM deployment"
    
    # Configure environment variables
    if [ -n "$NVIDIA_API_KEY" ]; then
        echo "NVIDIA_API_KEY=$NVIDIA_API_KEY" >> .env
        log "NVIDIA API Key configured"
    else
        warn "NVIDIA_API_KEY not provided, please set it manually in .env file"
    fi
    
    if [ -n "$NGC_API_KEY" ]; then
        echo "NGC_API_KEY=$NGC_API_KEY" >> .env
        log "NGC API Key configured"
    else
        warn "NGC_API_KEY not provided, please set it manually in .env file"
    fi
    
    echo "DISABLE_CV_PIPELINE=true" >> .env
    echo "INSTALL_PROPRIETARY_CODECS=false" >> .env
    
    # Update VSS image
    echo "VIA_IMAGE=nvcr.io/nvidia/blueprint/vss-engine-sbsa:2.4.0" >> .env
    log "VSS image configured"
    
    # Check model configuration
    if [ -f "config.yaml" ]; then
        log "Model configuration in config.yaml:"
        grep -A 10 "model" config.yaml
    fi
    
    # Start Standard VSS deployment
    log "Starting Standard VSS deployment..."
    docker compose up -d || error "Failed to start Standard VSS"
    
    log "Standard VSS deployment started"
}

# Wait for service initialization
wait_for_services() {
    log "Waiting for services to initialize..."
    
    # Wait up to 300 seconds for services to be ready
    timeout=300
    elapsed=0
    
    while [ $elapsed -lt $timeout ]; do
        # Check if containers are running
        running_containers=$(docker ps --format "table {{.Names}}" | grep -c "vss\|cv\|alert" || echo 0)
        if [ "$running_containers" -ge 2 ]; then
            log "Services are running"
            return 0
        fi
        
        log "Waiting for services to start... ($elapsed/$timeout seconds)"
        sleep 5
        elapsed=$((elapsed + 5))
    done
    
    error "Services failed to start within timeout period"
}

# Validate deployment
validate_deployment() {
    log "Step 9: Validating deployment"
    
    echo "Checking service status..."
    docker ps
    
    log "Deployment validation completed"
}

# Test video processing workflow
test_workflow() {
    log "Step 10: Testing video processing workflow"
    
    if [ -d "deploy/docker/event_reviewer" ]; then
        log "Testing Event Reviewer deployment"
        # Test CV UI accessibility
        if curl -f -I http://localhost:7862 > /dev/null 2>&1; then
            log "CV UI is accessible"
        else
            warn "CV UI not accessible"
        fi
        
        # Test Alert Inspector UI accessibility
        if curl -f -I http://localhost:7860 > /dev/null 2>&1; then
            log "Alert Inspector UI is accessible"
        else
            warn "Alert Inspector UI not accessible"
        fi
    elif [ -d "deploy/docker/remote_llm_deployment" ]; then
        log "Testing Standard VSS deployment"
        # Test VSS UI accessibility
        if curl -f -I http://localhost:9100 > /dev/null 2>&1; then
            log "VSS UI is accessible"
        else
            warn "VSS UI not accessible"
        fi
    fi
    
    log "Workflow testing completed"
}

# Cleanup deployment
cleanup() {
    log "Step 11: Cleaning up deployment"
    
    if [ -d "deploy/docker/event_reviewer" ]; then
        log "Cleaning up Event Reviewer deployment"
        cd deploy/docker/event_reviewer/ || return
        IS_SBSA=1 IS_AARCH64=1 ALERT_REVIEW_MEDIA_BASE_DIR=/tmp/alert-media-dir docker compose down || warn "Failed to stop Event Reviewer services"
        cd ../../examples/cv-event-detector/ || return
        IS_SBSA=1 IS_AARCH64=1 ALERT_REVIEW_MEDIA_BASE_DIR=/tmp/alert-media-dir docker compose down || warn "Failed to stop CV services"
        cd ../../../
        
        # Remove shared network if it exists
        if docker network ls | grep -q vss-shared-network; then
            docker network rm vss-shared-network || warn "Failed to remove Docker network"
        fi
        
        # Clean up temporary files
        rm -rf /tmp/alert-media-dir || warn "Failed to clean up temporary files"
        sudo pkill -f sys_cache_cleaner.sh || warn "Failed to stop cache cleaner"
    elif [ -d "deploy/docker/remote_llm_deployment" ]; then
        log "Cleaning up Standard VSS deployment"
        cd deploy/docker/remote_llm_deployment/ || return
        docker compose down || warn "Failed to stop Standard VSS services"
        cd ../../../
    fi
    
    log "Cleanup completed"
}

# Display next steps
display_next_steps() {
    log "Step 12: Next steps"
    echo "With VSS deployed, you can now:"
    echo ""
    if [ -d "deploy/docker/event_reviewer" ]; then
        echo "Event Reviewer deployment:"
        echo "  - Upload video files through the CV UI at port 7862"
        echo "  - Monitor automated event detection and reviewing"
        echo "  - Review analysis results in the Alert Inspector UI at port 7860"
        echo "  - Configure custom event detection rules and thresholds"
    elif [ -d "deploy/docker/remote_llm_deployment" ]; then
        echo "Standard VSS deployment:"
        echo "  - Access full VSS capabilities at port 9100"
        echo "  - Test video summarization and Q&A features"
        echo "  - Configure knowledge graphs and graph databases"
        echo "  - Integrate with existing video processing workflows"
    fi
}

# Main function
main() {
    log "Starting VSS Automation Setup"
    
    # Check if running as root
    check_root
    
    # Verify environment requirements
    verify_environment
    
    # Configure Docker
    configure_docker
    
    # Clone repository
    clone_repository
    
    # Start cache cleaner
    start_cache_cleaner
    
    # Create Docker network
    create_docker_network
    
    # Authenticate with NVIDIA Container Registry
    authenticate_nvc
    
    # Setup deployment scenario
    setup_deployment_scenario
    
    # Wait for services
    wait_for_services
    
    # Validate deployment
    validate_deployment
    
    # Test workflow
    test_workflow
    
    # Display next steps
    display_next_steps
    
    log "VSS Automation Setup completed successfully!"
}

# Parse command line arguments
if [ "$1" = "cleanup" ]; then
    cleanup
    exit 0
fi

# Run main function
main "$@"