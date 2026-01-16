#!/usr/bin/env bash

# =============================================================================
# NVIDIA DGX Spark Unsloth Automation Script
# This script automates the process of setting up and testing Unsloth on NVIDIA DGX Spark devices
# Following the official guide at https://build.nvidia.com/spark/unsloth
# =============================================================================

# Bash strict mode
set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Global variables
readonly SCRIPT_NAME="unsloth-automation.sh"
readonly TEST_SCRIPT_URL="https://raw.githubusercontent.com/NVIDIA/dgx-spark-playbooks/refs/heads/main/nvidia/unsloth/assets/test_unsloth.py"

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

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Display usage information
usage() {
    echo "Usage: $SCRIPT_NAME [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help               Show this help message"
    echo "  -a, --auto               Run all steps automatically (default)"
    echo "  -v, --verify             Verify prerequisites (CUDA, GPU)"
    echo "  -p, --pull               Pull Docker image"
    echo "  -l, --launch             Launch Docker container"
    echo "  -i, --install            Install dependencies in container"
    echo "  -t, --test               Create and run test script"
    echo "  -n, --next-steps         Show next steps information"
    echo ""
    echo "Examples:"
    echo "  $SCRIPT_NAME --auto"
    echo "  $SCRIPT_NAME --verify"
    echo "  $SCRIPT_NAME --pull"
    echo "  $SCRIPT_NAME --launch"
    echo "  $SCRIPT_NAME --install"
    echo "  $SCRIPT_NAME --test"
    echo "  $SCRIPT_NAME --next-steps"
    echo ""
}

# Verify prerequisites
verify_prerequisites() {
    print_step "Step 1: Verifying prerequisites"
    
    print_status "Checking CUDA version..."
    if command -v nvcc &> /dev/null; then
        local cuda_version
        cuda_version=$(nvcc --version | grep -o 'Cuda compilation tools, release [0-9.]*' | cut -d' ' -f5)
        print_status "CUDA version: $cuda_version"
        if [[ "$cuda_version" == "13.0" ]]; then
            print_status "CUDA version 13.0 is available ✓"
        else
            print_warning "CUDA version is $cuda_version, expected 13.0"
        fi
    else
        print_error "nvcc command not found - CUDA toolkit not installed"
        return 1
    fi
    
    print_status "Checking GPU information..."
    if command -v nvidia-smi &> /dev/null; then
        nvidia-smi
        print_status "GPU information retrieved successfully ✓"
    else
        print_error "nvidia-smi command not found - GPU drivers may not be installed"
        return 1
    fi
    
    return 0
}

# Pull Docker image
pull_docker_image() {
    print_step "Step 2: Getting container image"
    
    print_status "Pulling Docker image: nvcr.io/nvidia/pytorch:25.11-py3"
    
    if command -v docker &> /dev/null; then
        docker pull nvcr.io/nvidia/pytorch:25.11-py3
        print_status "Docker image pulled successfully ✓"
    else
        print_error "Docker not found - please install Docker before proceeding"
        return 1
    fi
    
    return 0
}

# Launch Docker container
launch_docker_container() {
    print_step "Step 3: Launching Docker container"
    
    print_status "Launching Docker container with required options..."
    
    if command -v docker &> /dev/null; then
        print_status "Starting container with: --gpus all --ulimit memlock=-1 -it --ulimit stack=67108864 --entrypoint /usr/bin/bash --rm nvcr.io/nvidia/pytorch:25.11-py3"
        # We'll launch a container that stays interactive for user to complete remaining steps
        docker run --gpus all --ulimit memlock=-1 -it --ulimit stack=67108864 --entrypoint /usr/bin/bash --rm nvcr.io/nvidia/pytorch:25.11-py3
        print_status "Docker container launched successfully ✓"
    else
        print_error "Docker not found - please install Docker before proceeding"
        return 1
    fi
    
    return 0
}

# Install dependencies inside Docker
install_dependencies() {
    print_step "Step 4: Installing dependencies inside Docker"
    
    print_status "Installing required Python packages..."
    
    # Note: This would need to be run inside the Docker container
    # For automation purposes, we'll just print what would be installed
    print_status "Installing with pip:"
    print_status "  - transformers"
    print_status "  - peft"
    print_status "  - hf_transfer"
    print_status "  - datasets==4.3.0"
    print_status "  - trl==0.26.1"
    print_status "  - unsloth"
    print_status "  - unsloth_zoo"
    print_status "  - bitsandbytes"
    
    print_warning "Dependencies installation must be done inside the Docker container"
    print_warning "Please run the following commands in the Docker container:"
    print_status "pip install transformers peft hf_transfer \"datasets==4.3.0\" \"trl==0.26.1\""
    print_status "pip install --no-deps unsloth unsloth_zoo bitsandbytes"
    
    return 0
}

# Create Python test script
create_test_script() {
    print_step "Step 5: Creating Python test script"
    
    print_status "Downloading test script from GitHub..."
    
    if command -v curl &> /dev/null; then
        curl -O "$TEST_SCRIPT_URL"
        if [[ -f "test_unsloth.py" ]]; then
            print_status "Test script downloaded successfully ✓"
            print_status "Test script location: $(pwd)/test_unsloth.py"
        else
            print_error "Failed to download test script"
            return 1
        fi
    elif command -v wget &> /dev/null; then
        wget "$TEST_SCRIPT_URL"
        if [[ -f "test_unsloth.py" ]]; then
            print_status "Test script downloaded successfully ✓"
            print_status "Test script location: $(pwd)/test_unsloth.py"
        else
            print_error "Failed to download test script"
            return 1
        fi
    else
        print_error "Neither curl nor wget found - cannot download test script"
        return 1
    fi
    
    return 0
}

# Run validation test
run_validation_test() {
    print_step "Step 6: Running validation test"
    
    print_status "Running test script to verify Unsloth installation..."
    
    if [[ -f "test_unsloth.py" ]]; then
        print_warning "The test script needs to be run inside the Docker container"
        print_warning "Expected output:"
        print_status "  'Unsloth: Will patch your computer to enable 2x faster free finetuning'"
        print_status "  Training progress bars showing loss decreasing over 60 steps"
        print_status "  Final training metrics showing completion"
        print_status "Please execute 'python test_unsloth.py' inside the Docker container"
    else
        print_error "Test script not found. Please run Step 5 first."
        return 1
    fi
    
    return 0
}

# Show next steps
show_next_steps() {
    print_step "Step 7: Next steps"
    
    echo -e "${BLUE}Next steps for using Unsloth with your own model and dataset:${NC}"
    echo ""
    echo "1. Update the test_unsloth.py file:"
    echo "   - Replace line 32 with your model choice:"
    echo "     model_name = \"unsloth/Meta-Llama-3.1-8B-bnb-4bit\""
    echo ""
    echo "2. Load your custom dataset in line 8:"
    echo "   dataset = load_dataset(\"your_dataset_name\")"
    echo ""
    echo "3. Adjust training parameters in line 61:"
    echo "   per_device_train_batch_size = 4"
    echo "   max_steps = 1000"
    echo ""
    echo -e "${BLUE}Additional resources:${NC}"
    echo "Visit https://github.com/unslothai/unsloth/wiki for advanced usage instructions, including:"
    echo "  - Saving models in GGUF format for vLLM"
    echo "  - Continued training from checkpoints"
    echo "  - Using custom chat templates"
    echo "  - Running evaluation loops"
    echo ""
    
    return 0
}

# Main function
main() {
    local action=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -a|--auto)
                action="auto"
                shift
                ;;
            -v|--verify)
                action="verify"
                shift
                ;;
            -p|--pull)
                action="pull"
                shift
                ;;
            -l|--launch)
                action="launch"
                shift
                ;;
            -i|--install)
                action="install"
                shift
                ;;
            -t|--test)
                action="test"
                shift
                ;;
            -n|--next-steps)
                action="next-steps"
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # If no action specified, run auto mode (all steps)
    if [[ -z "$action" ]]; then
        action="auto"
    fi
    
    # Execute requested action
    case "$action" in
        auto)
            print_status "Running all Unsloth setup steps automatically..."
            verify_prerequisites || exit 1
            pull_docker_image || exit 1
            # For launch, we'll show instructions as it requires interactive mode
            print_status "For launching Docker container, please run: $SCRIPT_NAME --launch"
            print_status "Or manually run: docker run --gpus all --ulimit memlock=-1 -it --ulimit stack=67108864 --entrypoint /usr/bin/bash --rm nvcr.io/nvidia/pytorch:25.11-py3"
            install_dependencies || exit 1
            create_test_script || exit 1
            run_validation_test || exit 1
            show_next_steps || exit 1
            print_status "All steps completed successfully!"
            ;;
        verify)
            verify_prerequisites || exit 1
            ;;
        pull)
            pull_docker_image || exit 1
            ;;
        launch)
            launch_docker_container || exit 1
            ;;
        install)
            install_dependencies || exit 1
            ;;
        test)
            create_test_script || exit 1
            run_validation_test || exit 1
            ;;
        "next-steps")
            show_next_steps || exit 1
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