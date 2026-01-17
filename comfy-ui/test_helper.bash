#!/bin/bash

# Test helper functions for ComfyUI automation

# Function to check if a command is available
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check Python version
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

# Function to check pip
check_pip() {
    if ! command_exists "pip3"; then
        echo "error: pip3 not found"
        return 1
    fi
    
    echo "info: pip3 is available"
    return 0
}

# Function to check nvidia-smi
check_nvidia_smi() {
    if ! command_exists "nvidia-smi"; then
        echo "error: nvidia-smi not found - GPU not detected"
        return 1
    fi
    
    echo "info: nvidia-smi is available"
    return 0
}

# Function to check nvcc
check_nvcc() {
    if ! command_exists "nvcc"; then
        echo "warning: nvcc not found, but CUDA support may be available through nvidia-smi"
        return 0
    fi
    
    echo "info: nvcc is available"
    return 0
}

# Function to verify virtual environment
verify_virtual_env() {
    if [ ! -d "comfyui-env" ]; then
        echo "error: virtual environment 'comfyui-env' not found"
        return 1
    fi
    
    echo "info: virtual environment 'comfyui-env' found"
    return 0
}

# Function to verify PyTorch installation
verify_pytorch() {
    if ! python3 -c "import torch; print('PyTorch version:', torch.__version__)" &> /dev/null; then
        echo "error: PyTorch not installed or not importable"
        return 1
    fi
    
    echo "info: PyTorch is installed"
    return 0
}

# Function to verify ComfyUI repository
verify_comfyui_repo() {
    if [ ! -d "ComfyUI" ]; then
        echo "error: ComfyUI repository not found"
        return 1
    fi
    
    echo "info: ComfyUI repository found"
    return 0
}

# Function to verify requirements.txt
verify_requirements() {
    if [ ! -f "ComfyUI/requirements.txt" ]; then
        echo "error: requirements.txt not found in ComfyUI directory"
        return 1
    fi
    
    echo "info: requirements.txt found in ComfyUI directory"
    return 0
}

# Function to verify model download
verify_model() {
    if [ ! -f "ComfyUI/models/checkpoints/v1-5-pruned-emaonly-fp16.safetensors" ]; then
        echo "error: Stable Diffusion checkpoint not found"
        return 1
    fi
    
    echo "info: Stable Diffusion checkpoint found"
    return 0
}

# Function to verify server is running
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

# Function to verify installation validation
verify_installation() {
    if ! curl -f -s http://localhost:8188 > /dev/null 2>&1; then
        echo "error: ComfyUI server is not responding on port 8188"
        return 1
    fi
    
    echo "info: ComfyUI installation validated successfully"
    return 0
}