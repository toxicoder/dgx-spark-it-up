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

# SSH function to execute command on remote node
ssh_execute() {
    local node="$1"
    local command="$2"
    local timeout="${3:-30}"
    
    # SSH to node and execute command with timeout
    timeout "$timeout" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
        "${FINETUNE_USERNAME:-$USER}@${node}.local" "$command" 2>/dev/null
}

# Configure network connectivity (Step 1)
configure_network() {
    print_status "Configuring network connectivity..."
    
    # Check if we have manager and worker nodes
    if [[ -z "${MANAGER_HOSTNAME:-}" ]]; then
        print_error "Manager hostname not configured"
        return 1
    fi
    
    if [[ -z "${WORKER_HOSTNAMES:-}" ]]; then
        print_warning "Worker hostnames not configured. Proceeding with manager node only."
    fi
    
    # Check if we can SSH to manager node
    print_status "Testing SSH connectivity to manager node..."
    if ! ssh_execute "$MANAGER_HOSTNAME" "echo 'SSH test successful'"; then
        print_error "Cannot SSH to manager node $MANAGER_HOSTNAME"
        return 1
    fi
    
    print_status "SSH connectivity to manager node verified"
    
    # Check if we have worker nodes
    if [[ -n "${WORKER_HOSTNAMES:-}" ]]; then
        IFS=',' read -ra WORKERS <<< "$WORKER_HOSTNAMES"
        for worker in "${WORKERS[@]}"; do
            print_status "Testing SSH connectivity to worker node $worker..."
            if ! ssh_execute "$worker" "echo 'SSH test successful'"; then
                print_error "Cannot SSH to worker node $worker"
                return 1
            fi
            print_status "SSH connectivity to worker node $worker verified"
        done
    fi
    
    # Check for required network interfaces
    print_status "Checking network interfaces..."
    local manager_interfaces
    manager_interfaces=$(ssh_execute "$MANAGER_HOSTNAME" "ip link show | grep -E 'enp[0-9]+s[0-9]+f[0-9]+' | awk '{print \$2}' | tr -d ':')")
    
    if [[ -z "$manager_interfaces" ]]; then
        print_warning "Could not find expected network interfaces on manager node. Please verify network setup."
    else
        print_status "Found network interfaces on manager: $manager_interfaces"
    fi
    
    # Check passwordless SSH
    print_status "Verifying passwordless SSH setup..."
    if ssh_execute "$MANAGER_HOSTNAME" "true"; then
        print_status "Passwordless SSH verified for manager node"
    else
        print_warning "Passwordless SSH not working for manager node. Please set up passwordless SSH."
        return 1
    fi
    
    if [[ -n "${WORKER_HOSTNAMES:-}" ]]; then
        for worker in "${WORKERS[@]}"; do
            if ssh_execute "$worker" "true"; then
                print_status "Passwordless SSH verified for worker node $worker"
            else
                print_warning "Passwordless SSH not working for worker node $worker. Please set up passwordless SSH."
                return 1
            fi
        done
    fi
    
    print_status "Network connectivity configured successfully"
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
    
    # Install NVIDIA Container Toolkit on manager node
    print_status "Installing NVIDIA Container Toolkit on manager node..."
    if ssh_execute "$MANAGER_HOSTNAME" "command -v nvidia-smi >/dev/null 2>&1 && sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit"; then
        print_status "NVIDIA Container Toolkit installed on manager node"
    else
        print_warning "Failed to install NVIDIA Container Toolkit on manager node. Continuing with other steps."
    fi
    
    # Install NVIDIA Container Toolkit on worker nodes if they exist
    if [[ -n "${WORKER_HOSTNAMES:-}" ]]; then
        IFS=',' read -ra WORKERS <<< "$WORKER_HOSTNAMES"
        for worker in "${WORKERS[@]}"; do
            print_status "Installing NVIDIA Container Toolkit on worker node $worker..."
            if ssh_execute "$worker" "command -v nvidia-smi >/dev/null 2>&1 && sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit"; then
                print_status "NVIDIA Container Toolkit installed on worker node $worker"
            else
                print_warning "Failed to install NVIDIA Container Toolkit on worker node $worker. Continuing with other steps."
            fi
        done
    fi
    
    print_status "NVIDIA Container Toolkit installation process initiated"
    return 0
}

# Enable resource advertising (Step 4)
enable_resource_advertising() {
    print_status "Enabling resource advertising..."
    
    # Find GPU UUID on manager node
    print_status "Finding GPU UUID on manager node..."
    local gpu_uuid
    gpu_uuid=$(ssh_execute "$MANAGER_HOSTNAME" "nvidia-smi -a | grep UUID | awk '{print \$3}'")
    
    if [[ -z "$gpu_uuid" ]]; then
        print_error "Failed to retrieve GPU UUID from manager node"
        return 1
    fi
    
    print_status "Found GPU UUID: $gpu_uuid"
    
    # Modify Docker daemon configuration on manager node
    print_status "Modifying Docker daemon configuration on manager node..."
    local daemon_config="/etc/docker/daemon.json"
    
    # Create backup
    ssh_execute "$MANAGER_HOSTNAME" "sudo cp $daemon_config ${daemon_config}.backup 2>/dev/null || true"
    
    # Create or update daemon.json on manager node
    ssh_execute "$MANAGER_HOSTNAME" "sudo tee $daemon_config > /dev/null << EOF
{
  \"runtimes\": {
    \"nvidia\": {
      \"path\": \"nvidia-container-runtime\",
      \"runtimeArgs\": []
    }
  },
  \"default-runtime\": \"nvidia\",
  \"node-generic-resources\": [
    \"NVIDIA_GPU=$gpu_uuid\"
  ]
}
EOF"
    
    print_status "Docker daemon configuration updated on manager node"
    
    # Modify nvidia-container-runtime config on manager node
    print_status "Enabling swarm resource advertisement on manager node..."
    local runtime_config="/etc/nvidia-container-runtime/config.toml"
    
    ssh_execute "$MANAGER_HOSTNAME" "sudo sed -i 's/^#\s*\(swarm-resource\s*=\s*\".*\"\)/\1/' $runtime_config 2>/dev/null || true"
    print_status "Swarm resource advertisement enabled on manager node"
    
    # Restart Docker daemon on manager node
    print_status "Restarting Docker daemon on manager node..."
    if ssh_execute "$MANAGER_HOSTNAME" "sudo systemctl restart docker"; then
        print_status "Docker daemon restarted successfully on manager node"
    else
        print_warning "Failed to restart Docker daemon on manager node"
    fi
    
    # Apply to worker nodes if they exist
    if [[ -n "${WORKER_HOSTNAMES:-}" ]]; then
        IFS=',' read -ra WORKERS <<< "$WORKER_HOSTNAMES"
        for worker in "${WORKERS[@]}"; do
            print_status "Applying resource advertising to worker node $worker..."
            
            # Create backup on worker
            ssh_execute "$worker" "sudo cp $daemon_config ${daemon_config}.backup 2>/dev/null || true"
            
            # Update daemon.json on worker
            ssh_execute "$worker" "sudo tee $daemon_config > /dev/null << EOF
{
  \"runtimes\": {
    \"nvidia\": {
      \"path\": \"nvidia-container-runtime\",
      \"runtimeArgs\": []
    }
  },
  \"default-runtime\": \"nvidia\",
  \"node-generic-resources\": [
    \"NVIDIA_GPU=$gpu_uuid\"
  ]
}
EOF"
            
            # Enable swarm resource advertisement on worker
            ssh_execute "$worker" "sudo sed -i 's/^#\s*\(swarm-resource\s*=\s*\".*\"\)/\1/' $runtime_config 2>/dev/null || true"
            
            # Restart Docker daemon on worker
            if ssh_execute "$worker" "sudo systemctl restart docker"; then
                print_status "Docker daemon restarted successfully on worker node $worker"
            else
                print_warning "Failed to restart Docker daemon on worker node $worker"
            fi
        done
    fi
    
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
    
    # Initialize swarm on manager node
    print_status "Initializing Docker Swarm on manager node $MANAGER_HOSTNAME..."
    
    # Try to get IP addresses of network interfaces
    local ip1=""
    local ip2=""
    
    # Get first IP address
    ip1=$(ssh_execute "$MANAGER_HOSTNAME" "ip -o -4 addr show enp1s0f0np0 2>/dev/null | awk '{print \$4}' | cut -d/ -f1")
    if [[ -z "$ip1" ]]; then
        ip1=$(ssh_execute "$MANAGER_HOSTNAME" "ip -o -4 addr show enp1s0f1np1 2>/dev/null | awk '{print \$4}' | cut -d/ -f1")
    fi
    
    # Get second IP address if available
    ip2=$(ssh_execute "$MANAGER_HOSTNAME" "ip -o -4 addr show enp1s0f1np1 2>/dev/null | awk '{print \$4}' | cut -d/ -f1")
    if [[ -z "$ip2" ]]; then
        ip2=$(ssh_execute "$MANAGER_HOSTNAME" "ip -o -4 addr show enp1s0f0np0 2>/dev/null | awk '{print \$4}' | cut -d/ -f1")
    fi
    
    local advertise_addr=""
    if [[ -n "$ip1" ]]; then
        advertise_addr="--advertise-addr $ip1"
        if [[ -n "$ip2" && "$ip1" != "$ip2" ]]; then
            advertise_addr="$advertise_addr $ip2"
        fi
    fi
    
    print_debug "Using advertise address: $advertise_addr"
    
    # Initialize swarm on manager node
    local swarm_init_output
    swarm_init_output=$(ssh_execute "$MANAGER_HOSTNAME" "docker swarm init $advertise_addr 2>&1")
    
    if [[ $? -eq 0 ]]; then
        print_status "Docker Swarm initialized successfully on manager node"
        echo "$swarm_init_output" | grep -E "(join|token)" > /tmp/swarm_join_info.txt
        log "Docker Swarm initialized on manager node $MANAGER_HOSTNAME"
        return 0
    else
        print_error "Failed to initialize Docker Swarm on manager node"
        print_error "$swarm_init_output"
        return 1
    fi
}

# Join worker nodes (Step 6)
join_worker_nodes() {
    print_status "Joining worker nodes to Docker Swarm..."
    
    # Check if we have manager and worker nodes
    if [[ -z "${MANAGER_HOSTNAME:-}" ]]; then
        print_error "Manager hostname not configured"
        return 1
    fi
    
    if [[ -z "${WORKER_HOSTNAMES:-}" ]]; then
        print_warning "Worker hostnames not configured. Skipping worker node joining."
        return 0
    fi
    
    # Get the join command from manager node
    print_status "Retrieving join command from manager node..."
    local join_command
    join_command=$(ssh_execute "$MANAGER_HOSTNAME" "docker swarm join-token worker 2>/dev/null | grep -E 'docker swarm join' | head -1")
    
    if [[ -z "$join_command" ]]; then
        print_error "Failed to retrieve join command from manager node"
        return 1
    fi
    
    print_status "Join command retrieved: $join_command"
    
    # Execute join command on each worker node
    IFS=',' read -ra WORKERS <<< "$WORKER_HOSTNAMES"
    for worker in "${WORKERS[@]}"; do
        print_status "Joining worker node $worker to swarm..."
        if ssh_execute "$worker" "$join_command"; then
            print_status "Worker node $worker successfully joined to swarm"
        else
            print_error "Failed to join worker node $worker to swarm"
            return 1
        fi
    done
    
    print_status "All worker nodes joined to Docker Swarm"
    return 0
}

# Deploy fine-tuning stack (Step 6 continued)
deploy_stack() {
    print_status "Deploying fine-tuning stack..."
    
    # Check if required files exist locally
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
    
    # Make entrypoint executable locally
    chmod +x "$entrypoint_file"
    
    # Deploy stack on manager node
    print_status "Deploying fine-tuning multi-node stack on manager node..."
    if ssh_execute "$MANAGER_HOSTNAME" "cd $(dirname "$compose_file") && chmod +x $entrypoint_file && docker stack deploy -c $compose_file finetuning-multinode"; then
        print_status "Fine-tuning stack deployed successfully on manager node"
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
    
    # Get container ID from manager node
    local container_id
    container_id=$(ssh_execute "$MANAGER_HOSTNAME" "docker ps -q -f name=finetuning-multinode")
    
    if [[ -z "$container_id" ]]; then
        print_warning "No running finetuning-multinode containers found on manager node"
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
    
    # Check if we have configuration files locally
    local config_files=("$PWD/config_finetuning.yaml" "$PWD/config_fsdp_lora.yaml")
    local found_configs=false
    
    for config_file in "${config_files[@]}"; do
        if [[ -f "$config_file" ]]; then
            found_configs=true
            print_status "Found configuration file: $config_file"
        fi
    done
    
    if [[ "$found_configs" == false ]]; then
        print_warning "No configuration files found locally. You need to download them first."
        return 1
    fi
    
    # Get manager IP
    local manager_ip=""
    manager_ip=$(ssh_execute "$MANAGER_HOSTNAME" "hostname -I | awk '{print \$1}'")
    
    if [[ -z "$manager_ip" ]]; then
        print_warning "Could not determine manager IP address. Please set main_process_ip manually."
        return 1
    fi
    
    print_status "Manager IP: $manager_ip"
    
    # Set default port
    local port=29500
    
    # Adapt each config file
    for config_file in "${config_files[@]}"; do
        if [[ -f "$config_file" ]]; then
            print_status "Adapting $config_file..."
            
            # Determine machine rank based on hostname
            local machine_rank=0  # Manager node is rank 0
            
            # If we're not on manager node, determine rank based on hostname
            if [[ "$HOSTNAME" != "$MANAGER_HOSTNAME" ]]; then
                # If we have a list of workers, check if current node is one of them
                IFS=',' read -ra WORKERS <<< "$WORKER_HOSTNAMES"
                for i in "${!WORKERS[@]}"; do
                    if [[ "$HOSTNAME" == "${WORKERS[i]}" ]]; then
                        machine_rank=$((i + 1))
                        break
                    fi
                done
            fi
            
            print_status "Setting machine_rank: $machine_rank"
            print_status "Setting main_process_ip: $manager_ip"
            print_status "Setting main_process_port: $port"
            
            # Create backup
            cp "$config_file" "${config_file}.backup"
            
            # Update config file
            sed -i "s/machine_rank: .*/machine_rank: $machine_rank/" "$config_file"
            sed -i "s/main_process_ip: .*/main_process_ip: $manager_ip/" "$config_file"
            sed -i "s/main_process_port: .*/main_process_port: $port/" "$config_file"
            
            print_status "Configuration file $config_file adapted successfully"
        fi
    done
    
    print_status "All configuration files adapted"
    return 0
}

# Run fine-tuning scripts (Step 9)
run_finetune() {
    print_status "Running fine-tuning scripts..."
    
    # Check if container ID exists
    local container_id
    container_id=$(ssh_execute "$MANAGER_HOSTNAME" "docker ps -q -f name=finetuning-multinode")
    
    if [[ -z "$container_id" ]]; then
        print_error "No running container found. Please run 'find_container_id' first."
        return 1
    fi
    
    # Check if HuggingFace token is set
    if [[ -z "${HF_TOKEN:-}" ]]; then
        print_error "HuggingFace token not configured"
        return 1
    fi
    
    # Check which script to run
    print_status "Selecting fine-tuning script..."
    local script_to_run=""
    local config_file=""
    
    if [[ -f "$PWD/config_fsdp_lora.yaml" ]]; then
        script_to_run="/workspace/Llama3_70B_LoRA_finetuning.py"
        config_file="/workspace/configs/config_fsdp_lora.yaml"
        print_status "Using FSDP LoRA configuration for 70B model"
    elif [[ -f "$PWD/config_finetuning.yaml" ]]; then
        script_to_run="/workspace/Llama3_3B_finetuning.py"
        config_file="/workspace/configs/config_finetuning.yaml"
        print_status "Using full fine-tuning configuration for 3B model"
    else
        print_warning "No known configuration file found. Please ensure your scripts are in the container."
        script_to_run="/workspace/Llama3_70B_LoRA_finetuning.py"
        config_file="/workspace/configs/config_fsdp_lora.yaml"
    fi
    
    # Run the fine-tuning command
    print_status "Running fine-tuning script with container: $container_id"
    print_status "Using script: $script_to_run"
    print_status "Using config: $config_file"
    
    # Execute the command in the container
    local fine_tune_cmd="docker exec -e HF_TOKEN=$HF_TOKEN -it $container_id bash -c 'bash /workspace/install-requirements && accelerate launch --config_file=$config_file $script_to_run'"
    
    print_status "Executing fine-tuning command..."
    print_status "This will run in the background. Monitor the logs on the manager node."
    
    # Run in background to avoid hanging
    ssh_execute "$MANAGER_HOSTNAME" "$fine_tune_cmd" &
    
    print_status "Fine-tuning started in background. Check container logs for progress."
    print_status "You can monitor the process using: docker logs -f <container_id>"
    
    return 0
}

# Cleanup and rollback (Step 10)
cleanup() {
    print_status "Cleaning up and rolling back..."
    
    # Remove containers from manager node
    print_status "Removing fine-tuning stack from manager node..."
    if ssh_execute "$MANAGER_HOSTNAME" "docker stack rm finetuning-multinode"; then
        print_status "Fine-tuning stack removed from manager node"
    else
        print_warning "Failed to remove fine-tuning stack from manager node"
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
            gather_config
            configure_network
            ;;
        docker)
            verify_requirements
            configure_docker_permissions
            ;;
        resources)
            verify_requirements
            gather_config
            enable_resource_advertising
            ;;
        swarm)
            verify_requirements
            gather_config
            initialize_swarm
            ;;
        join)
            verify_requirements
            gather_config
            join_worker_nodes
            ;;
        deploy)
            verify_requirements
            gather_config
            deploy_stack
            ;;
        finetune)
            verify_requirements
            gather_config
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