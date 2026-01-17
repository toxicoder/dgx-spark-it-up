#!/bin/bash

# Isaac Sim Automation Script
# This script automates the installation and setup of Isaac Sim and Isaac Lab

set -e  # Exit on any error

# Function to log messages
log() {
    echo "[INFO] $1"
}

# Function to log errors
error() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Function to check if command succeeded
check_command() {
    if [ $? -ne 0 ]; then
        error "$1"
    fi
}

# Step 1: Install gcc-11 and git-lfs
install_dependencies() {
    log "Installing gcc-11 and git-lfs..."
    sudo apt update || error "Failed to update package list"
    sudo apt install -y gcc-11 g++-11 git-lfs || error "Failed to install dependencies"
    
    # Set gcc-11 as default
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 200 || error "Failed to set gcc-11 as default"
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 200 || error "Failed to set g++-11 as default"
    
    # Verify versions
    gcc --version | grep -q "gcc-11" || error "gcc-11 not found"
    g++ --version | grep -q "g++-11" || error "g++-11 not found"
    
    log "Dependencies installed successfully"
}

# Step 2: Clone Isaac Sim repository
clone_isaac_sim() {
    log "Cloning Isaac Sim repository..."
    if [ ! -d "IsaacSim" ]; then
        git clone --depth=1 --recursive --branch=develop https://github.com/isaac-sim/IsaacSim || error "Failed to clone Isaac Sim"
    else
        log "Isaac Sim repository already exists"
    fi
    
    cd IsaacSim
    git lfs install || error "Failed to install git-lfs"
    git lfs pull || error "Failed to pull LFS files"
    
    log "Isaac Sim cloned successfully"
}

# Step 3: Build Isaac Sim
build_isaac_sim() {
    log "Building Isaac Sim..."
    if [ ! -f "./build.sh" ]; then
        error "build.sh not found in IsaacSim directory"
    fi
    
    ./build.sh || error "Failed to build Isaac Sim"
    
    # Check if build was successful
    if ! grep -q "BUILD (RELEASE) SUCCEEDED" build.log; then
        error "Isaac Sim build failed"
    fi
    
    log "Isaac Sim built successfully"
}

# Step 4: Set up environment variables
setup_environment() {
    log "Setting up environment variables..."
    export ISAACSIM_PATH="${PWD}/_build/linux-aarch64/release"
    export ISAACSIM_PYTHON_EXE="${ISAACSIM_PATH}/python.sh"
    
    if [ ! -d "$ISAACSIM_PATH" ]; then
        error "ISAACSIM_PATH directory not found"
    fi
    
    log "Environment variables set successfully"
}

# Step 5: Run Isaac Sim
run_isaac_sim() {
    log "Running Isaac Sim..."
    if [ ! -f "${ISAACSIM_PATH}/isaac-sim.sh" ]; then
        error "isaac-sim.sh not found"
    fi
    
    # Set LD_PRELOAD as required
    export LD_PRELOAD="$LD_PRELOAD:/lib/aarch64-linux-gnu/libgomp.so.1"
    
    log "Isaac Sim is ready to run. Use: ${ISAACSIM_PATH}/isaac-sim.sh"
}

# Step 6: Clone and setup Isaac Lab
clone_isaac_lab() {
    log "Cloning Isaac Lab repository..."
    if [ ! -d "IsaacLab" ]; then
        git clone --recursive https://github.com/isaac-sim/IsaacLab || error "Failed to clone Isaac Lab"
    else
        log "Isaac Lab repository already exists"
    fi
    
    cd IsaacLab
    log "Isaac Lab cloned successfully"
}

# Step 7: Create symbolic link to Isaac Sim
setup_isaac_sim_link() {
    log "Setting up symbolic link to Isaac Sim..."
    
    if [ -z "$ISAACSIM_PATH" ]; then
        error "ISAACSIM_PATH environment variable not set"
    fi
    
    # Create symbolic link
    ln -sfn "${ISAACSIM_PATH}" "${PWD}/_isaac_sim" || error "Failed to create symbolic link"
    
    # Verify the link
    if [ ! -L "${PWD}/_isaac_sim" ]; then
        error "Symbolic link not created properly"
    fi
    
    log "Symbolic link created successfully"
}

# Step 8: Install Isaac Lab
install_isaac_lab() {
    log "Installing Isaac Lab..."
    if [ ! -f "./isaaclab.sh" ]; then
        error "isaaclab.sh not found in IsaacLab directory"
    fi
    
    ./isaaclab.sh --install || error "Failed to install Isaac Lab"
    
    log "Isaac Lab installed successfully"
}

# Step 9: Run Isaac Lab training (headless mode)
run_isaac_lab_training() {
    log "Running Isaac Lab training in headless mode..."
    
    # Set LD_PRELOAD as required
    export LD_PRELOAD="$LD_PRELOAD:/lib/aarch64-linux-gnu/libgomp.so.1"
    
    # Run training with headless mode
    ./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py --task=Isaac-Velocity-Rough-H1-v0 --headless || error "Failed to run Isaac Lab training"
    
    log "Isaac Lab training completed successfully"
}

# Main execution function
main() {
    log "Starting Isaac Sim and Isaac Lab automation..."
    
    # Step 1: Install dependencies
    install_dependencies
    
    # Step 2: Clone Isaac Sim
    clone_isaac_sim
    
    # Step 3: Build Isaac Sim
    build_isaac_sim
    
    # Step 4: Set up environment
    setup_environment
    
    # Step 5: Run Isaac Sim
    run_isaac_sim
    
    # Step 6: Clone Isaac Lab
    cd ..
    clone_isaac_lab
    
    # Step 7: Setup Isaac Sim link for Isaac Lab
    setup_isaac_sim_link
    
    # Step 8: Install Isaac Lab
    install_isaac_lab
    
    # Step 9: Run training
    run_isaac_lab_training
    
    log "All steps completed successfully!"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi