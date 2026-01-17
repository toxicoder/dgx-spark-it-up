#!/usr/bin/env bats

# Load test helpers
load '../test_helper/load.bash'

# Set the path to our automation script
SCRIPT_PATH="./isaac-sim-automation.sh"

# Test that the script exists
@test "script exists" {
    [ -f "$SCRIPT_PATH" ]
}

# Test that the script is executable
@test "script is executable" {
    [ -x "$SCRIPT_PATH" ]
}

# Test that the script can be parsed without syntax errors
@test "script syntax is valid" {
    run bash -n "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

# Test that the script has proper function definitions
@test "script has expected functions" {
    # Check that the script contains the main functions we expect
    grep -q "install_dependencies" "$SCRIPT_PATH"
    grep -q "clone_isaac_sim" "$SCRIPT_PATH"
    grep -q "build_isaac_sim" "$SCRIPT_PATH"
    grep -q "setup_environment" "$SCRIPT_PATH"
    grep -q "run_isaac_sim" "$SCRIPT_PATH"
    grep -q "clone_isaac_lab" "$SCRIPT_PATH"
    grep -q "setup_isaac_sim_link" "$SCRIPT_PATH"
    grep -q "install_isaac_lab" "$SCRIPT_PATH"
    grep -q "run_isaac_lab_training" "$SCRIPT_PATH"
}

# Test that the script contains required elements
@test "script contains required elements" {
    # Check for key elements in the script
    grep -q "set -e" "$SCRIPT_PATH"
    grep -q "log()" "$SCRIPT_PATH"
    grep -q "error()" "$SCRIPT_PATH"
    grep -q "export ISAACSIM_PATH" "$SCRIPT_PATH"
    grep -q "export LD_PRELOAD" "$SCRIPT_PATH"
}

# Test that the script has proper error handling
@test "script contains error handling" {
    run grep -c "error" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
    [ "$output" -gt 0 ]
}

# Test that the script has proper exit handling
@test "script has set -e for error handling" {
    grep -q "set -e" "$SCRIPT_PATH"
}

# Test that the script uses the correct git clone command for Isaac Sim
@test "script uses correct Isaac Sim clone command" {
    grep -q "git clone --depth=1 --recursive --branch=develop" "$SCRIPT_PATH"
}

# Test that the script uses the correct git clone command for Isaac Lab
@test "script uses correct Isaac Lab clone command" {
    grep -q "git clone --recursive" "$SCRIPT_PATH"
}

# Test that the script has proper build verification
@test "script verifies build success" {
    grep -q "BUILD (RELEASE) SUCCEEDED" "$SCRIPT_PATH"
}

# Test that the script handles directory changes correctly
@test "script contains proper directory handling" {
    grep -q "cd IsaacSim" "$SCRIPT_PATH"
    grep -q "cd IsaacLab" "$SCRIPT_PATH"
    grep -q "cd .." "$SCRIPT_PATH"
}