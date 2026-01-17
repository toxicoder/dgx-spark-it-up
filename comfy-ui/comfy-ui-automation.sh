#!/bin/bash

# ComfyUI Automation Script.
#
# This script automates the installation and setup of ComfyUI on NVIDIA DGX Spark devices, including dependency installation, model downloading, and server launching.

set -e  # Exit on any error

# Colors for output
# RED color code for error messages
RED='\033[0;31m'
# GREEN color code for info messages
GREEN='\033[0;32m'
# YELLOW color code for warning messages
YELLOW='\033[1;33m'
# NC color code for no color (reset)
NC='\033[0m' # No Color

# Log function - Print an info message with green color prefix.
#
# Prints an info message with a green color prefix for clear visual distinction.
#
# Parameters:
#   $1 (String) - Message to log.
#
# Returns:
#   0 - Success.
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Error function - Print an error message with red color prefix.
#
# Prints an error message with a red color prefix for clear visual distinction.
#
# Parameters:
#   $1 (String) - Error message to log.
#
# Returns:
#   0 - Success.
error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Warning function - Print a warning message with yellow color prefix.
#
# Prints a warning message with a yellow color prefix for clear visual distinction.
#
# Parameters:
#   $1 (String) - Warning message to log.
#
# Returns:
#   0 - Success.
warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# check_prerequisites - Verify system prerequisites for ComfyUI installation.
#
# Verifies that all system prerequisites are met for ComfyUI installation,
# including Python 3, pip3, and nvidia-smi availability.
#
# Returns:
#   0 - All prerequisites met.
#   1 - Missing prerequisite detected.
#
# Errors:
#   1 - Python 3 not installed. Python 3 is required for ComfyUI.
#   1 - pip3 not installed. pip3 is required for package installation.
#   1 - nvidia-smi not installed. nvidia-smi is required to detect GPU.
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

# create_virtual_env - Create Python virtual environment for ComfyUI dependencies.
#
# Creates a Python virtual environment for ComfyUI dependencies and activates it.
#
# Returns:
#   0 - Virtual environment created/activated successfully.
#   1 - Failed to create or activate virtual environment.
#
# Errors:
#   1 - Failed to create virtual environment. Virtual environment creation failed.
#   1 - Failed to activate virtual environment. Virtual environment activation failed.
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

# install_pytorch - Install PyTorch with CUDA 13.0 support.
#
# Installs PyTorch with CUDA 13.0 support in the virtual environment.
#
# Returns:
#   0 - PyTorch installed successfully.
#   1 - Failed to install PyTorch.
#
# Errors:
#   1 - Failed to install PyTorch. PyTorch installation failed.
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

# clone_comfyui - Clone ComfyUI repository from GitHub.
#
# Clones the ComfyUI repository from GitHub to the local directory.
#
# Returns:
#   0 - Repository cloned successfully or already exists.
#   1 - Failed to clone repository.
#
# Errors:
#   1 - Failed to clone repository. Repository cloning failed.
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

# install_dependencies - Install ComfyUI dependencies from requirements.txt.
#
# Installs all ComfyUI dependencies from requirements.txt.
#
# Returns:
#   0 - Dependencies installed successfully.
#   1 - Failed to install dependencies or requirements.txt not found.
#
# Errors:
#   1 - requirements.txt not found. Dependencies file not found.
#   1 - Failed to install dependencies. Dependency installation failed.
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

# download_model - Download Stable Diffusion v1.5 checkpoint model.
#
# Downloads the Stable Diffusion v1.5 checkpoint model from Hugging Face.
#
# Returns:
#   0 - Model downloaded successfully or already exists.
#   1 - Failed to download model.
#
# Errors:
#   1 - Failed to download model. Model download failed.
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

# launch_server - Launch ComfyUI server in the background.
#
# Launches the ComfyUI server in the background and validates it's running.
#
# Returns:
#   0 - Server launched successfully.
#   1 - Failed to launch server.
#
# Errors:
#   1 - ComfyUI server failed to start. Server process could not be started.
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

# validate_installation - Validate ComfyUI server is responding correctly.
#
# Validates that ComfyUI server is responding correctly on port 8188.
#
# Returns:
#   0 - Installation validated successfully.
#   1 - Installation validation failed.
#
# Errors:
#   1 - ComfyUI server is not responding on port 8188. Server not responding.
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

# cleanup - Remove temporary files and directories.
#
# Removes all temporary files and directories created during ComfyUI installation.
#
# Returns:
#   0 - Cleanup completed successfully.
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

# show_next_steps - Display instructions for using installed ComfyUI.
#
# Displays instructions for using the installed ComfyUI, including web interface access.
#
# Returns:
#   0 - Success.
show_next_steps() {
    log "Step 10: Next steps"
    echo "To test the installation:"
    echo "1. Access the web interface at http://<SPARK_IP>:8188"
    echo "2. Load the default workflow (should appear automatically)"
    echo "3. Click \"Run\" to generate your first image"
    echo "4. Monitor GPU usage with nvidia-smi in a separate terminal"
    echo "The image generation should complete within 30-60 seconds depending on your hardware configuration."
}

# main - Execute the main installation workflow for ComfyUI.
#
# Executes the main installation workflow for ComfyUI, including all steps from
# prerequisites checking to final validation.
#
# Parameters:
#   $@ (All) - All arguments passed to the script.
#
# Returns:
#   0 - Installation completed successfully.
#   1 - Installation failed at some step.
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

# cleanup_on_exit - Perform cleanup when script exits.
#
# Performs cleanup operations when the script exits, including killing background processes.
#
# Returns:
#   0 - Cleanup completed.
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