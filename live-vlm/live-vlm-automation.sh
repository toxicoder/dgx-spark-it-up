#!/bin/bash

# =============================================================================
# Live VLM WebUI Automation Script
# This script automates the entire Live VLM WebUI setup and configuration
# following the official guide at https://build.nvidia.com/spark/live-vlm-webui
# =============================================================================

set -euo pipefail  # Exit on any error, undefined vars, pipe failures

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

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
    echo "  -h, --help                    Show this help message"
    echo "  -i, --install                 Install Ollama and Live VLM WebUI"
    echo "  -s, --start                   Start the Live VLM WebUI server"
    echo "  -c, --configure               Configure VLM settings"
    echo "  -p, --port PORT               Specify port for the server (default: 8090)"
    echo "  -m, --model MODEL             Specify VLM model to use (default: gemma3:4b)"
    echo "  -u, --uninstall               Uninstall Live VLM WebUI and Ollama"
    echo ""
    echo "Examples:"
    echo "  $SCRIPT_NAME --install"
    echo "  $SCRIPT_NAME --install --model llama3.2-vision:11b"
    echo "  $SCRIPT_NAME --start"
    echo "  $SCRIPT_NAME --start --port 8091"
    echo "  $SCRIPT_NAME --uninstall"
    echo ""
}

# Check if running on NVIDIA DGX Spark with Blackwell GPU
verify_dgx_spark_environment() {
    print_status "Verifying DGX Spark Blackwell GPU environment..."
    
    # Check if we're on a NVIDIA system
    if ! command -v nvidia-smi &> /dev/null; then
        print_warning "nvidia-smi not found. This might not be a DGX Spark system."
        return 1
    fi
    
    # Check for Blackwell GPU
    if nvidia-smi | grep -q "Blackwell"; then
        print_status "Blackwell GPU detected"
        return 0
    else
        print_warning "Blackwell GPU not detected. This script is optimized for DGX Spark Blackwell."
        return 1
    fi
}

# Install Ollama as VLM Backend
install_ollama() {
    print_status "Installing Ollama as VLM Backend..."
    
    # Check if Ollama is already installed
    if command -v ollama &> /dev/null; then
        print_status "Ollama is already installed"
        ollama --version
        return 0
    fi
    
    # Install Ollama
    print_status "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
    
    # Verify installation
    if command -v ollama &> /dev/null; then
        print_status "Ollama installed successfully"
        ollama --version
    else
        print_error "Failed to install Ollama"
        return 1
    fi
    
    # Wait for Ollama service to start
    print_status "Waiting for Ollama service to start..."
    sleep 5
    
    return 0
}

# Download VLM model
download_vlm_model() {
    local model_name="${1:-gemma3:4b}"
    
    print_status "Downloading VLM model: $model_name"
    
    # Check if model already exists
    if ollama list | grep -q "$model_name"; then
        print_status "Model $model_name already downloaded"
        return 0
    fi
    
    # Download the model
    ollama pull "$model_name"
    
    # Verify model was downloaded
    if ollama list | grep -q "$model_name"; then
        print_status "Model $model_name downloaded successfully"
        return 0
    else
        print_error "Failed to download model $model_name"
        return 1
    fi
}

# Install Live VLM WebUI
install_live_vlm_webui() {
    print_status "Installing Live VLM WebUI..."
    
    # Check if pip is available
    if ! command -v pip &> /dev/null; then
        print_error "pip is not installed"
        return 1
    fi
    
    # Install Live VLM WebUI
    pip install live-vlm-webui
    
    # Verify installation
    if command -v live-vlm-webui &> /dev/null; then
        print_status "Live VLM WebUI installed successfully"
        return 0
    else
        print_error "Failed to install Live VLM WebUI"
        return 1
    fi
}

# Start Live VLM WebUI server
start_live_vlm_server() {
    local port="${1:-8090}"
    local model_name="${2:-gemma3:4b}"
    
    print_status "Starting Live VLM WebUI server on port $port..."
    
    # Check if server is already running
    if pgrep -f "live-vlm-webui" > /dev/null; then
        print_warning "Live VLM WebUI server is already running"
        return 0
    fi
    
    # Set up environment for Ollama API
    export OLLAMA_API_BASE="http://localhost:11434/v1"
    
    print_status "Server will use model: $model_name"
    print_status "Server will run on port: $port"
    
    # Start the server in background
    live-vlm-webui --port "$port" &
    
    # Give the server a moment to start
    sleep 5
    
    # Verify server is running
    if pgrep -f "live-vlm-webui" > /dev/null; then
        print_status "Live VLM WebUI server started successfully"
        print_status "Access the WebUI at:"
        print_status "  Local URL:   https://localhost:$port"
        print_status "  Network URL: https://<YOUR_SPARK_IP>:$port"
        return 0
    else
        print_error "Failed to start Live VLM WebUI server"
        return 1
    fi
}

# Uninstall Live VLM WebUI and Ollama
uninstall_live_vlm() {
    print_status "Uninstalling Live VLM WebUI..."
    
    # Uninstall Live VLM WebUI
    pip uninstall -y live-vlm-webui
    
    print_status "Uninstalling Ollama..."
    
    # Stop Ollama service
    if systemctl is-active --quiet ollama; then
        sudo systemctl stop ollama
    fi
    
    # Remove Ollama binary and data
    sudo rm -f /usr/local/bin/ollama
    sudo rm -rf /usr/share/ollama
    rm -rf ~/.ollama
    
    print_status "Uninstallation complete"
    return 0
}

# Configure VLM settings
configure_vlm() {
    print_status "Configuring VLM settings..."
    
    # Display current Ollama models
    print_status "Available Ollama models:"
    ollama list
    
    # Display current server status
    if pgrep -f "live-vlm-webui" > /dev/null; then
        print_status "Live VLM WebUI server is running"
    else
        print_status "Live VLM WebUI server is not running"
    fi
    
    print_status "Configuration complete"
    return 0
}

# Main function
main() {
    local action=""
    local port="8090"
    local model="gemma3:4b"
    local SCRIPT_NAME="live-vlm-automation.sh"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -i|--install)
                action="install"
                shift
                ;;
            -s|--start)
                action="start"
                shift
                ;;
            -c|--configure)
                action="configure"
                shift
                ;;
            -p|--port)
                port="$2"
                shift 2
                ;;
            -m|--model)
                model="$2"
                shift 2
                ;;
            -u|--uninstall)
                action="uninstall"
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
        install)
            verify_dgx_spark_environment
            install_ollama
            download_vlm_model "$model"
            install_live_vlm_webui
            print_status "Installation complete!"
            print_status "Run '$SCRIPT_NAME --start' to start the server"
            ;;
        start)
            verify_dgx_spark_environment
            # Check if required components are installed
            if ! command -v ollama &> /dev/null; then
                print_error "Ollama is not installed. Run '$SCRIPT_NAME --install' first."
                exit 1
            fi
            if ! command -v live-vlm-webui &> /dev/null; then
                print_error "Live VLM WebUI is not installed. Run '$SCRIPT_NAME --install' first."
                exit 1
            fi
            start_live_vlm_server "$port" "$model"
            ;;
        configure)
            verify_dgx_spark_environment
            configure_vlm
            ;;
        uninstall)
            uninstall_live_vlm
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

echo "= Live VLM Automation Script Completed ="