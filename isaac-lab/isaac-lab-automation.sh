#!/bin/bash

# Isaac Lab Automation Script.
#
# This script automates the installation and setup of Isaac Lab according to the NVIDIA guide, including repository cloning, symbolic link creation, and training execution.

set -e  # Exit on any error

# log - Log informational messages.
#
# Logs informational messages to stdout with [INFO] prefix.
#
# Parameters:
#   $1 (String) - Message to log.
#
# Returns:
#   0 - Success.
log() {
    echo "[INFO] $1"
}

# error - Log error messages and exit.
#
# Logs error messages to stderr with [ERROR] prefix and exits with code 1.
#
# Parameters:
#   $1 (String) - Error message to log.
#
# Returns:
#   1 - Error occurred.
error() {
    echo "[ERROR] $1" >&2
    exit 1
}

# check_command - Check if last command succeeded.
#
# Checks if the last executed command returned exit code 0.
#
# Parameters:
#   $1 (String) - Error message to display if command failed.
#
# Returns:
#   0 - Command succeeded.
check_command() {
    if [ $? -ne 0 ]; then
        error "$1"
    fi
}

# install_isaac_sim - Check Isaac Sim installation.
#
# Checks if Isaac Sim is installed and the ISAACSIM_PATH environment variable is set correctly.
#
# Returns:
#   0 - Isaac Sim installation verified.
#   1 - Installation or path verification failed.
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

# clone_isaac_lab_repo - Clone Isaac Lab repository.
#
# Clones the Isaac Lab repository from GitHub if it doesn't already exist.
#
# Returns:
#   0 - Repository cloned or already exists.
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

# setup_isaac_sim_link - Create symbolic link to Isaac Sim.
#
# Creates a symbolic link to the Isaac Sim installation directory.
#
# Returns:
#   0 - Symbolic link created successfully.
#   1 - Failed to create symbolic link.
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

# install_isaac_lab - Install Isaac Lab.
#
# Installs Isaac Lab by running the installation script.
#
# Returns:
#   0 - Installation completed successfully.
#   1 - Installation failed.
install_isaac_lab() {
    log "Step 4: Installing Isaac Lab..."
    
    if [ ! -f "./isaaclab.sh" ]; then
        error "isaaclab.sh not found in IsaacLab directory"
    fi
    
    ./isaaclab.sh --install || error "Failed to install Isaac Lab"
    
    log "Isaac Lab installed successfully"
}

# run_isaac_lab_training - Run Isaac Lab training in headless mode.
#
# Runs Isaac Lab training in headless mode with specified task.
#
# Returns:
#   0 - Training completed successfully.
#   1 - Training failed.
run_isaac_lab_training() {
    log "Step 5: Running Isaac Lab training..."
    
    # Set LD_PRELOAD as required
    export LD_PRELOAD="$LD_PRELOAD:/lib/aarch64-linux-gnu/libgomp.so.1"
    
    # Run training with headless mode
    log "Running Isaac Lab training in headless mode..."
    ./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py --task=Isaac-Velocity-Rough-H1-v0 --headless || error "Failed to run Isaac Lab training in headless mode"
    
    log "Isaac Lab training completed successfully in headless mode"
}

# run_isaac_lab_training_visualization - Run Isaac Lab training with visualization.
#
# Runs Isaac Lab training with visualization enabled.
#
# Returns:
#   0 - Training completed successfully.
#   1 - Training failed.
run_isaac_lab_training_visualization() {
    log "Step 5b: Running Isaac Lab training with visualization..."
    
    # Set LD_PRELOAD as required
    export LD_PRELOAD="$LD_PRELOAD:/lib/aarch64-linux-gnu/libgomp.so.1"
    
    # Run training with visualization mode
    log "Running Isaac Lab training with visualization..."
    ./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py --task=Isaac-Velocity-Rough-H1-v0 || error "Failed to run Isaac Lab training with visualization"
    
    log "Isaac Lab training completed successfully with visualization"
}

# main - Main execution function.
#
# Main execution function that orchestrates the complete Isaac Lab setup process.
#
# Parameters:
#   $@ (All) - Command line arguments.
#
# Returns:
#   0 - Script completed successfully.
#   1 - Script failed at some point.
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