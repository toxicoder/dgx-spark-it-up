#!/usr/bin/env bash

# Automated setup script for Nemotron-3-Nano-30B-A3B GGUF model on DGX Spark
# This script automates all steps from the installation guide

set -euo pipefail

# Global variables
readonly MODELS_DIR="${HOME}/models/nemotron3-gguf"
readonly VENV_DIR="./nemotron-venv"
readonly LLAMA_CPP_DIR="./llama.cpp"
readonly SERVER_LOG="server.log"

# Function to print styled messages
print_header() {
    echo "==============================================="
    echo "Nemotron-3-Nano-30B-A3B Setup Script"
    echo "==============================================="
}

print_status() {
    echo "✅ $1"
}

print_error() {
    echo "❌ $1" >&2
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v git &> /dev/null; then
        print_error "git is not installed. Please install it first."
        print_error "On Ubuntu/Debian: sudo apt install git"
        exit 1
    fi

    if ! command -v cmake &> /dev/null; then
        print_error "cmake is not installed. Please install it first."
        print_error "On Ubuntu/Debian: sudo apt install cmake"
        exit 1
    fi

    if ! command -v nvcc &> /dev/null; then
        print_error "nvcc (CUDA) is not installed. Please ensure CUDA toolkit is properly installed and in PATH."
        print_error "On Ubuntu/Debian: sudo apt install nvidia-cuda-toolkit"
        exit 1
    fi

    print_status "Prerequisites verified."
}

# Function to setup virtual environment
setup_virtual_environment() {
    print_status "Setting up Hugging Face CLI environment..."
    
    python3 -m venv "$VENV_DIR"
    # shellcheck disable=SC1091
    if ! source "$VENV_DIR/bin/activate"; then
        print_error "Failed to activate venv"
        exit 1
    fi
    
    pip install -U "huggingface_hub[cli]"
    
    # Check hf version
    print_status "Checking Hugging Face CLI version..."
    hf --version
}

# Function to clone llama.cpp repository
clone_llama_cpp() {
    print_status "Cloning llama.cpp repository..."
    
    if ! git clone https://github.com/ggml-org/llama.cpp; then
        print_error "Failed to clone llama.cpp repository"
        exit 1
    fi
    
    if ! cd "$LLAMA_CPP_DIR"; then
        print_error "Failed to enter llama.cpp directory"
        exit 1
    fi
}

# Function to build llama.cpp with CUDA support
build_llama_cpp() {
    print_status "Building llama.cpp with CUDA support..."
    
    if ! mkdir -p build && cd build; then
        print_error "Failed to create and enter build directory"
        exit 1
    fi

    # Note: Using sm_90 for Hopper architecture (common for recent NVIDIA GPUs)
    # If your DGX Spark uses a different architecture, adjust this accordingly
    cmake .. -DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES="90" -DLLAMA_CURL=OFF
    make -j8
    
    # Check if build was successful
    if ! make -j8; then
        print_error "Build failed. Please check for errors above."
        exit 1
    fi
    
    print_status "llama.cpp built successfully."
}

# Function to download Nemotron GGUF model
download_model() {
    print_status "Downloading Nemotron GGUF model (~38GB)..."
    
    if ! mkdir -p "$MODELS_DIR"; then
        print_error "Failed to create models directory"
        exit 1
    fi

    # Download the Q8 quantized model
    if ! hf download unsloth/Nemotron-3-Nano-30B-A3B-GGUF \
      Nemotron-3-Nano-30B-A3B-UD-Q8_K_XL.gguf \
      --local-dir "$MODELS_DIR"; then
        print_error "Model download failed. Please check your internet connection and try again."
        exit 1
    fi
    
    print_status "Model downloaded successfully."
}

# Function to start llama.cpp server
start_server() {
    print_status "Starting llama.cpp server..."
    
    if ! cd "../bin"; then
        print_error "Failed to enter bin directory"
        exit 1
    fi

    # Start server in background with logging
    nohup ./llama-server \
      --model "$MODELS_DIR/Nemotron-3-Nano-30B-A3B-UD-Q8_K_XL.gguf" \
      --host 0.0.0.0 \
      --port 30000 \
      --n-gpu-layers 99 \
      --ctx-size 8192 \
      --threads 8 > "$SERVER_LOG" 2>&1 &
    
    # Check if server started
    if pgrep -f "llama-server" > /dev/null; then
        print_status "Server started successfully in background."
        echo "Server logs are being saved to: $(pwd)/$SERVER_LOG"
        echo ""
        print_header
        echo "Setup Complete!"
        print_header
        echo "To test the API, run:"
        echo "curl http://localhost:30000/v1/chat/completions \\"
        echo "  -H \"Content-Type: application/json\" \\"
        echo "  -d '{\"model\": \"nemotron\", \"messages\": [{\"role\": \"user\", \"content\": \"Hello\"}], \"max_tokens\": 50}'"
        echo ""
        echo "To stop the server, find the process ID and kill it:"
        echo "ps aux | grep llama-server"
        echo "kill [PID]"
        echo ""
        echo "Note: Server will continue running even after terminal closes."
        print_header
    else
        print_error "Failed to start server."
        exit 1
    fi
}

# Main execution function
main() {
    print_header
    
    # Setup cleanup trap
    trap 'echo "Script interrupted. Cleaning up..."' INT TERM EXIT
    
    check_prerequisites
    setup_virtual_environment
    clone_llama_cpp
    build_llama_cpp
    download_model
    start_server
}

# Execute main function
main "$@"

# Add a function to check if we're running in test mode
# This is a helper function to make testing easier
test_mode() {
    if [[ "${TEST_MODE:-false}" == "true" ]]; then
        echo "Running in test mode"
        return 0
    else
        return 1
    fi
}