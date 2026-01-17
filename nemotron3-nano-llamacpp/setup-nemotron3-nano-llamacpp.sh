#!/usr/bin/env bash

# Nemotron-3-Nano-30B-A3B GGUF Setup Script.
#
# This script automates the complete setup of Nemotron-3-Nano-30B-A3B GGUF model on DGX Spark, including prerequisites checking, virtual environment setup, llama.cpp building, model downloading, and server startup.

set -euo pipefail

# Global variables
readonly MODELS_DIR="${HOME}/models/nemotron3-gguf"
readonly VENV_DIR="./nemotron-venv"
readonly LLAMA_CPP_DIR="./llama.cpp"
readonly SERVER_LOG="server.log"

# print_header – Print styled header message.
#
# Prints a formatted header message for the Nemotron setup script.
#
# Returns:
#   0 – Success. .
print_header() {
    echo "==============================================="
    echo "Nemotron-3-Nano-30B-A3B Setup Script"
    echo "==============================================="
}

# print_status – Print status message.
#
# Prints a status message with a checkmark emoji prefix.
#
# Parameters:
#   $1 (String) – Status message to display. .
#
# Returns:
#   0 – Success. .
print_status() {
    echo "✅ $1"
}

# print_error – Print error message.
#
# Prints an error message with a cross emoji prefix to stderr.
#
# Parameters:
#   $1 (String) – Error message to display. .
#
# Returns:
#   0 – Success. .
print_error() {
    echo "❌ $1" >&2
}

# check_prerequisites – Check system prerequisites.
#
# Checks that all required system tools (git, cmake, nvcc) are installed and available.
#
# Returns:
#   0 – All prerequisites met. .
#   1 – Missing prerequisite detected. .
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

# setup_virtual_environment – Set up Hugging Face CLI virtual environment.
#
# Sets up a Python virtual environment and installs the Hugging Face CLI.
#
# Returns:
#   0 – Virtual environment set up successfully. .
#   1 – Failed to set up virtual environment. .
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

# clone_llama_cpp – Clone llama.cpp repository.
#
# Clones the llama.cpp repository from GitHub to the local directory.
#
# Returns:
#   0 – Repository cloned successfully. .
#   1 – Failed to clone repository. .
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

# build_llama_cpp – Build llama.cpp with CUDA support.
#
# Builds the llama.cpp project with CUDA support enabled for GPU acceleration.
#
# Returns:
#   0 – Build completed successfully. .
#   1 – Build failed. .
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

# download_model – Download Nemotron GGUF model.
#
# Downloads the Nemotron-3-Nano-30B-A3B GGUF model (~38GB) from Hugging Face.
#
# Returns:
#   0 – Model downloaded successfully. .
#   1 – Model download failed. .
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

# start_server – Start llama.cpp server.
#
# Starts the llama.cpp server in the background with specified configuration.
#
# Returns:
#   0 – Server started successfully. .
#   1 – Server failed to start. .
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

# main – Main execution function.
#
# Main execution function that orchestrates the complete Nemotron setup process.
#
# Parameters:
#   $@ (All) – Command line arguments. .
#
# Returns:
#   0 – Script completed successfully. .
#   1 – Script failed at some point. .
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

# test_mode – Check if running in test mode.
#
# Checks if the script is running in test mode by examining TEST_MODE environment variable.
#
# Returns:
#   0 – Test mode is enabled. .
#   1 – Test mode is disabled. .
test_mode() {
    if [[ "${TEST_MODE:-false}" == "true" ]]; then
        echo "Running in test mode"
        return 0
    else
        return 1
    fi
}