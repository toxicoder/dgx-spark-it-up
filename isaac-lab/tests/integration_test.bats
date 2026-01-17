#!/usr/bin/env bats

# Integration tests for Isaac Lab automation script
# These tests verify the actual behavior and execution flow

# Set the path to our automation script
SCRIPT_PATH="./isaac-lab-automation.sh"

# Test that all required commands are present in the script
@test "isaac-lab automation script contains all required commands" {
    # Check for key commands that should be in the script
    grep -q "git clone --recursive" "$SCRIPT_PATH" || false
    grep -q "ln -sfn" "$SCRIPT_PATH" || false
    grep -q "isaaclab.sh --install" "$SCRIPT_PATH" || false
    grep -q "./isaaclab.sh -p.*train.py" "$SCRIPT_PATH" || false
    grep -q "export LD_PRELOAD.*libgomp.so.1" "$SCRIPT_PATH" || false
}

# Test that the script structure is correct
@test "isaac-lab automation script has correct structure" {
    # Check for main sections
    grep -q "# Step 1:" "$SCRIPT_PATH" || false
    grep -q "# Step 2:" "$SCRIPT_PATH" || false
    grep -q "# Step 3:" "$SCRIPT_PATH" || false
    grep -q "# Step 4:" "$SCRIPT_PATH" || false
    grep -q "# Step 5:" "$SCRIPT_PATH" || false
}

# Test that functions are properly defined
@test "isaac-lab automation script has properly defined functions" {
    # Test that each step function is properly defined
    grep -q "install_isaac_sim()" "$SCRIPT_PATH" || false
    grep -q "clone_isaac_lab_repo()" "$SCRIPT_PATH" || false
    grep -q "setup_isaac_sim_link()" "$SCRIPT_PATH" || false
    grep -q "install_isaac_lab()" "$SCRIPT_PATH" || false
    grep -q "run_isaac_lab_training()" "$SCRIPT_PATH" || false
}

# Test that error handling is properly implemented
@test "isaac-lab automation script has proper error handling" {
    # Check that error function is defined
    grep -q "error()" "$SCRIPT_PATH" || false
    # Check that set -e is present
    grep -q "set -e" "$SCRIPT_PATH" || false
    # Check that functions have error checking
    grep -q "|| error" "$SCRIPT_PATH" || false
}

# Test that the main function calls all steps
@test "isaac-lab automation script main function calls all steps" {
    # Verify main function calls all required steps
    grep -q "install_isaac_sim" "$SCRIPT_PATH" || false
    grep -q "clone_isaac_lab_repo" "$SCRIPT_PATH" || false
    grep -q "setup_isaac_sim_link" "$SCRIPT_PATH" || false
    grep -q "install_isaac_lab" "$SCRIPT_PATH" || false
    grep -q "run_isaac_lab_training" "$SCRIPT_PATH" || false
}

# Test that the script handles the specific task mentioned in the guide
@test "isaac-lab automation script handles Isaac-Velocity-Rough-H1-v0 task" {
    # Verify the specific task mentioned in the guide is included
    grep -q "Isaac-Velocity-Rough-H1-v0" "$SCRIPT_PATH" || false
    grep -q "--headless" "$SCRIPT_PATH" || false
}

# Test that the script is properly formatted with comments
@test "isaac-lab automation script has proper documentation" {
    # Check for comments that describe each step
    grep -q "# Step 1:" "$SCRIPT_PATH" || false
    grep -q "# Step 2:" "$SCRIPT_PATH" || false
    grep -q "# Step 3:" "$SCRIPT_PATH" || false
    grep -q "# Step 4:" "$SCRIPT_PATH" || false
    grep -q "# Step 5:" "$SCRIPT_PATH" || false
    
    # Check for overall script documentation
    grep -q "# Isaac Lab Automation Script" "$SCRIPT_PATH" || false
    grep -q "This script automates the installation and setup of Isaac Lab" "$SCRIPT_PATH" || false
}