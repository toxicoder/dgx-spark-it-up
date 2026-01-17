#!/bin/bash

# CUDA-X Data Science Automation Script.
#
# This script automates the setup and execution of the CUDA-X Data Science workflow, including environment setup, library installation, repository cloning, and notebook execution.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: Verify system requirements
verify_system_requirements() {
    log "Step 1: Verifying system requirements"
    
    # Check if nvcc is available
    if ! command_exists nvcc; then
        error "nvcc not found. Please install CUDA toolkit."
    fi
    
    # Check CUDA version
    local cuda_version=$(nvcc --version 2>&1 | grep -o "Cuda version [0-9.]*" | cut -d' ' -f3)
    if [[ -z "$cuda_version" ]]; then
        warn "Could not determine CUDA version"
    else
        log "CUDA version: $cuda_version"
        if [[ "$cuda_version" != *"13."* ]]; then
            warn "CUDA 13 is recommended but found version $cuda_version"
        fi
    fi
    
    # Check if nvidia-smi is available
    if command_exists nvidia-smi; then
        local gpu_info=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n1)
        log "GPU detected: $gpu_info"
    else
        warn "nvidia-smi not found, GPU detection may be limited"
    fi
    
    # Check if conda is installed
    if ! command_exists conda; then
        error "conda not found. Please install conda first."
    fi
    
    log "System requirements verified successfully"
}

# Step 2: Install Data Science libraries
install_data_science_libraries() {
    log "Step 2: Installing Data Science libraries"
    
    # Create conda environment with CUDA-X libraries
    log "Creating conda environment 'rapids-test' with CUDA-X libraries..."
    
    conda create -n rapids-test \
        -c rapidsai-nightly \
        -c conda-forge \
        -c nvidia \
        rapids=25.10 \
        python=3.12 \
        'cuda-version=13.0' \
        jupyter \
        hdbscan \
        umap-learn \
        --yes
    
    log "Data Science libraries installed successfully"
}

# Step 3: Activate conda environment
activate_environment() {
    log "Step 3: Activating conda environment"
    
    # Activate the environment
    conda activate rapids-test
    
    log "Environment 'rapids-test' activated"
}

# Step 4: Clone the playbook repository
clone_repository() {
    log "Step 4: Cloning playbook repository"
    
    # Clone the repository
    git clone https://github.com/NVIDIA/dgx-spark-playbooks
    
    # Create assets directory
    mkdir -p dgx-spark-playbooks/assets
    
    # Check if kaggle.json exists in current directory
    if [[ -f "kaggle.json" ]]; then
        log "Found kaggle.json in current directory, copying to assets folder"
        cp kaggle.json dgx-spark-playbooks/assets/
    else
        warn "kaggle.json not found in current directory. Please place it in the assets folder manually."
    fi
    
    log "Repository cloned successfully"
}

# Step 5: Run the notebooks
run_notebooks() {
    log "Step 5: Running notebooks"
    
    # Change to the playbooks directory
    cd dgx-spark-playbooks
    
    # Run the first notebook (cudf_pandas_demo.ipynb)
    log "Starting cudf_pandas_demo.ipynb notebook..."
    jupyter nbconvert --to notebook --execute cudf_pandas_demo.ipynb --output executed_cudf_pandas_demo.ipynb &
    
    # Run the second notebook (cuml_sklearn_demo.ipynb)
    log "Starting cuml_sklearn_demo.ipynb notebook..."
    jupyter nbconvert --to notebook --execute cuml_sklearn_demo.ipynb --output executed_cuml_sklearn_demo.ipynb &
    
    log "Notebooks started. Check the output files for results."
    
    # Return to original directory
    cd ..
}

# Main execution function
main() {
    log "Starting CUDA-X Data Science Automation"
    
    # Verify system requirements
    verify_system_requirements
    
    # Install Data Science libraries
    install_data_science_libraries
    
    # Activate environment
    activate_environment
    
    # Clone repository
    clone_repository
    
    # Run notebooks
    run_notebooks
    
    log "CUDA-X Data Science workflow completed successfully!"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi