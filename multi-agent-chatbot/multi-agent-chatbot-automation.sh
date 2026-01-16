#!/usr/bin/env bash

# =============================================================================
# NVIDIA DGX Spark Multi-Agent Chatbot Automation Script
# This script automates the setup and deployment of the multi-agent chatbot
# following the official guide at https://build.nvidia.com/spark/multi-agent-chatbot
# =============================================================================

# Bash strict mode
set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Global variables
readonly SCRIPT_NAME="multi-agent-chatbot-automation.sh"
readonly REPO_URL="https://github.com/NVIDIA/dgx-spark-playbooks"
readonly ASSETS_DIR="dgx-spark-playbooks/nvidia/multi-agent-chatbot/assets"
readonly MODEL_DOWNLOAD_SCRIPT="model_download.sh"
readonly DOCKER_COMPOSE_FILE="docker-compose.yml"
readonly DOCKER_COMPOSE_MODELS_FILE="docker-compose-models.yml"

# Print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Display usage information
usage() {
    echo "Usage: $SCRIPT_NAME [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help               Show this help message"
    echo "  -s, --setup              Setup the multi-agent chatbot environment"
    echo "  -r, --run                Run the multi-agent chatbot containers"
    echo "  -t, --test               Test if containers are running"
    echo "  -c, --cleanup            Cleanup and rollback containers"
    echo "  -u, --ui                 Open the UI in browser (localhost:3000)"
    echo "  -p, --port-forward       Set up SSH tunnel for web access (requires SSH setup)"
    echo ""
    echo "Examples:"
    echo "  $SCRIPT_NAME --setup"
    echo "  $SCRIPT_NAME --run"
    echo "  $SCRIPT_NAME --test"
    echo "  $SCRIPT_NAME --cleanup"
    echo "  $SCRIPT_NAME --ui"
    echo ""
}

# Verify Docker installation
verify_docker() {
    print_status "Verifying Docker installation..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        return 1
    fi
    
    local docker_version
    docker_version=$(docker --version)
    print_status "Docker installed: $docker_version"
    
    # Check if user is in docker group
    if ! groups | grep -q docker; then
        print_warning "User is not in docker group. You may need to use sudo for Docker commands."
        print_warning "Run 'sudo usermod -aG docker $USER && newgrp docker' to add yourself to the docker group."
    fi
    
    return 0
}

# Configure Docker permissions
configure_docker_permissions() {
    print_status "Configuring Docker permissions..."
    
    if groups | grep -q docker; then
        print_status "User is already in docker group"
        return 0
    fi
    
    print_warning "Adding user to docker group..."
    if sudo usermod -aG docker "$USER"; then
        print_status "User added to docker group successfully"
        print_status "Please run 'newgrp docker' or log out and back in for changes to take effect"
        return 0
    else
        print_error "Failed to add user to docker group"
        return 1
    fi
}

# Clone the repository
clone_repository() {
    print_status "Cloning repository from $REPO_URL..."
    
    if [[ -d "dgx-spark-playbooks" ]]; then
        print_status "Repository already exists, skipping clone"
        return 0
    fi
    
    if git clone "$REPO_URL"; then
        print_status "Repository cloned successfully"
        return 0
    else
        print_error "Failed to clone repository"
        return 1
    fi
}

# Change to assets directory
change_to_assets_directory() {
    print_status "Changing to assets directory..."
    
    if [[ ! -d "$ASSETS_DIR" ]]; then
        print_error "Assets directory not found: $ASSETS_DIR"
        return 1
    fi
    
    cd "$ASSETS_DIR" || return 1
    print_status "Changed to directory: $(pwd)"
    return 0
}

# Run model download script
run_model_download() {
    print_status "Running model download script..."
    
    if [[ ! -f "$MODEL_DOWNLOAD_SCRIPT" ]]; then
        print_error "Model download script not found: $MODEL_DOWNLOAD_SCRIPT"
        return 1
    fi
    
    print_status "Making model_download.sh executable..."
    chmod +x "$MODEL_DOWNLOAD_SCRIPT"
    
    print_status "Running model download script. This may take 30 minutes to 2 hours..."
    print_status "Models being downloaded: gpt-oss-120B (~63GB), Deepseek-Coder:6.7B-Instruct (~7GB), Qwen3-Embedding-4B (~4GB)"
    
    # Run the model download script and show progress
    if ./"$MODEL_DOWNLOAD_SCRIPT"; then
        print_status "Model download completed successfully"
        return 0
    else
        print_error "Model download failed"
        return 1
    fi
}

# Start Docker containers
start_docker_containers() {
    print_status "Starting Docker containers..."
    
    if [[ ! -f "$DOCKER_COMPOSE_FILE" ]] || [[ ! -f "$DOCKER_COMPOSE_MODELS_FILE" ]]; then
        print_error "Docker compose files not found"
        print_status "Expected files: $DOCKER_COMPOSE_FILE and $DOCKER_COMPOSE_MODELS_FILE"
        return 1
    fi
    
    print_status "Building and starting containers. This may take 10-20 minutes..."
    print_status "Command: docker compose -f $DOCKER_COMPOSE_FILE -f $DOCKER_COMPOSE_MODELS_FILE up -d --build"
    
    if docker compose -f "$DOCKER_COMPOSE_FILE" -f "$DOCKER_COMPOSE_MODELS_FILE" up -d --build; then
        print_status "Docker containers started successfully"
        return 0
    else
        print_error "Failed to start Docker containers"
        return 1
    fi
}

# Wait for containers to be ready
wait_for_containers() {
    print_status "Waiting for containers to become ready and healthy..."
    print_status "This may take several minutes..."
    
    local max_wait=300  # 5 minutes max wait
    local wait_time=0
    local containers_ready=false
    
    while [[ $wait_time -lt $max_wait ]] && [[ "$containers_ready" == false ]]; do
        sleep 5
        wait_time=$((wait_time + 5))
        
        # Check if all containers are healthy
        if docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}" | grep -q "Up"; then
            containers_ready=true
            print_status "Containers are running and healthy"
        else
            print_status "Waiting for containers to be ready... ($wait_time seconds)"
        fi
    done
    
    if [[ "$containers_ready" == true ]]; then
        print_status "All containers are ready"
        return 0
    else
        print_warning "Timeout waiting for containers to be ready"
        return 1
    fi
}

# Check if containers are running
check_containers() {
    print_status "Checking running containers..."
    
    if docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}" | grep -q "Up"; then
        print_status "Containers are running"
        docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
        return 0
    else
        print_warning "No containers are currently running"
        return 1
    fi
}

# Cleanup containers and volumes
cleanup_containers() {
    print_status "Cleaning up containers and volumes..."
    
    # Stop and remove containers
    if docker compose -f "$DOCKER_COMPOSE_FILE" -f "$DOCKER_COMPOSE_MODELS_FILE" down; then
        print_status "Containers stopped and removed successfully"
    else
        print_warning "Failed to stop containers, continuing with cleanup"
    fi
    
    # Remove postgres data volume
    local volume_name="$(basename "$PWD")_postgres_data"
    if docker volume ls | grep -q "$volume_name"; then
        if docker volume rm "$volume_name"; then
            print_status "PostgreSQL data volume removed successfully"
        else
            print_warning "Failed to remove PostgreSQL data volume"
        fi
    else
        print_status "PostgreSQL data volume not found"
    fi
    
    print_status "Cleanup completed"
    return 0
}

# Open UI in browser
open_ui() {
    print_status "Opening UI in browser at http://localhost:3000"
    
    if command -v xdg-open &> /dev/null; then
        xdg-open "http://localhost:3000" &
    elif command -v open &> /dev/null; then
        open "http://localhost:3000" &
    else
        print_warning "Cannot open browser automatically. Please open http://localhost:3000 in your browser"
    fi
    
    print_status "UI should now be accessible at http://localhost:3000"
    return 0
}

# Set up SSH tunnel (for remote access)
setup_ssh_tunnel() {
    print_status "Setting up SSH tunnel for remote access..."
    print_warning "This requires SSH access to the remote host"
    print_warning "Run: ssh -L 3000:localhost:3000 -L 8000:localhost:8000 username@IP-address"
    print_status "After setup, access UI at http://localhost:3000"
    return 0
}

# Main function
main() {
    local action=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -s|--setup)
                action="setup"
                shift
                ;;
            -r|--run)
                action="run"
                shift
                ;;
            -t|--test)
                action="test"
                shift
                ;;
            -c|--cleanup)
                action="cleanup"
                shift
                ;;
            -u|--ui)
                action="ui"
                shift
                ;;
            -p|--port-forward)
                action="port-forward"
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # If no action specified, show help
    if [[ -z "$action" ]]; then
        print_warning "No action specified. Showing help."
        usage
        exit 1
    fi
    
    # Execute requested action
    case "$action" in
        setup)
            verify_docker
            configure_docker_permissions
            clone_repository
            change_to_assets_directory
            run_model_download
            ;;
        run)
            verify_docker
            change_to_assets_directory
            start_docker_containers
            wait_for_containers
            ;;
        test)
            verify_docker
            check_containers
            ;;
        cleanup)
            verify_docker
            change_to_assets_directory
            cleanup_containers
            ;;
        ui)
            open_ui
            ;;
        "port-forward")
            setup_ssh_tunnel
            ;;
        *)
            print_error "Unknown action: $action"
            usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"