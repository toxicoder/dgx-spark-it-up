#!/bin/bash

# ComfyUI Automation Script
# This script automates the installation and setup of ComfyUI on NVIDIA DGX Spark devices

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Error function
error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Warning function
warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    log "Step 1: Verifying system prerequisites"
    
    # Check Python version
    if ! command -v python3 &> /dev/null; then
        error "Python 3 is not installed"
        return 1
    fi
    
    python_version=$(python3 --version 2>&1 | cut -d' ' -f2)
    if [[ "$(printf '%s\n' "3.8" "$python_version" | sort -V | head -n1)" != "3.8" ]]; then
        warning "Python version $python_version is installed, but 3.8+ is recommended"
    fi
    
    # Check pip
    if ! command -v pip3 &> /dev/null; then
        error "pip3 is not installed"
        return 1
    fi
    
    # Check nvcc
    if ! command -v nvcc &> /dev/null; then
        warning "nvcc is not installed, but CUDA support may be available through nvidia-smi"
    fi
    
    # Check nvidia-smi
    if ! command -v nvidia-smi &> /dev/null; then
        error "nvidia-smi is not installed - GPU not detected"
        return 1
    fi
    
    log "All prerequisites verified"
    return 0
}

# Function to create virtual environment
create_virtual_env() {
    log "Step 2: Creating Python virtual environment"
    
    if [ -d "comfyui-env" ]; then
        warning "Virtual environment 'comfyui-env' already exists, will use existing one"
    else
        python3 -m venv comfyui-env
        if [ $? -ne 0 ]; then
            error "Failed to create virtual environment"
            return 1
        fi
    fi
    
    # Activate virtual environment
    source comfyui-env/bin/activate
    
    # Verify activation
    if [[ $VIRTUAL_ENV != *"comfyui-env"* ]]; then
        error "Failed to activate virtual environment"
        return 1
    fi
    
    log "Virtual environment activated"
    return 0
}

# Function to install PyTorch with CUDA support
install_pytorch() {
    log "Step 3: Installing PyTorch with CUDA 13.0 support"
    
    # Install PyTorch with CUDA 13.0 support
    pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu130
    if [ $? -ne 0 ]; then
        error "Failed to install PyTorch"
        return 1
    fi
    
    log "PyTorch installed successfully"
    return 0
}

# Function to clone ComfyUI repository
clone_comfyui() {
    log "Step 4: Cloning ComfyUI repository"
    
    if [ -d "ComfyUI" ]; then
        warning "ComfyUI directory already exists, skipping clone"
        return 0
    fi
    
    git clone https://github.com/comfyanonymous/ComfyUI.git
    if [ $? -ne 0 ]; then
        error "Failed to clone ComfyUI repository"
        return 1
    fi
    
    cd ComfyUI
    log "ComfyUI repository cloned successfully"
    return 0
}

# Function to install ComfyUI dependencies
install_dependencies() {
    log "Step 5: Installing ComfyUI dependencies"
    
    if [ ! -f "requirements.txt" ]; then
        error "requirements.txt not found in ComfyUI directory"
        return 1
    fi
    
    pip install -r requirements.txt
    if [ $? -ne 0 ]; then
        error "Failed to install ComfyUI dependencies"
        return 1
    fi
    
    log "ComfyUI dependencies installed successfully"
    return 0
}

# Function to download Stable Diffusion checkpoint
download_model() {
    log "Step 6: Downloading Stable Diffusion checkpoint"
    
    cd models/checkpoints/
    
    if [ -f "v1-5-pruned-emaonly-fp16.safetensors" ]; then
        warning "Model already downloaded, skipping download"
        cd ../../
        return 0
    fi
    
    wget https://huggingface.co/Comfy-Org/stable-diffusion-v1-5-archive/resolve/main/v1-5-pruned-emaonly-fp16.safetensors
    if [ $? -ne 0 ]; then
        error "Failed to download Stable Diffusion checkpoint"
        cd ../../
        return 1
    fi
    
    cd ../../
    log "Stable Diffusion checkpoint downloaded successfully"
    return 0
}

# Function to launch ComfyUI server
launch_server() {
    log "Step 7: Launching ComfyUI server"
    
    # Start the server in background
    python main.py --listen 0.0.0.0 > comfyui.log 2>&1 &
    local server_pid=$!
    
    # Wait a bit for server to start
    sleep 5
    
    # Check if server is running
    if ! ps -p $server_pid > /dev/null; then
        error "ComfyUI server failed to start"
        return 1
    fi
    
    log "ComfyUI server launched successfully (PID: $server_pid)"
    echo $server_pid > comfyui.pid
    return 0
}

# Function to validate installation
validate_installation() {
    log "Step 8: Validating installation"
    
    # Check if server is responding
    if ! curl -f -s http://localhost:8188 > /dev/null; then
        error "ComfyUI server is not responding on port 8188"
        return 1
    fi
    
    log "Installation validated successfully"
    return 0
}

# Function to cleanup installation
cleanup() {
    log "Step 9: Cleaning up installation"
    
    # Kill server if running
    if [ -f "comfyui.pid" ]; then
        local server_pid=$(cat comfyui.pid)
        if ps -p $server_pid > /dev/null; then
            kill $server_pid 2>/dev/null || true
        fi
        rm -f comfyui.pid
    fi
    
    # Deactivate virtual environment
    deactivate 2>/dev/null || true
    
    # Remove virtual environment and ComfyUI directory
    rm -rf comfyui-env/
    rm -rf ComfyUI/
    
    log "Cleanup completed"
    return 0
}

# Function to show next steps
show_next_steps() {
    log "Step 10: Next steps"
    echo "To test the installation:"
    echo "1. Access the web interface at http://<SPARK_IP>:8188"
    echo "2. Load the default workflow (should appear automatically)"
    echo "3. Click \"Run\" to generate your first image"
    echo "4. Monitor GPU usage with nvidia-smi in a separate terminal"
    echo "The image generation should complete within 30-60 seconds depending on your hardware configuration."
}

# Main execution function
main() {
    log "Starting ComfyUI automation installation"
    
    # Step 1: Check prerequisites
    check_prerequisites || exit 1
    
    # Step 2: Create virtual environment
    create_virtual_env || exit 1
    
    # Step 3: Install PyTorch
    install_pytorch || exit 1
    
    # Step 4: Clone ComfyUI
    clone_comfyui || exit 1
    
    # Step 5: Install dependencies
    install_dependencies || exit 1
    
    # Step 6: Download model
    download_model || exit 1
    
    # Step 7: Launch server
    launch_server || exit 1
    
    # Step 8: Validate installation
    validate_installation || exit 1
    
    # Step 9: Show next steps
    show_next_steps
    
    log "ComfyUI installation completed successfully!"
    return 0
}

# Cleanup function to be called on exit
cleanup_on_exit() {
    log "Cleaning up on exit..."
    cleanup
}

# Register cleanup function
trap cleanup_on_exit EXIT

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi