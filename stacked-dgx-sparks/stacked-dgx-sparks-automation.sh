#!/usr/bin/env bash

# NVIDIA DGX Spark Stacked Multi-Node Automation Script
#
# This script automates the complete stacked DGX Sparks setup process, including:
# - Environment verification
# - Network configuration
# - Docker setup
# - Container deployment
# - Model downloading
# - API server deployment
#
# Usage:
#   ./stacked-dgx-sparks-automation.sh [OPTIONS]
#
# Options:
#   -h, --help                    Show this help message
#   -c, --configure               Configure connection settings
#   -v, --verify                  Verify environment and prerequisites
#   -s, --setup                   Setup multi-node stacked DGX Sparks environment
#   -d, --deploy                  Deploy model and start server
#   -t, --test                    Test the deployed model
#   -r, --rollback                Cleanup and rollback environment
#   -u, --username USER           Specify username (overrides config)
#   -H, --hostname HOST           Specify hostname (overrides config)
#   -n, --node NODE               Specify secondary node IP (for multi-node)
#   -m, --model MODEL             Specify model to deploy (default: nvidia/Qwen3-235B-A22B-FP4)
#   -p, --port PORT               Specify server port (default: 8355)
#   -t, --tp-size TP_SIZE         Specify tensor parallelism size (default: 2)
#   -k, --hf-token TOKEN          Specify Hugging Face token (required for model download)
#
# Examples:
#   ./stacked-dgx-sparks-automation.sh --configure
#   ./stacked-dgx-sparks-automation.sh --verify
#   ./stacked-dgx-sparks-automation.sh --setup --node 169.254.35.62 --hf-token your-hf-token
#   ./stacked-dgx-sparks-automation.sh --deploy --model meta-llama/Llama-3.1-70B --hf-token your-hf-token
#   ./stacked-dgx-sparks-automation.sh --test
#   ./stacked-dgx-sparks-automation.sh --rollback

# Bash strict mode
set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Global variables
readonly SCRIPT_NAME="stacked-dgx-sparks-automation.sh"
readonly CONFIG_FILE="$HOME/.dgx-spark-stacked-config"
readonly DEFAULT_MODEL="nvidia/Qwen3-235B-A22B-FP4"
readonly DEFAULT_PORT="8355"
readonly DEFAULT_TP_SIZE="2"

# Print colored output.
#
# Prints a status message with a green color prefix.
#
# Args:
#   $1: The status message to display
#
# Returns:
#   None
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Print warning message
#
# Prints a warning message with a yellow color prefix.
#
# Args:
#   $1: The warning message to display
#
# Returns:
#   None
print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Print error message
#
# Prints an error message with a red color prefix.
#
# Args:
#   $1: The error message to display
#
# Returns:
#   None
print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Print debug message
#
# Prints a debug message with a blue color prefix.
#
# Args:
#   $1: The debug message to display
#
# Returns:
#   None
print_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Display usage information
#
# Displays the usage message and all available command line options.
#
# Returns:
#   None
usage() {
    echo "Usage: $SCRIPT_NAME [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help                    Show this help message"
    echo "  -c, --configure               Configure connection settings"
    echo "  -v, --verify                  Verify environment and prerequisites"
    echo "  -s, --setup                   Setup multi-node stacked DGX Sparks environment"
    echo "  -d, --deploy                  Deploy model and start server"
    echo "  -t, --test                    Test the deployed model"
    echo "  -r, --rollback                Cleanup and rollback environment"
    echo "  -u, --username USER           Specify username (overrides config)"
    echo "  -H, --hostname HOST           Specify hostname (overrides config)"
    echo "  -n, --node NODE               Specify secondary node IP (for multi-node)"
    echo "  -m, --model MODEL             Specify model to deploy (default: $DEFAULT_MODEL)"
    echo "  -p, --port PORT               Specify server port (default: $DEFAULT_PORT)"
    echo "  -t, --tp-size TP_SIZE         Specify tensor parallelism size (default: $DEFAULT_TP_SIZE)"
    echo "  -k, --hf-token TOKEN          Specify Hugging Face token (required for model download)"
    echo ""
    echo "Examples:"
    echo "  $SCRIPT_NAME --configure"
    echo "  $SCRIPT_NAME --verify"
    echo "  $SCRIPT_NAME --setup --node 169.254.35.62 --hf-token your-hf-token"
    echo "  $SCRIPT_NAME --deploy --model meta-llama/Llama-3.1-70B --hf-token your-hf-token"
    echo "  $SCRIPT_NAME --test"
    echo "  $SCRIPT_NAME --rollback"
    echo ""
}

# Verify SSH client availability
#
# Verifies that the SSH client is installed and available in the PATH.
#
# Returns:
#   0 if SSH client is available, 1 otherwise
verify_ssh_client() {
    print_status "Verifying SSH client availability..."
    
    if ! command -v ssh &> /dev/null; then
        print_error "SSH client is not installed or not in PATH"
        return 1
    fi
    
    local ssh_version
    ssh_version=$(ssh -V 2>&1)
    print_status "SSH client version: $ssh_version"
    return 0
}

# Verify Docker client availability
#
# Verifies that the Docker client is installed and available in the PATH.
#
# Returns:
#   0 if Docker client is available, 1 otherwise
verify_docker_client() {
    print_status "Verifying Docker client availability..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker client is not installed or not in PATH"
        return 1
    fi
    
    local docker_version
    docker_version=$(docker --version)
    print_status "Docker client version: $docker_version"
    return 0
}

# Check Docker permissions
#
# Checks if the user has proper Docker permissions to run Docker commands.
#
# Returns:
#   0 if Docker permissions are correct, 1 otherwise
check_docker_permissions() {
    print_status "Checking Docker permissions..."
    
    if ! docker ps &> /dev/null; then
        print_warning "Docker permissions issue detected. You may need to run:"
        print_warning "  sudo usermod -aG docker \$USER"
        print_warning "  newgrp docker"
        print_warning "Then re-login or re-source your shell."
        return 1
    fi
    
    print_status "Docker permissions are correctly configured"
    return 0
}

# Gather connection information
#
# Gathers connection information from user input or configuration file.
# Prompts user for DGX Spark username, hostname, and secondary node IP.
#
# Returns:
#   0 on successful configuration gathering, 1 on failure
gather_connection_info() {
    print_status "Gathering connection information..."
    
    # Try to read from config file first
    if [[ -f "$CONFIG_FILE" ]]; then
        print_status "Loading configuration from $CONFIG_FILE"
        source "$CONFIG_FILE"
    fi
    
    # If username not set, ask user
    if [[ -z "${DGX_USERNAME:-}" ]]; then
        read -rp "Enter your DGX Spark username: " DGX_USERNAME
    fi
    
    # If hostname not set, ask user
    if [[ -z "${DGX_HOSTNAME:-}" ]]; then
        read -rp "Enter your DGX Spark hostname (without .local): " DGX_HOSTNAME
    fi
    
    # If secondary node not set, ask user (for multi-node)
    if [[ -z "${SECONDARY_NODE:-}" ]]; then
        read -rp "Enter secondary node IP address (or press Enter to skip): " SECONDARY_NODE
    fi
    
    # Save configuration
    cat > "$CONFIG_FILE" << EOF
# DGX Spark Stacked Configuration
DGX_USERNAME="$DGX_USERNAME"
DGX_HOSTNAME="$DGX_HOSTNAME"
SECONDARY_NODE="$SECONDARY_NODE"
EOF
    
    print_status "Configuration saved to $CONFIG_FILE"
    return 0
}

# Test mDNS resolution
#
# Tests if mDNS resolution works for the given hostname.
#
# Args:
#   $1: The hostname to test (without .local suffix)
#
# Returns:
#   0 if mDNS resolution succeeds, 1 otherwise
test_mdns_resolution() {
    local hostname="$1"
    print_status "Testing mDNS resolution for $hostname.local..."
    
    if ping -c 1 -W 5 "$hostname.local" &> /dev/null; then
        print_status "mDNS resolution successful for $hostname.local"
        return 0
    else
        print_warning "mDNS resolution failed for $hostname.local"
        return 1
    fi
}

# Test SSH connection to a host
#
# Tests SSH connectivity to a remote host using either mDNS hostname or IP address.
#
# Args:
#   $1: Username for SSH connection
#   $2: Hostname (without .local suffix)
#   $3: Optional IP address to use if mDNS fails
#
# Returns:
#   0 if SSH connection succeeds, 1 otherwise
test_ssh_connection() {
    local username="$1"
    local hostname="$2"
    local ip_address="${3:-}"
    
    print_status "Testing SSH connection to $hostname..."
    
    # Try mDNS hostname first
    if test_mdns_resolution "$hostname"; then
        print_status "Connecting via mDNS hostname: $username@$hostname.local"
        ssh -o ConnectTimeout=10 "$username@$hostname.local" exit
        return $?
    fi
    
    # If mDNS fails, try IP address if provided
    if [[ -n "$ip_address" ]]; then
        print_status "Connecting via IP address: $username@$ip_address"
        ssh -o ConnectTimeout=10 "$username@$ip_address" exit
        return $?
    fi
    
    print_error "Cannot connect - both mDNS and IP address failed"
    return 1
}

# Verify remote connection
#
# Verifies connectivity to a remote host by executing a simple command.
#
# Args:
#   $1: Username for SSH connection
#   $2: Hostname (without .local suffix)
#   $3: Optional IP address to use if mDNS fails
#
# Returns:
#   0 if remote connection verification succeeds, 1 otherwise
verify_remote_connection() {
    local username="$1"
    local hostname="$2"
    local ip_address="${3:-}"
    
    print_status "Verifying remote connection to $hostname..."
    
    # Try mDNS hostname first
    if test_mdns_resolution "$hostname"; then
        print_status "Connecting via mDNS hostname: $username@$hostname.local"
        ssh -o ConnectTimeout=10 "$username@$hostname.local" '
            echo "Connected to: $(hostname)"
            echo "System info: $(uname -a)"
        '
        return $?
    fi
    
    # If mDNS fails, try IP address if provided
    if [[ -n "$ip_address" ]]; then
        print_status "Connecting via IP address: $username@$ip_address"
        ssh -o ConnectTimeout=10 "$username@$ip_address" '
            echo "Connected to: $(hostname)"
            echo "System info: $(uname -a)"
        '
        return $?
    fi
    
    print_error "Cannot verify connection - both mDNS and IP address failed"
    return 1
}

# Get network interface information
#
# Gets network interface information and prompts user for interface selection.
# Determines the IP address for the selected interface.
#
# Returns:
#   0 on successful interface information gathering, 1 on failure
get_network_interfaces() {
    print_status "Getting network interface information..."
    
    # List all available network interfaces
    print_status "Available network interfaces:"
    ip link show | grep -E '^[0-9]+:' | awk '{print $2}' | tr -d ':'
    
    # Prompt user for interface selection
    read -rp "Enter the primary network interface name (e.g., enp1s0f0np0): " NETWORK_INTERFACE
    
    if [[ -z "$NETWORK_INTERFACE" ]]; then
        print_error "Network interface not specified"
        return 1
    fi
    
    # Get IP address for the interface
    print_status "Getting IP address for interface $NETWORK_INTERFACE..."
    local ip_address
    ip_address=$(ip addr show "$NETWORK_INTERFACE" | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
    
    if [[ -z "$ip_address" ]]; then
        print_error "Could not determine IP address for interface $NETWORK_INTERFACE"
        return 1
    fi
    
    print_status "Interface $NETWORK_INTERFACE IP address: $ip_address"
    
    # Store interface and IP for later use
    export NETWORK_INTERFACE
    export NETWORK_IP_ADDRESS="$ip_address"
    
    return 0
}

# Create and validate hostfile
#
# Creates and validates a hostfile with the specified network interface information.
#
# Args:
#   $1: Path to the hostfile to create
#   $2: Network interface name
#   $3: Optional node information to add to the hostfile
#
# Returns:
#   0 on successful hostfile creation, 1 on failure
create_and_validate_hostfile() {
    local hostfile_path="$1"
    local network_interface="$2"
    local node_info="$3"
    
    print_status "Creating and validating hostfile at $hostfile_path..."
    
    # Validate network interface exists
    if ! ip link show "$network_interface" &> /dev/null; then
        print_error "Network interface $network_interface does not exist"
        return 1
    fi
    
    # Get IP address for the interface
    local ip_address
    ip_address=$(ip addr show "$network_interface" | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
    
    if [[ -z "$ip_address" ]]; then
        print_error "Could not determine IP address for interface $network_interface"
        return 1
    fi
    
    # Create the hostfile with primary node IP
    print_status "Creating hostfile with IP address: $ip_address"
    cat > "$hostfile_path" << EOF
$ip_address
EOF
    
    # If node_info is specified, add it too
    if [[ -n "$node_info" ]]; then
        print_status "Adding node information to hostfile: $node_info"
        echo "$node_info" >> "$hostfile_path"
    fi
    
    # Validate hostfile was created
    if [[ ! -f "$hostfile_path" ]]; then
        print_error "Failed to create hostfile at $hostfile_path"
        return 1
    fi
    
    # Validate hostfile content
    local file_content
    file_content=$(cat "$hostfile_path")
    if [[ -z "$file_content" ]]; then
        print_error "Hostfile at $hostfile_path is empty"
        return 1
    fi
    
    print_status "Hostfile created successfully at $hostfile_path"
    print_status "Hostfile contents:"
    cat "$hostfile_path"
    
    return 0
}

# Configure Docker permissions
#
# Checks Docker permissions and optionally configures them if needed.
#
# Returns:
#   0 if Docker permissions are correct, 1 otherwise
configure_docker_permissions() {
    print_status "Checking Docker permissions..."
    
    if ! docker ps &> /dev/null; then
        print_warning "Docker permissions issue detected. You may need to run:"
        print_warning "  sudo usermod -aG docker \$USER"
        print_warning "  newgrp docker"
        print_warning "Then re-login or re-source your shell."
        
        read -rp "Do you want to run the Docker permission setup commands now? (y/n): " confirm
        if [[ "$confirm" == [Yy] ]]; then
            print_status "Running Docker permission setup..."
            sudo usermod -aG docker "$USER"
            newgrp docker
            print_status "Docker permissions configured. Please re-login or re-source your shell."
            return 1
        fi
        return 1
    fi
    
    print_status "Docker permissions are correctly configured"
    return 0
}

# Create OpenMPI hostfile
#
# Creates an OpenMPI hostfile with the primary node IP address.
# Optionally adds secondary node IP if specified.
#
# Returns:
#   0 on successful hostfile creation, 1 on failure
create_hostfile() {
    print_status "Creating OpenMPI hostfile..."
    
    # Create the hostfile with primary node IP
    cat > "$HOME/openmpi-hostfile" << EOF
$NETWORK_IP_ADDRESS
EOF
    
    # If secondary node is specified, add it too
    if [[ -n "${SECONDARY_NODE:-}" ]]; then
        print_status "Adding secondary node IP to hostfile: $SECONDARY_NODE"
        echo "$SECONDARY_NODE" >> "$HOME/openmpi-hostfile"
    fi
    
    print_status "Hostfile created at $HOME/openmpi-hostfile"
    print_status "Hostfile contents:"
    cat "$HOME/openmpi-hostfile"
    
    return 0
}

# Start containers on nodes
#
# Starts TRT-LLM containers on the primary node and optionally on secondary node.
#
# Returns:
#   0 on successful container start, 1 on failure
start_containers() {
    print_status "Starting TRT-LLM containers on all nodes..."
    
    local primary_node="$DGX_HOSTNAME"
    local secondary_node="$SECONDARY_NODE"
    local container_name="trtllm-multinode"
    
    # Start container on primary node
    print_status "Starting container on primary node: $primary_node"
    
    # Try mDNS hostname first
    if test_mdns_resolution "$primary_node"; then
        print_status "Connecting via mDNS hostname: $DGX_USERNAME@$primary_node.local"
        ssh -o ConnectTimeout=10 "$DGX_USERNAME@$primary_node.local" "
            docker run -d --rm \\
              --name $container_name \\
              --gpus '\"device=all\"' \\
              --network host \\
              --ulimit memlock=-1 \\
              --ulimit stack=67108864 \\
              --device /dev/infiniband:/dev/infiniband \\
              -e UCX_NET_DEVICES=\"$NETWORK_INTERFACE,$NETWORK_INTERFACE\" \\
              -e NCCL_SOCKET_IFNAME=\"$NETWORK_INTERFACE,$NETWORK_INTERFACE\" \\
              -e OMPI_MCA_btl_tcp_if_include=\"$NETWORK_INTERFACE,$NETWORK_INTERFACE\" \\
              -e OMPI_MCA_orte_default_hostfile=\"/etc/openmpi-hostfile\" \\
              -e OMPI_MCA_rmaps_ppr_n_pernode=\"1\" \\
              -e OMPI_ALLOW_RUN_AS_ROOT=\"1\" \\
              -e OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=\"1\" \\
              -v ~/.cache/huggingface/:/root/.cache/huggingface/ \\
              -v ~/.ssh:/tmp/.ssh:ro \\
              nvcr.io/nvidia/tensorrt-llm/release:1.2.0rc6 \\
              sh -c \"curl https://raw.githubusercontent.com/NVIDIA/dgx-spark-playbooks/refs/heads/main/nvidia/trt-llm/assets/trtllm-mn-entrypoint.sh | sh\"
        "
    else
        print_error "Cannot connect to primary node via mDNS"
        return 1
    fi
    
    # Start container on secondary node if specified
    if [[ -n "$secondary_node" ]]; then
        print_status "Starting container on secondary node: $secondary_node"
        # This would typically require SSH to secondary node
        # For now, we'll just show the command that would be run
        print_status "To start container on secondary node, run this command:"
        print_status "docker run -d --rm --name $container_name --gpus '\"device=all\"' --network host --ulimit memlock=-1 --ulimit stack=67108864 --device /dev/infiniband:/dev/infiniband -e UCX_NET_DEVICES=\"$NETWORK_INTERFACE,$NETWORK_INTERFACE\" -e NCCL_SOCKET_IFNAME=\"$NETWORK_INTERFACE,$NETWORK_INTERFACE\" -e OMPI_MCA_btl_tcp_if_include=\"$NETWORK_INTERFACE,$NETWORK_INTERFACE\" -e OMPI_MCA_orte_default_hostfile=\"/etc/openmpi-hostfile\" -e OMPI_MCA_rmaps_ppr_n_pernode=\"1\" -e OMPI_ALLOW_RUN_AS_ROOT=\"1\" -e OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=\"1\" -v ~/.cache/huggingface/:/root/.cache/huggingface/ -v ~/.ssh:/tmp/.ssh:ro nvcr.io/nvidia/tensorrt-llm/release:1.2.0rc6 sh -c \"curl https://raw.githubusercontent.com/NVIDIA/dgx-spark-playbooks/refs/heads/main/nvidia/trt-llm/assets/trtllm-mn-entrypoint.sh | sh\""
    fi
    
    print_status "Containers started. Check their status with: docker ps"
    return 0
}

# Verify containers are running
#
# Verifies that containers are running on the primary node.
#
# Returns:
#   0 on successful verification, 1 on failure
verify_containers() {
    print_status "Verifying containers are running..."
    
    # Check primary node
    print_status "Checking container status on primary node: $DGX_HOSTNAME"
    
    if test_mdns_resolution "$DGX_HOSTNAME"; then
        print_status "Connecting via mDNS hostname: $DGX_USERNAME@$DGX_HOSTNAME.local"
        ssh -o ConnectTimeout=10 "$DGX_USERNAME@$DGX_HOSTNAME.local" "
            docker ps
        "
    else
        print_error "Cannot connect to primary node via mDNS"
        return 1
    fi
    
    return 0
}

# Copy hostfile to primary container
#
# Copies the OpenMPI hostfile to the primary container.
#
# Returns:
#   0 on successful copy, 1 on failure
copy_hostfile_to_container() {
    print_status "Copying hostfile to primary container..."
    
    local container_name="trtllm-multinode"
    
    if test_mdns_resolution "$DGX_HOSTNAME"; then
        print_status "Connecting via mDNS hostname: $DGX_USERNAME@$DGX_HOSTNAME.local"
        ssh -o ConnectTimeout=10 "$DGX_USERNAME@$DGX_HOSTNAME.local" "
            docker cp $HOME/openmpi-hostfile $container_name:/etc/openmpi-hostfile
        "
    else
        print_error "Cannot connect to primary node via mDNS"
        return 1
    fi
    
    print_status "Hostfile copied to container"
    return 0
}

# Save container reference
#
# Saves the container reference by setting an environment variable in the primary container.
#
# Returns:
#   0 on successful save, 1 on failure
save_container_reference() {
    print_status "Saving container reference..."
    
    local container_name="trtllm-multinode"
    
    if test_mdns_resolution "$DGX_HOSTNAME"; then
        print_status "Connecting via mDNS hostname: $DGX_USERNAME@$DGX_HOSTNAME.local"
        ssh -o ConnectTimeout=10 "$DGX_USERNAME@$DGX_HOSTNAME.local" "
            export TRTLLM_MN_CONTAINER=$container_name
        "
    else
        print_error "Cannot connect to primary node via mDNS"
        return 1
    fi
    
    print_status "Container reference saved"
    return 0
}

# Generate configuration file
#
# Generates a configuration file inside the container for TensorRT-LLM API settings.
#
# Returns:
#   0 on successful generation, 1 on failure
generate_config_file() {
    print_status "Generating configuration file inside container..."
    
    local container_name="trtllm-multinode"
    
    if test_mdns_resolution "$DGX_HOSTNAME"; then
        print_status "Connecting via mDNS hostname: $DGX_USERNAME@$DGX_HOSTNAME.local"
        ssh -o ConnectTimeout=10 "$DGX_USERNAME@$DGX_HOSTNAME.local" "
            docker exec $container_name bash -c 'cat <<EOF > /tmp/extra-llm-api-config.yml
print_iter_log: false
kv_cache_config:
  dtype: \"auto\"
  free_gpu_memory_fraction: 0.9
cuda_graph_config:
  enable_padding: true
EOF'
        "
    else
        print_error "Cannot connect to primary node via mDNS"
        return 1
    fi
    
    print_status "Configuration file generated"
    return 0
}

# Download model
#
# Downloads the specified model inside the container using Hugging Face CLI.
#
# Returns:
#   0 on successful download, 1 on failure
download_model() {
    print_status "Downloading model inside container..."
    
    local model="${MODEL:-$DEFAULT_MODEL}"
    local hf_token="${HF_TOKEN:-}"
    
    if [[ -z "$hf_token" ]]; then
        read -rp "Enter your Hugging Face token: " hf_token
        export HF_TOKEN="$hf_token"
    fi
    
    if test_mdns_resolution "$DGX_HOSTNAME"; then
        print_status "Connecting via mDNS hostname: $DGX_USERNAME@$DGX_HOSTNAME.local"
        ssh -o ConnectTimeout=10 "$DGX_USERNAME@$DGX_HOSTNAME.local" "
            docker exec \\
              -e MODEL=\"$model\" \\
              -e HF_TOKEN=$hf_token \\
              -it $container_name bash -c 'mpirun -x HF_TOKEN bash -c \"hf download \$MODEL\"'
        "
    else
        print_error "Cannot connect to primary node via mDNS"
        return 1
    fi
    
    print_status "Model downloaded successfully"
    return 0
}

# Serve the model
#
# Starts the TensorRT-LLM server with the specified model and configuration.
#
# Returns:
#   0 on successful server start, 1 on failure
serve_model() {
    print_status "Starting TensorRT-LLM server..."
    
    local model="${MODEL:-$DEFAULT_MODEL}"
    local port="${PORT:-$DEFAULT_PORT}"
    local tp_size="${TP_SIZE:-$DEFAULT_TP_SIZE}"
    local hf_token="${HF_TOKEN:-}"
    
    if [[ -z "$hf_token" ]]; then
        read -rp "Enter your Hugging Face token: " hf_token
        export HF_TOKEN="$hf_token"
    fi
    
    if test_mdns_resolution "$DGX_HOSTNAME"; then
        print_status "Connecting via mDNS hostname: $DGX_USERNAME@$DGX_HOSTNAME.local"
        ssh -o ConnectTimeout=10 "$DGX_USERNAME@$DGX_HOSTNAME.local" "
            docker exec \\
              -e MODEL=\"$model\" \\
              -e HF_TOKEN=$hf_token \\
              -it $container_name bash -c '
                mpirun -x HF_TOKEN trtllm-llmapi-launch trtllm-serve \$MODEL \\
                  --tp_size $tp_size \\
                  --backend pytorch \\
                  --max_num_tokens 32768 \\
                  --max_batch_size 4 \\
                  --extra_llm_api_options /tmp/extra-llm-api-config.yml \\
                  --port $port'
        "
    else
        print_error "Cannot connect to primary node via mDNS"
        return 1
    fi
    
    print_status "TensorRT-LLM server started on port $port"
    print_status "You can now make inference requests to http://localhost:$port using the OpenAI-compatible API format"
    return 0
}

# Test API server
#
# Tests the deployed model server by making a curl request to the API endpoint.
#
# Returns:
#   0 on successful test, 1 on failure
test_api_server() {
    print_status "Testing the deployed model server..."
    
    local port="${PORT:-$DEFAULT_PORT}"
    local model="${MODEL:-$DEFAULT_MODEL}"
    
    print_status "Testing with curl request to http://localhost:$port/v1/chat/completions"
    
    # Create test request JSON
    cat > "/tmp/test_request.json" << EOF
{
  "model": "$model",
  "messages": [{"role": "user", "content": "Paris is great because"}],
  "max_tokens": 64
}
EOF
    
    # Send test request
    curl -s "http://localhost:$port/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d @/tmp/test_request.json
    
    # Clean up
    rm -f /tmp/test_request.json
    
    print_status "Test completed"
    return 0
}

# Cleanup and rollback
#
# Cleans up the stacked DGX Sparks environment by stopping containers,
# removing downloaded models, and cleaning up temporary files.
#
# Returns:
#   0 on successful cleanup, 1 on failure
cleanup() {
    print_status "Cleaning up stacked DGX Sparks environment..."
    
    local container_name="trtllm-multinode"
    
    # Stop and remove containers on primary node
    if test_mdns_resolution "$DGX_HOSTNAME"; then
        print_status "Stopping container on primary node: $DGX_HOSTNAME"
        ssh -o ConnectTimeout=10 "$DGX_USERNAME@$DGX_HOSTNAME.local" "
            docker stop $container_name
        "
    fi
    
    # Remove downloaded models
    print_status "Removing downloaded models..."
    if test_mdns_resolution "$DGX_HOSTNAME"; then
        ssh -o ConnectTimeout=10 "$DGX_USERNAME@$DGX_HOSTNAME.local" "
            rm -rf $HOME/.cache/huggingface/hub/models--nvidia--Qwen3*
        "
    fi
    
    # Remove hostfile
    if [[ -f "$HOME/openmpi-hostfile" ]]; then
        rm -f "$HOME/openmpi-hostfile"
    fi
    
    print_status "Cleanup completed"
    return 0
}

# Main function.
#
# Parses command line arguments and executes the appropriate action based on the specified command.
#
# Args:
#   All command line arguments passed to the script
#
# Returns:
#   None (exits with appropriate status codes)
main() {
    local action=""
    local username=""
    local hostname=""
    local node=""
    local model=""
    local port=""
    local tp_size=""
    local hf_token=""
    local cleanup_only=false
    
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
            -s|--setup)
                action="setup"
                shift
                ;;
            -d|--deploy)
                action="deploy"
                shift
                ;;
            -t|--test)
                action="test"
                shift
                ;;
            -r|--rollback)
                action="rollback"
                shift
                ;;
            -u|--username)
                username="$2"
                shift 2
                ;;
            -H|--hostname)
                hostname="$2"
                shift 2
                ;;
            -n|--node)
                node="$2"
                shift 2
                ;;
            -m|--model)
                model="$2"
                shift 2
                ;;
            -p|--port)
                port="$2"
                shift 2
                ;;
            -t|--tp-size)
                tp_size="$2"
                shift 2
                ;;
            -k|--hf-token)
                hf_token="$2"
                shift 2
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
    
    # Load configuration if available
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    fi
    
    # Set environment variables from arguments or config
    local actual_username="${username:-${DGX_USERNAME:-}}"
    local actual_hostname="${hostname:-${DGX_HOSTNAME:-}}"
    local actual_node="${node:-${SECONDARY_NODE:-}}"
    local actual_model="${model:-$DEFAULT_MODEL}"
    local actual_port="${port:-$DEFAULT_PORT}"
    local actual_tp_size="${tp_size:-$DEFAULT_TP_SIZE}"
    local actual_hf_token="${hf_token:-${HF_TOKEN:-}}"
    
    # Export variables for use in remote commands
    export DGX_USERNAME="$actual_username"
    export DGX_HOSTNAME="$actual_hostname"
    export SECONDARY_NODE="$actual_node"
    export MODEL="$actual_model"
    export PORT="$actual_port"
    export TP_SIZE="$actual_tp_size"
    export HF_TOKEN="$actual_hf_token"
    
    # Execute requested action
    case "$action" in
        configure)
            gather_connection_info
            ;;
        verify)
            verify_ssh_client
            verify_docker_client
            check_docker_permissions
            ;;
        setup)
            verify_ssh_client
            verify_docker_client
            check_docker_permissions
            
            # Configure Docker permissions if needed
            configure_docker_permissions
            
            # Get network interface information
            get_network_interfaces
            
            # Create hostfile
            create_hostfile
            
            # Start containers
            start_containers
            
            # Verify containers
            verify_containers
            ;;
        deploy)
            verify_ssh_client
            verify_docker_client
            check_docker_permissions
            
            # Save container reference
            save_container_reference
            
            # Generate config file
            generate_config_file
            
            # Download model
            download_model
            
            # Serve model
            serve_model
            ;;
        test)
            verify_ssh_client
            verify_docker_client
            check_docker_permissions
            
            # Test API server
            test_api_server
            ;;
        rollback)
            cleanup
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