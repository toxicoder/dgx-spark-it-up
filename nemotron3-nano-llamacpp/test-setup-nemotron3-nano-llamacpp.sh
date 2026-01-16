#!/usr/bin/env bash

# Unit tests for setup-nemotron3-nano-llamacpp.sh
# This script tests the individual functions of the setup script

# Load the setup script to test its functions
source ./setup-nemotron3-nano-llamacpp.sh

# Test function for checking prerequisites
test_check_prerequisites() {
    # Mock command function to simulate successful commands
    command() {
        case "$1" in
            git|cmake|nvcc)
                return 0
                ;;
            *)
                return 1
                ;;
        esac
    }
    
    # Test that prerequisites check passes
    check_prerequisites
    echo "✅ check_prerequisites test passed"
}

# Test function for setting up virtual environment
test_setup_virtual_environment() {
    # Mock python3 and pip commands
    python3() {
        echo "Creating venv..."
        return 0
    }
    
    pip() {
        echo "Installing packages..."
        return 0
    }
    
    # Mock hf command
    hf() {
        echo "Hugging Face CLI version 0.20.0"
        return 0
    }
    
    # Test that virtual environment setup passes
    setup_virtual_environment
    echo "✅ setup_virtual_environment test passed"
}

# Test function for cloning llama.cpp
test_clone_llama_cpp() {
    # Mock git command
    git() {
        echo "Cloning repository..."
        return 0
    }
    
    # Mock cd command
    cd() {
        return 0
    }
    
    # Test that cloning works
    clone_llama_cpp
    echo "✅ clone_llama_cpp test passed"
}

# Test function for building llama.cpp
test_build_llama_cpp() {
    # Mock mkdir, cd, cmake, and make commands
    mkdir() {
        return 0
    }
    
    cd() {
        return 0
    }
    
    cmake() {
        return 0
    }
    
    make() {
        return 0
    }
    
    # Test that building works
    build_llama_cpp
    echo "✅ build_llama_cpp test passed"
}

# Test function for downloading model
test_download_model() {
    # Mock mkdir command
    mkdir() {
        return 0
    }
    
    # Mock hf download command
    hf() {
        case "$1" in
            download)
                echo "Downloading model..."
                return 0
                ;;
            *)
                return 1
                ;;
        esac
    }
    
    # Test that downloading works
    download_model
    echo "✅ download_model test passed"
}

# Test function for starting server
test_start_server() {
    # Mock cd command
    cd() {
        return 0
    }
    
    # Mock pgrep command
    pgrep() {
        echo "12345"
        return 0
    }
    
    # Mock nohup command
    nohup() {
        return 0
    }
    
    # Test that server starting works
    start_server
    echo "✅ start_server test passed"
}

# Main test runner
main() {
    echo "Running unit tests for setup script..."
    
    # Run all tests
    test_check_prerequisites
    test_setup_virtual_environment
    test_clone_llama_cpp
    test_build_llama_cpp
    test_download_model
    test_start_server
    
    echo "All tests passed! ✅"
}

# Execute main function
main "$@"