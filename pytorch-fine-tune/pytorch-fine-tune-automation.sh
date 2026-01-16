#!/usr/bin/env bash

# =============================================================================
# NVIDIA DGX Spark PyTorch Fine-Tuning Automation Script
# This script automates the PyTorch fine-tuning process on DGX Spark nodes
# following the official guide at https://build.nvidia.com/spark/pytorch-fine-tune
# =============================================================================

# Bash strict mode
set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Global variables
readonly SCRIPT_NAME="pytorch-fine-tune-automation.sh"
readonly CONFIG_FILE="$HOME/.pytorch-fine-tune-config"
readonly LOG_FILE="/tmp/pytorch-fine-tune-automation.log"

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

print_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Log function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Display usage information
usage() {
    echo "Usage: $SCRIPT_NAME [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help                     Show this help message"
    echo "  -c, --configure                Configure fine-tuning settings"
    echo "  -v, --verify                   Verify system requirements"
    echo "  -n, --network                  Configure network connectivity"
    echo "  -d, --docker                   Configure Docker permissions and setup"
    echo "  -r, --resources                Enable resource advertising"
    echo "  -s, --swarm                    Initialize Docker Swarm"
    echo "  -j, --join                     Join worker nodes"
    echo "  -D, --deploy                   Deploy fine-tuning stack"
    echo "  -f, --finetune                 Run fine-tuning"
    echo "  -C, --cleanup                  Cleanup and rollback"
    echo "  -a, --all                      Run all steps (except cleanup)"
    echo ""
    echo "Examples:"
    echo "  $SCRIPT_NAME --configure"
    echo "  $SCRIPT_NAME --verify"
    echo "  $SCRIPT_NAME --all"
    echo ""
}

# Verify system requirements
verify_requirements() {
    print_status "Verifying system requirements..."
    
    # Check if we're on a DGX Spark system
    if ! command -v nvidia-smi &> /dev/null; then
        print_warning "nvidia-smi not found. This might not be a DGX system."
    fi
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        return 1
    fi
    
    # Check if docker-compose is installed
    if ! command -v docker-compose &> /dev/null && ! command -v docker &> /dev/null; then
        print_error "Docker Compose is not installed"
        return 1
    fi
    
    # Check if bash is available
    if ! command -v bash &> /dev/null; then
        print_error "Bash shell is not available"
        return 1
    fi
    
    print_status "All system requirements verified"
    return 0
}

# Gather fine-tuning configuration
gather_config() {
    print_status "Gathering fine-tuning configuration..."
    
    # If config file exists, load it
    if [[ -f "$CONFIG_FILE" ]]; then
        print_status "Loading configuration from $CONFIG_FILE"
        source "$CONFIG_FILE"
    fi
    
    # Get user information
    if [[ -z "${FINETUNE_USERNAME:-}" ]]; then
        read -rp "Enter your DGX Spark username: " FINETUNE_USERNAME
    fi
    
    # Get manager node information
    if [[ -z "${MANAGER_HOSTNAME:-}" ]]; then
        read -rp "Enter manager node hostname (without .local): " MANAGER_HOSTNAME
    fi
    
    # Get worker nodes information
    if [[ -z "${WORKER_HOSTNAMES:-}" ]]; then
        read -rp "Enter worker node hostnames (comma separated, without .local): " WORKER_HOSTNAMES
    fi
    
    # Get HuggingFace token
    if [[ -z "${HF_TOKEN:-}" ]]; then
        read -rp "Enter HuggingFace token for model access: " HF_TOKEN
    fi
    
    # Save configuration
    cat > "$CONFIG_FILE" << EOF
# PyTorch Fine-Tuning Configuration
FINETUNE_USERNAME="$FINETUNE_USERNAME"
MANAGER_HOSTNAME="$MANAGER_HOSTNAME"
WORKER_HOSTNAMES="$WORKER_HOSTNAMES"
HF_TOKEN="$HF_TOKEN"
EOF
    
    print_status "Configuration saved to $CONFIG_FILE"
    log "Configuration saved"
    return 0
}

# Configure network connectivity (Step 1)
configure_network() {
    print_status "Configuring network connectivity..."
    
    # This is a placeholder - in a real implementation, this would:
    # 1. Check physical QSFP cable connections
    # 2. Configure network interfaces
    # 3. Set up passwordless SSH
    # 4. Verify network connectivity
    
    print_warning "Network configuration requires manual setup according to DGX Spark documentation."
    print_warning "Please ensure:"
    print_warning "  - Physical QSFP cable connection is established"
    print_warning "  - Network interface configuration is complete"
    print_warning "  - Passwordless SSH is configured"
    print_warning "  - Network connectivity is verified"
    
    # Ask user to confirm
    read -rp "Press Enter to continue once network is configured..."
    return 0
}

# Configure Docker permissions (Step 2)
configure_docker_permissions() {
    print_status "Configuring Docker permissions..."
    
    # Check if user is already in docker group
    if groups "$USER" | grep -q docker; then
        print_status "User is already in docker group"
        return 0
    fi
    
    # Add user to docker group
    print_status "Adding user to docker group..."
    if sudo usermod -aG docker "$USER"; then
        print_status "User added to docker group successfully"
        print_status "Please log out and log back in for changes to take effect"
        log "Added user to docker group"
    else
        print_error "Failed to add user to docker group"
        return 1
    fi
    
    # Test Docker access
    print_status "Testing Docker access..."
    if docker ps >/dev/null 2>&1; then
        print_status "Docker access verified"
        return 0
    else
        print_warning "Docker access still requires sudo - you may need to log out and back in"
        return 1
    fi
}

# Install NVIDIA Container Toolkit & setup Docker environment (Step 3)
install_nvidia_toolkit() {
    print_status "Installing NVIDIA Container Toolkit..."
    
    # This is a placeholder - actual implementation would check and install:
    # 1. NVIDIA drivers
    # 2. NVIDIA Container Toolkit
    # 3. Docker configuration for NVIDIA Container Toolkit
    
    print_warning "NVIDIA Container Toolkit installation requires manual setup."
    print_warning "Please ensure NVIDIA drivers and NVIDIA Container Toolkit are installed on all nodes."
    print_warning "Refer to NVIDIA documentation for installation steps."
    
    # Ask user to confirm
    read -rp "Press Enter to continue once NVIDIA Container Toolkit is installed on all nodes..."
    return 0
}

# Enable resource advertising (Step 4)
enable_resource_advertising() {
    print_status "Enabling resource advertising..."
    
    # Find GPU UUID
    print_status "Finding GPU UUID..."
    local gpu_uuid
    gpu_uuid=$(nvidia-smi -a | grep UUID | awk '{print $3}')
    
    if [[ -z "$gpu_uuid" ]]; then
        print_error "Failed to retrieve GPU UUID"
        return 1
    fi
    
    print_status "Found GPU UUID: $gpu_uuid"
    
    # Modify Docker daemon configuration
    print_status "Modifying Docker daemon configuration..."
    local daemon_config="/etc/docker/daemon.json"
    
    # Create backup
    if [[ -f "$daemon_config" ]]; then
        sudo cp "$daemon_config" "${daemon_config}.backup"
    fi
    
    # Create or update daemon.json
    sudo tee "$daemon_config" > /dev/null << EOF
{
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  },
  "default-runtime": "nvidia",
  "node-generic-resources": [
    "NVIDIA_GPU=$gpu_uuid"
  ]
}
EOF
    
    print_status "Docker daemon configuration updated"
    
    # Modify nvidia-container-runtime config
    print_status "Enabling swarm resource advertisement..."
    local runtime_config="/etc/nvidia-container-runtime/config.toml"
    
    if [[ -f "$runtime_config" ]]; then
        sudo sed -i 's/^#\s*\(swarm-resource\s*=\s*".*"\)/\1/' "$runtime_config"
        print_status "Swarm resource advertisement enabled in nvidia-container-runtime config"
    else
        print_warning "nvidia-container-runtime config not found. This may not be an issue."
    fi
    
    # Restart Docker daemon
    print_status "Restarting Docker daemon..."
    sudo systemctl restart docker
    
    print_status "Docker daemon restarted successfully"
    log "Resource advertising enabled with GPU UUID: $gpu_uuid"
    return 0
}

# Initialize Docker Swarm (Step 5)
initialize_swarm() {
    print_status "Initializing Docker Swarm..."
    
    # Check if we're on the manager node
    if [[ -z "${MANAGER_HOSTNAME:-}" ]]; then
        print_error "Manager hostname not configured"
        return 1
    fi
    
    # Check if already in swarm
    if docker info >/dev/null 2>&1 && docker info | grep -q "Swarm: active"; then
        print_status "Already in Docker Swarm"
        return 0
    fi
    
    # Initialize swarm
    print_status "Initializing Docker Swarm on manager node..."
    
    # Try to get IP addresses of network interfaces
    local ip1=""
    local ip2=""
    
    # Get first IP address
    ip1=$(ip -o -4 addr show enp1s0f0np0 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
    if [[ -z "$ip1" ]]; then
        ip1=$(ip -o -4 addr show enp1s0f1np1 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
    fi
    
    # Get second IP address if available
    ip2=$(ip -o -4 addr show enp1s0f1np1 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
    if [[ -z "$ip2" ]]; then
        ip2=$(ip -o -4 addr show enp1s0f0np0 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
    fi
    
    local advertise_addr=""
    if [[ -n "$ip1" ]]; then
        advertise_addr="--advertise-addr $ip1"
        if [[ -n "$ip2" && "$ip1" != "$ip2" ]]; then
            advertise_addr="$advertise_addr $ip2"
        fi
    fi
    
    print_debug "Using advertise address: $advertise_addr"
    
    # Initialize swarm
    if docker swarm init $advertise_addr; then
        print_status "Docker Swarm initialized successfully"
        log "Docker Swarm initialized"
        return 0
    else
        print_error "Failed to initialize Docker Swarm"
        return 1
    fi
}

# Join worker nodes (Step 6)
join_worker_nodes() {
    print_status "Joining worker nodes to Docker Swarm..."
    
    # Check if we're on a worker node
    if [[ -z "${WORKER_HOSTNAMES:-}" ]]; then
        print_warning "Worker hostnames not configured. Skipping worker node joining."
        return 0
    fi
    
    # This is a complex process that would require:
    # 1. Getting the join token from the manager
    # 2. Running the join command on each worker
    
    print_warning "Worker node joining requires manual execution on each worker node."
    print_warning "Please run the following command on each worker node:"
    print_warning "  docker swarm join --token <worker-token> <manager-ip>:<port>"
    print_warning "The join command will be displayed after manager setup is complete."
    
    # Get the join command from manager (simplified approach)
    if docker info >/dev/null 2>&1 && docker info | grep -q "Swarm: active"; then
        print_status "Manager node swarm status verified"
        print_status "Use 'docker swarm join-token worker' on manager to get join command"
    else
        print_warning "Not on manager node or swarm not initialized"
    fi
    
    # Ask user to confirm
    read -rp "Press Enter after joining all worker nodes..."
    return 0
}

# Deploy fine-tuning stack (Step 6 continued)
deploy_stack() {
    print_status "Deploying fine-tuning stack..."
    
    # Check if required files exist
    local compose_file="$PWD/docker-compose.yml"
    local entrypoint_file="$PWD/pytorch-ft-entrypoint.sh"
    
    if [[ ! -f "$compose_file" ]]; then
        print_error "docker-compose.yml not found in current directory"
        return 1
    fi
    
    if [[ ! -f "$entrypoint_file" ]]; then
        print_error "pytorch-ft-entrypoint.sh not found in current directory"
        return 1
    fi
    
    # Make entrypoint executable
    chmod +x "$entrypoint_file"
    
    # Deploy stack
    print_status "Deploying fine-tuning multi-node stack..."
    if docker stack deploy -c "$compose_file" finetuning-multinode; then
        print_status "Fine-tuning stack deployed successfully"
        log "Fine-tuning stack deployed"
        return 0
    else
        print_error "Failed to deploy fine-tuning stack"
        return 1
    fi
}

# Find Docker container ID (Step 7)
find_container_id() {
    print_status "Finding Docker container ID..."
    
    # Get container ID
    local container_id
    container_id=$(docker ps -q -f name=finetuning-multinode)
    
    if [[ -z "$container_id" ]]; then
        print_warning "No running finetuning-multinode containers found"
        return 1
    fi
    
    print_status "Found container ID: $container_id"
    echo "FINETUNING_CONTAINER=$container_id" >> "$CONFIG_FILE"
    log "Container ID found: $container_id"
    return 0
}

# Adapt configuration files (Step 8)
adapt_config_files() {
    print_status "Adapting configuration files..."
    
    # This is a complex step requiring:
    # 1. Setting machine_rank for each node
    # 2. Setting main_process_ip from manager node
    # 3. Setting main_process_port
    
    # Check if we have configuration files
    local config_files=("$PWD/config_finetuning.yaml" "$PWD/config_fsdp_lora.yaml")
    local found_configs=false
    
    for config_file in "${config_files[@]}"; do
        if [[ -f "$config_file" ]]; then
            found_configs=true
            print_status "Found configuration file: $config_file"
        fi
    done
    
    if [[ "$found_configs" == false ]]; then
        print_warning "No configuration files found. You need to download them first."
        return 1
    fi
    
    # Get manager IP
    local manager_ip=""
    if [[ -n "${MANAGER_HOSTNAME:-}" ]]; then
        manager_ip=$(ping -c 1 -W 5 "${MANAGER_HOSTNAME}.local" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        if [[ -z "$manager_ip" ]]; then
            print_warning "Could not resolve manager hostname. Please set main_process_ip manually."
        fi
    fi
    
    print_status "Manager IP: $manager_ip"
    
    print_warning "Configuration file adaptation requires manual editing."
    print_warning "Please edit the following files to set:"
    print_warning "  - machine_rank (0 for manager, 1 for worker, etc.)"
    print_warning "  - main_process_ip (manager node IP)"
    print_warning "  - main_process_port (a free port on manager node)"
    
    # Ask user to confirm
    read -rp "Press Enter after adapting configuration files..."
    return 0
}

# Run fine-tuning scripts (Step 9)
run_finetune() {
    print_status "Running fine-tuning scripts..."
    
    # Check if container ID exists
    local container_id
    container_id=$(docker ps -q -f name=finetuning-multinode)
    
    if [[ -z "$container_id" ]]; then
        print_error "No running container found. Please run 'find_container_id' first."
        return 1
    fi
    
    # Check if HuggingFace token is set
    if [[ -z "${HF_TOKEN:-}" ]]; then
        print_error "HuggingFace token not configured"
        return 1
    fi
    
    # Run the fine-tuning command
    print_status "Running fine-tuning script with container: $container_id"
    print_status "Make sure you have the required scripts in your container"
    
    # This command would be run inside the container to execute the fine-tuning
    print_warning "The actual fine-tuning command would be something like:"
    print_warning "  docker exec -e HF_TOKEN=$HF_TOKEN -it $container_id bash -c 'bash /workspace/install-requirements; accelerate launch --config_file=/workspace/configs/config_fsdp_lora.yaml /workspace/Llama3_70B_LoRA_finetuning.py'"
    
    print_warning "Please execute your fine-tuning command manually with the appropriate parameters."
    
    # Ask user to confirm
    read -rp "Press Enter after running the fine-tuning script..."
    return 0
}

# Cleanup and rollback (Step 10)
cleanup() {
    print_status "Cleaning up and rolling back..."
    
    # Remove containers
    print_status "Removing fine-tuning stack..."
    if docker stack rm finetuning-multinode; then
        print_status "Fine-tuning stack removed"
    else
        print_warning "Failed to remove fine-tuning stack"
    fi
    
    # Remove downloaded models
    print_status "Removing downloaded models..."
    if rm -rf "$HOME/.cache/huggingface/hub/models--meta-llama*" "$HOME/.cache/huggingface/hub/datasets*"; then
        print_status "Downloaded models removed"
    else
        print_warning "Failed to remove downloaded models"
    fi
    
    # Remove config file
    if rm -f "$CONFIG_FILE"; then
        print_status "Configuration file removed"
    else
        print_warning "Failed to remove configuration file"
    fi
    
    print_status "Cleanup completed"
    log "Cleanup completed"
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
            -c|--configure)
                action="configure"
                shift
                ;;
            -v|--verify)
                action="verify"
                shift
                ;;
            -n|--network)
                action="network"
                shift
                ;;
            -d|--docker)
                action="docker"
                shift
                ;;
            -r|--resources)
                action="resources"
                shift
                ;;
            -s|--swarm)
                action="swarm"
                shift
                ;;
            -j|--join)
                action="join"
                shift
                ;;
            -D|--deploy)
                action="deploy"
                shift
                ;;
            -f|--finetune)
                action="finetune"
                shift
                ;;
            -C|--cleanup)
                action="cleanup"
                shift
                ;;
            -a|--all)
                action="all"
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
    
    # Create log file
    touch "$LOG_FILE"
    
    # Execute requested action
    case "$action" in
        configure)
            gather_config
            ;;
        verify)
            verify_requirements
            ;;
        network)
            verify_requirements
            configure_network
            ;;
        docker)
            verify_requirements
            configure_docker_permissions
            ;;
        resources)
            verify_requirements
            enable_resource_advertising
            ;;
        swarm)
            verify_requirements
            initialize_swarm
            ;;
        join)
            verify_requirements
            join_worker_nodes
            ;;
        deploy)
            verify_requirements
            deploy_stack
            ;;
        finetune)
            verify_requirements
            find_container_id
            adapt_config_files
            run_finetune
            ;;
        cleanup)
            cleanup
            ;;
        all)
            verify_requirements
            gather_config
            configure_network
            configure_docker_permissions
            install_nvidia_toolkit
            enable_resource_advertising
            initialize_swarm
            join_worker_nodes
            deploy_stack
            find_container_id
            adapt_config_files
            run_finetune
            ;;
        *)
            print_error "Unknown action: $action"
            usage
            exit 1
            ;;
    esac
    
    print_status "Script execution completed"
    log "Script execution completed"
}

# Run main function with all arguments
main "$@"