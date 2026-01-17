#!/bin/bash

# Test helper functions for ComfyUI automation

# Function to check if a command is available.
#
# Check if a command exists in the system PATH.
#
# Arguments:
#   $1 - Command name to check.
#
# Returns:
#   0 - Command exists.
#   1 - Command does not exist.
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check Python version.
#
# Verify that Python 3 is available and meets version requirements.
#
# Returns:
#   0 - Python 3 is available and meets requirements.
#   1 - Python 3 is not available or doesn't meet requirements.
#
# Errors:
#   python3 not found: Python 3 is required for ComfyUI.
#   Python version too low: Python version 3.8+ is recommended.
check_python_version() {
    if ! command_exists "python3"; then
        echo "error: python3 not found"
        return 1
    fi
    
    local version=$(python3 --version 2>&1 | cut -d' ' -f2)
    if [[ "$(printf '%s\n' "3.8" "$version" | sort -V | head -n1)" != "3.8" ]]; then
        echo "warning: Python version $version is installed, but 3.8+ is recommended"
        return 0
    fi
    
    echo "info: Python version $version is available"
    return 0
}

# Function to check pip.
#
# Verify that pip3 is available for package management.
#
# Returns:
#   0 - pip3 is available.
#   1 - pip3 is not available.
#
# Errors:
#   pip3 not found: pip3 is required for installing Python packages.
check_pip() {
    if ! command_exists "pip3"; then
        echo "error: pip3 not found"
        return 1
    fi
    
    echo "info: pip3 is available"
    return 0
}

# Function to check nvidia-smi.
#
# Verify that nvidia-smi is available for GPU detection.
#
# Returns:
#   0 - nvidia-smi is available.
#   1 - nvidia-smi is not available.
#
# Errors:
#   nvidia-smi not found: nvidia-smi is required to detect GPU.
check_nvidia_smi() {
    if ! command_exists "nvidia-smi"; then
        echo "error: nvidia-smi not found - GPU not detected"
        return 1
    fi
    
    echo "info: nvidia-smi is available"
    return 0
}

# Function to check nvcc.
#
# Verify that nvcc is available for CUDA compilation.
#
# Returns:
#   0 - nvcc is available or not required.
#   1 - nvcc is not available (but this may be acceptable).
#
# Errors:
#   nvcc not found: nvcc is not required but may be useful for CUDA development.
check_nvcc() {
    if ! command_exists "nvcc"; then
        echo "warning: nvcc not found, but CUDA support may be available through nvidia-smi"
        return 0
    fi
    
    echo "info: nvcc is available"
    return 0
}

# Function to verify virtual environment.
#
# Check if the ComfyUI virtual environment directory exists.
#
# Returns:
#   0 - Virtual environment exists.
#   1 - Virtual environment does not exist.
#
# Errors:
#   virtual environment 'comfyui-env' not found: Virtual environment required for ComfyUI.
verify_virtual_env() {
    if [ ! -d "comfyui-env" ]; then
        echo "error: virtual environment 'comfyui-env' not found"
        return 1
    fi
    
    echo "info: virtual environment 'comfyui-env' found"
    return 0
}

# Function to verify PyTorch installation.
#
# Verify that PyTorch is properly installed and importable.
#
# Returns:
#   0 - PyTorch is installed and importable.
#   1 - PyTorch is not installed or not importable.
#
# Errors:
#   PyTorch not installed or not importable: PyTorch is required for ComfyUI.
verify_pytorch() {
    if ! python3 -c "import torch; print('PyTorch version:', torch.__version__)" &> /dev/null; then
        echo "error: PyTorch not installed or not importable"
        return 1
    fi
    
    echo "info: PyTorch is installed"
    return 0
}

# Function to verify ComfyUI repository.
#
# Check if the ComfyUI repository directory exists.
#
# Returns:
#   0 - ComfyUI repository exists.
#   1 - ComfyUI repository does not exist.
#
# Errors:
#   ComfyUI repository not found: ComfyUI repository required for installation.
verify_comfyui_repo() {
    if [ ! -d "ComfyUI" ]; then
        echo "error: ComfyUI repository not found"
        return 1
    fi
    
    echo "info: ComfyUI repository found"
    return 0
}

# Function to verify requirements.txt.
#
# Check if the requirements.txt file exists in the ComfyUI directory.
#
# Returns:
#   0 - requirements.txt found.
#   1 - requirements.txt not found.
#
# Errors:
#   requirements.txt not found in ComfyUI directory: Dependencies file required.
verify_requirements() {
    if [ ! -f "ComfyUI/requirements.txt" ]; then
        echo "error: requirements.txt not found in ComfyUI directory"
        return 1
    fi
    
    echo "info: requirements.txt found in ComfyUI directory"
    return 0
}

# Function to verify model download.
#
# Check if the Stable Diffusion model checkpoint exists.
#
# Returns:
#   0 - Model checkpoint found.
#   1 - Model checkpoint not found.
#
# Errors:
#   Stable Diffusion checkpoint not found: Model required for ComfyUI.
verify_model() {
    if [ ! -f "ComfyUI/models/checkpoints/v1-5-pruned-emaonly-fp16.safetensors" ]; then
        echo "error: Stable Diffusion checkpoint not found"
        return 1
    fi
    
    echo "info: Stable Diffusion checkpoint found"
    return 0
}

# Function to verify server is running.
#
# Check if the ComfyUI server is running by checking its PID file.
#
# Returns:
#   0 - Server is running.
#   1 - Server is not running or PID file not found.
#
# Errors:
#   ComfyUI server PID file not found: Server not started.
#   ComfyUI server is not running: Server process not active.
verify_server() {
    if [ ! -f "comfyui.pid" ]; then
        echo "error: ComfyUI server PID file not found"
        return 1
    fi
    
    local pid=$(cat comfyui.pid)
    if ! ps -p "$pid" > /dev/null 2>&1; then
        echo "error: ComfyUI server is not running"
        return 1
    fi
    
    echo "info: ComfyUI server is running (PID: $pid)"
    return 0
}

# Function to verify installation validation.
#
# Validate that the ComfyUI installation is responding correctly.
#
# Returns:
#   0 - Installation validated successfully.
#   1 - Installation validation failed.
#
# Errors:
#   ComfyUI server is not responding on port 8188: Server not responding.
verify_installation() {
    if ! curl -f -s http://localhost:8188 > /dev/null 2>&1; then
        echo "error: ComfyUI server is not responding on port 8188"
        return 1
    fi
    
    echo "info: ComfyUI installation validated successfully"
    return 0
}