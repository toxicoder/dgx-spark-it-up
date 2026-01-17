#!/bin/bash

# Isaac Lab Automation Script
# This script automates the installation and setup of Isaac Lab according to the NVIDIA guide

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

# Step 1: Install Isaac Sim (Assumed to be done already)
install_isaac_sim() {
    log "Step 1: Checking Isaac Sim installation..."
    
    # Check if ISAACSIM_PATH is set
    if [ -z "$ISAACSIM_PATH" ]; then
        log "ISAACSIM_PATH not set. Please ensure Isaac Sim is installed and ISAACSIM_PATH is set."
        log "If you have installed Isaac Sim in a different location, please set ISAACSIM_PATH accordingly."
        return 1
    fi
    
    # Check if the path exists
    if [ ! -d "$ISAACSIM_PATH" ]; then
        error "ISAACSIM_PATH directory does not exist: $ISAACSIM_PATH"
    fi
    
    log "Isaac Sim installation found at: $ISAACSIM_PATH"
}

# Step 2: Clone the Isaac Lab repository
clone_isaac_lab_repo() {
    log "Step 2: Cloning Isaac Lab repository..."
    
    if [ ! -d "IsaacLab" ]; then
        git clone --recursive https://github.com/isaac-sim/IsaacLab || error "Failed to clone Isaac Lab repository"
        log "Isaac Lab repository cloned successfully"
    else
        log "Isaac Lab repository already exists"
    fi
    
    cd IsaacLab
}

# Step 3: Create symbolic link to Isaac Sim installation
setup_isaac_sim_link() {
    log "Step 3: Creating symbolic link to Isaac Sim installation..."
    
    # Check if ISAACSIM_PATH is set
    if [ -z "$ISAACSIM_PATH" ]; then
        error "ISAACSIM_PATH environment variable not set"
    fi
    
    # Create symbolic link
    ln -sfn "${ISAACSIM_PATH}" "${PWD}/_isaac_sim" || error "Failed to create symbolic link"
    
    # Verify the link
    if [ ! -L "${PWD}/_isaac_sim" ]; then
        error "Symbolic link not created properly"
    fi
    
    # Verify the link points to the correct location
    if [ ! -d "${PWD}/_isaac_sim" ]; then
        error "Symbolic link does not point to a valid directory"
    fi
    
    # Verify that python.sh exists in the linked directory
    if [ ! -f "${PWD}/_isaac_sim/python.sh" ]; then
        error "python.sh not found in the linked Isaac Sim directory"
    fi
    
    log "Symbolic link created successfully: ${PWD}/_isaac_sim -> ${ISAACSIM_PATH}"
}

# Step 4: Install Isaac Lab
install_isaac_lab() {
    log "Step 4: Installing Isaac Lab..."
    
    if [ ! -f "./isaaclab.sh" ]; then
        error "isaaclab.sh not found in IsaacLab directory"
    fi
    
    ./isaaclab.sh --install || error "Failed to install Isaac Lab"
    
    log "Isaac Lab installed successfully"
}

# Step 5: Run Isaac Lab training
run_isaac_lab_training() {
    log "Step 5: Running Isaac Lab training..."
    
    # Set LD_PRELOAD as required
    export LD_PRELOAD="$LD_PRELOAD:/lib/aarch64-linux-gnu/libgomp.so.1"
    
    # Run training with headless mode
    log "Running Isaac Lab training in headless mode..."
    ./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py --task=Isaac-Velocity-Rough-H1-v0 --headless || error "Failed to run Isaac Lab training in headless mode"
    
    log "Isaac Lab training completed successfully in headless mode"
}

# Step 5b: Run Isaac Lab training with visualization (additional option)
run_isaac_lab_training_visualization() {
    log "Step 5b: Running Isaac Lab training with visualization..."
    
    # Set LD_PRELOAD as required
    export LD_PRELOAD="$LD_PRELOAD:/lib/aarch64-linux-gnu/libgomp.so.1"
    
    # Run training with visualization mode
    log "Running Isaac Lab training with visualization..."
    ./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py --task=Isaac-Velocity-Rough-H1-v0 || error "Failed to run Isaac Lab training with visualization"
    
    log "Isaac Lab training completed successfully with visualization"
}

# Main execution function
main() {
    log "Starting Isaac Lab automation..."
    
    # Step 1: Install Isaac Sim (assumed)
    install_isaac_sim
    
    # Step 2: Clone Isaac Lab repository
    clone_isaac_lab_repo
    
    # Step 3: Create symbolic link to Isaac Sim
    setup_isaac_sim_link
    
    # Step 4: Install Isaac Lab
    install_isaac_lab
    
    # Step 5: Run Isaac Lab training (headless mode)
    run_isaac_lab_training
    
    # Step 5b: Run Isaac Lab training with visualization (additional option)
    # Uncomment the following line to run with visualization mode
    # run_isaac_lab_training_visualization
    
    log "All steps completed successfully!"
    log "Isaac Lab is now ready for use."
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi