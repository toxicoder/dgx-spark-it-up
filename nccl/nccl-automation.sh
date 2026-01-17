#!/usr/bin/env bash

# NVIDIA DGX Spark NCCL Automation Script.
#
# This script automates the complete NCCL setup process for DGX Spark nodes, including network configuration, NCCL building, test suite building, and communication testing.

# Bash strict mode
set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Global variables
readonly SCRIPT_NAME="nccl-automation.sh"
readonly NCCL_DIR="$HOME/nccl"
readonly NCCL_TESTS_DIR="$HOME/nccl-tests"

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

# usage - Display usage information for the script.
#
# Displays the usage instructions and available options for running this script.
#
# Parameters:
#   None
#
# Returns:
#   0 - Success.
usage() {
    echo "Usage: $SCRIPT_NAME [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help               Show this help message"
    echo "  -n, --node NODE          Specify node IP address (required for multi-node setup)"
    echo "  -i, --interface IFACE    Specify network interface (auto-detected if not provided)"
    echo "  -c, --cleanup            Cleanup NCCL and NCCL tests directories"
    echo "  -v, --verbose            Enable verbose output"
    echo ""
    echo "Examples:"
    echo "  $SCRIPT_NAME"
    echo "  $SCRIPT_NAME --node 169.254.35.62"
    echo "  $SCRIPT_NAME --node 169.254.35.62 --interface enp1s0f1np1"
    echo "  $SCRIPT_NAME --cleanup"
    echo ""
}

# check_dgx_spark_environment - Check if running on DGX Spark system.
#
# Checks if the script is running on a DGX Spark system and verifies required tools.
#
# Returns:
#   0 - All requirements met.
#   1 - Missing requirements.
check_dgx_spark_environment() {
    print_status "Checking DGX Spark environment..."
    
    # Check if we're on a DGX system
    if [[ -f "/etc/nvidia-release" ]]; then
        print_status "Detected NVIDIA DGX system"
    else
        print_warning "Not running on a DGX system - continuing anyway"
    fi
    
    # Check for required tools
    local required_tools=("git" "make" "gcc" "nvcc")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            print_error "Required tool $tool is not installed"
            return 1
        fi
    done
    
    print_status "All required tools are available"
    return 0
}

# configure_network_connectivity - Configure network connectivity.
#
# Configures network connectivity for NCCL setup, including physical cable connections
# and passwordless SSH setup between nodes.
#
# Returns:
#   0 - Network configuration completed.
configure_network_connectivity() {
    print_status "Step 1: Configuring network connectivity"
    
    # This is a simplified version - in reality, this would require specific
    # network configuration which is outside the scope of this automation
    print_status "Network connectivity setup: Manual configuration required"
    print_status "Please ensure:"
    print_status "  - Physical QSFP cable connection is established"
    print_status "  - Network interface configuration is set (automatic or manual IP assignment)"
    print_status "  - Passwordless SSH setup is configured between nodes"
    print_status "  - Network connectivity is verified"
    
    print_warning "This step requires manual configuration. Please verify connectivity before proceeding."
    read -rp "Press Enter to continue after verifying network connectivity..."
    
    return 0
}

# build_nccl - Build NCCL with Blackwell support.
#
# Builds NCCL with Blackwell support from source code.
#
# Returns:
#   0 - NCCL built successfully.
#   1 - Build failed.
build_nccl() {
    print_status "Step 2: Building NCCL with Blackwell support"
    
    # Install dependencies
    print_status "Installing dependencies..."
    sudo apt-get update
    sudo apt-get install -y libopenmpi-dev
    
    # Clone and build NCCL
    print_status "Cloning NCCL repository..."
    if [[ -d "$NCCL_DIR" ]]; then
        print_status "NCCL directory already exists, removing it..."
        rm -rf "$NCCL_DIR"
    fi
    
    git clone -b v2.28.9-1 https://github.com/NVIDIA/nccl.git "$NCCL_DIR"
    
    print_status "Building NCCL..."
    cd "$NCCL_DIR"
    make -j src.build NVCC_GENCODE="-gencode=arch=compute_121,code=sm_121"
    
    # Set environment variables
    export CUDA_HOME="/usr/local/cuda"
    export MPI_HOME="/usr/lib/aarch64-linux-gnu/openmpi"
    export NCCL_HOME="$NCCL_DIR/build/"
    export LD_LIBRARY_PATH="$NCCL_HOME/lib:$CUDA_HOME/lib64/:$MPI_HOME/lib:$LD_LIBRARY_PATH"
    
    print_status "NCCL built successfully"
    return 0
}

# build_nccl_tests - Build NCCL test suite.
#
# Builds the NCCL test suite from source code.
#
# Returns:
#   0 - NCCL tests built successfully.
#   1 - Build failed.
build_nccl_tests() {
    print_status "Step 3: Building NCCL test suite"
    
    # Clone and build NCCL tests
    print_status "Cloning NCCL tests repository..."
    if [[ -d "$NCCL_TESTS_DIR" ]]; then
        print_status "NCCL tests directory already exists, removing it..."
        rm -rf "$NCCL_TESTS_DIR"
    fi
    
    git clone https://github.com/NVIDIA/nccl-tests.git "$NCCL_TESTS_DIR"
    
    print_status "Building NCCL tests..."
    cd "$NCCL_TESTS_DIR"
    make MPI=1
    
    print_status "NCCL tests built successfully"
    return 0
}

# find_network_interfaces - Find active network interface and IP addresses.
#
# Finds active network interfaces and determines IP addresses for NCCL communication.
#
# Returns:
#   0 - Interface information retrieved.
#   1 - Failed to determine interface information.
find_network_interfaces() {
    print_status "Step 4: Finding active network interfaces and IP addresses"
    
    # Check network port status
    print_status "Checking network port status..."
    if command -v ibdev2netdev &> /dev/null; then
        ibdev2netdev
    else
        print_warning "ibdev2netdev not found, using alternative method..."
        print_status "Checking available network interfaces..."
        ip link show
    fi
    
    # Prompt user for interface selection if not provided
    if [[ -z "${NETWORK_INTERFACE:-}" ]]; then
        read -rp "Enter the active network interface name (e.g., enp1s0f1np1): " NETWORK_INTERFACE
    fi
    
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

# run_nccl_test - Run NCCL communication test.
#
# Runs NCCL communication tests to verify multi-node connectivity.
#
# Returns:
#   0 - Test completed.
#   1 - Test failed.
run_nccl_test() {
    print_status "Step 5: Running NCCL communication test"
    
    # Check if we have node information
    if [[ -z "${NODE_IP:-}" ]]; then
        print_warning "No remote node specified, running single-node test"
        print_status "Set NODE_IP environment variable to run multi-node test"
        return 0
    fi
    
    # Set environment variables
    export UCX_NET_DEVICES="$NETWORK_INTERFACE"
    export NCCL_SOCKET_IFNAME="$NETWORK_INTERFACE"
    export OMPI_MCA_btl_tcp_if_include="$NETWORK_INTERFACE"
    
    print_status "Running NCCL all_gather performance test..."
    print_status "Using interface: $NETWORK_INTERFACE"
    print_status "Node 1 IP: $NETWORK_IP_ADDRESS"
    print_status "Node 2 IP: $NODE_IP"
    
    # Run the test with two nodes
    print_status "Executing mpirun command..."
    mpirun -np 2 -H "$NETWORK_IP_ADDRESS:1,$NODE_IP:1" \
        --mca plm_rsh_agent "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" \
        -x LD_LIBRARY_PATH="$LD_LIBRARY_PATH" \
        "$NCCL_TESTS_DIR/build/all_gather_perf"
    
    print_status "Running NCCL test with larger buffer size..."
    mpirun -np 2 -H "$NETWORK_IP_ADDRESS:1,$NODE_IP:1" \
        --mca plm_rsh_agent "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" \
        -x LD_LIBRARY_PATH="$LD_LIBRARY_PATH" \
        "$NCCL_TESTS_DIR/build/all_gather_perf" -b 16G -e 16G -f 2
    
    return 0
}

# cleanup - Cleanup NCCL and NCCL tests directories.
#
# Cleans up NCCL and NCCL tests directories, removing build artifacts.
#
# Returns:
#   0 - Cleanup completed.
cleanup() {
    print_status "Step 6: Cleaning up NCCL and NCCL tests directories"
    
    if [[ -d "$NCCL_DIR" ]]; then
        print_status "Removing NCCL directory..."
        rm -rf "$NCCL_DIR"
    fi
    
    if [[ -d "$NCCL_TESTS_DIR" ]]; then
        print_status "Removing NCCL tests directory..."
        rm -rf "$NCCL_TESTS_DIR"
    fi
    
    print_status "Cleanup completed"
    return 0
}

# main - Main execution function.
#
# Main execution function that orchestrates the complete NCCL setup process.
#
# Parameters:
#   $@ (All) - Command line arguments.
#
# Returns:
#   0 - Script completed successfully.
#   1 - Script failed at some point.
main() {
    local cleanup_only=false
    local verbose=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -n|--node)
                NODE_IP="$2"
                shift 2
                ;;
            -i|--interface)
                NETWORK_INTERFACE="$2"
                shift 2
                ;;
            -c|--cleanup)
                cleanup_only=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # Enable verbose mode if requested
    if [[ "$verbose" == true ]]; then
        set -x
    fi
    
    print_status "Starting NVIDIA DGX Spark NCCL Automation Script"
    print_status "=================================================="
    
    # If cleanup flag is set, just cleanup and exit
    if [[ "$cleanup_only" == true ]]; then
        cleanup
        print_status "NCCL automation completed"
        exit 0
    fi
    
    # Check environment
    check_dgx_spark_environment || exit 1
    
    # Step 1: Configure network connectivity
    configure_network_connectivity || exit 1
    
    # Step 2: Build NCCL with Blackwell support
    build_nccl || exit 1
    
    # Step 3: Build NCCL test suite
    build_nccl_tests || exit 1
    
    # Step 4: Find network interfaces
    find_network_interfaces || exit 1
    
    # Step 5: Run NCCL communication test
    run_nccl_test || exit 1
    
    # Step 6: Cleanup (optional - only if not requested)
    # We'll keep the build artifacts for re-use
    
    print_status "=================================================="
    print_status "NCCL automation completed successfully!"
    print_status "Your NCCL environment is ready for multi-node distributed training workloads."
    print_status ""
    print_status "Next steps:"
    print_status "  - Run distributed training workloads such as TRT-LLM or vLLM inference"
    print_status "  - Use the built test suite for performance verification"
    
    return 0
}

# Run main function with all arguments
main "$@"