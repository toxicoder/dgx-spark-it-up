#!/usr/bin/env bash

# =============================================================================
# NVIDIA DGX Spark SSH Automation Script
# This script automates the process of connecting to NVIDIA DGX Spark devices
# following the official guide at https://build.nvidia.com/spark/connect-to-your-spark
# =============================================================================

# Bash strict mode
set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Global variables
readonly SCRIPT_NAME="dgx-spark-ssh-automation.sh"
readonly CONFIG_FILE="$HOME/.dgx-spark-config"

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
    echo "  -c, --configure          Configure connection settings"
    echo "  -t, --test               Test SSH connection"
    echo "  -v, --verify             Verify SSH client and connection"
    echo "  -p, --port-forward PORT  Set up SSH tunnel for web app"
    echo "  -u, --username USER      Specify username (overrides config)"
    echo "  -H, --hostname HOST      Specify hostname (overrides config)"
    echo ""
    echo "Examples:"
    echo "  $SCRIPT_NAME --configure"
    echo "  $SCRIPT_NAME --verify"
    echo "  $SCRIPT_NAME --test"
    echo "  $SCRIPT_NAME --port-forward 11000"
    echo ""
}

# Verify SSH client availability
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

# Gather connection information
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
    
    # If IP address not set, ask user
    if [[ -z "${DGX_IP_ADDRESS:-}" ]]; then
        read -rp "Enter your DGX Spark IP address (optional, press Enter to skip): " DGX_IP_ADDRESS
    fi
    
    # Save configuration
    cat > "$CONFIG_FILE" << EOF
# DGX Spark Connection Configuration
DGX_USERNAME="$DGX_USERNAME"
DGX_HOSTNAME="$DGX_HOSTNAME"
DGX_IP_ADDRESS="$DGX_IP_ADDRESS"
EOF
    
    print_status "Configuration saved to $CONFIG_FILE"
    return 0
}

# Test mDNS resolution
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

# Test SSH connection
test_ssh_connection() {
    local username="$1"
    local hostname="$2"
    local ip_address="${3:-}"
    
    print_status "Testing SSH connection..."
    
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
verify_remote_connection() {
    local username="$1"
    local hostname="$2"
    local ip_address="${3:-}"
    
    print_status "Verifying remote connection..."
    
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

# Set up SSH tunnel for web applications
setup_ssh_tunnel() {
    local username="$1"
    local hostname="$2"
    local local_port="$3"
    local remote_port="$4"
    
    print_status "Setting up SSH tunnel..."
    print_status "Local port: $local_port -> Remote port: $remote_port"
    
    # Try mDNS hostname first
    if test_mdns_resolution "$hostname"; then
        print_status "Creating tunnel via mDNS hostname: $username@$hostname.local"
        ssh -L "$local_port:localhost:$remote_port" "$username@$hostname.local"
        return $?
    fi
    
    # If mDNS fails, try IP address if provided
    print_error "Cannot establish SSH tunnel - mDNS resolution failed"
    return 1
}

# Main function
main() {
    local action=""
    local username=""
    local hostname=""
    local port_forward=""
    
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
            -t|--test)
                action="test"
                shift
                ;;
            -v|--verify)
                action="verify"
                shift
                ;;
            -p|--port-forward)
                action="port-forward"
                port_forward="$2"
                shift 2
                ;;
            -u|--username)
                username="$2"
                shift 2
                ;;
            -H|--hostname)
                hostname="$2"
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
    
    # Execute requested action
    case "$action" in
        configure)
            gather_connection_info
            ;;
        verify)
            verify_ssh_client
            ;;
        test)
            # Load configuration if available
            if [[ -f "$CONFIG_FILE" ]]; then
                source "$CONFIG_FILE"
            fi
            
            # Use provided username or hostname or config values
            local actual_username="${username:-$DGX_USERNAME}"
            local actual_hostname="${hostname:-$DGX_HOSTNAME}"
            local actual_ip_address="${DGX_IP_ADDRESS:-}"
            
            if [[ -z "$actual_username" ]] || [[ -z "$actual_hostname" ]]; then
                print_error "Username and hostname must be specified"
                exit 1
            fi
            
            verify_ssh_client
            test_ssh_connection "$actual_username" "$actual_hostname" "$actual_ip_address"
            verify_remote_connection "$actual_username" "$actual_hostname" "$actual_ip_address"
            ;;
        "port-forward")
            # Load configuration if available
            if [[ -f "$CONFIG_FILE" ]]; then
                source "$CONFIG_FILE"
            fi
            
            # Use provided username or hostname or config values
            local actual_username="${username:-$DGX_USERNAME}"
            local actual_hostname="${hostname:-$DGX_HOSTNAME}"
            
            if [[ -z "$actual_username" ]] || [[ -z "$actual_hostname" ]] || [[ -z "$port_forward" ]]; then
                print_error "Username, hostname, and port must be specified"
                exit 1
            fi
            
            # Default remote port to local port if not specified
            local remote_port="${port_forward}"
            
            setup_ssh_tunnel "$actual_username" "$actual_hostname" "$port_forward" "$remote_port"
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