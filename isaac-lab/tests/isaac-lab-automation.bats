#!/usr/bin/env bats

# Set the path to our automation script
SCRIPT_PATH="./isaac-lab-automation.sh"

# Test that the script exists
@test "isaac-lab automation script exists" {
    [ -f "$SCRIPT_PATH" ]
}

# Test that the script is executable
@test "isaac-lab automation script is executable" {
    [ -x "$SCRIPT_PATH" ]
}

# Test that the script can be parsed without syntax errors
@test "isaac-lab automation script syntax is valid" {
    run bash -n "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

# Test that the script has proper function definitions
@test "isaac-lab automation script has expected functions" {
    # Check that the script contains the main functions we expect
    grep -q "install_isaac_sim" "$SCRIPT_PATH"
    grep -q "clone_isaac_lab_repo" "$SCRIPT_PATH"
    grep -q "setup_isaac_sim_link" "$SCRIPT_PATH"
    grep -q "install_isaac_lab" "$SCRIPT_PATH"
    grep -q "run_isaac_lab_training" "$SCRIPT_PATH"
    grep -q "main" "$SCRIPT_PATH"
}

# Test that the script contains required elements
@test "isaac-lab automation script contains required elements" {
    # Check for key elements in the script
    grep -q "set -e" "$SCRIPT_PATH"
    grep -q "log()" "$SCRIPT_PATH"
    grep -q "error()" "$SCRIPT_PATH"
    grep -q "export ISAACSIM_PATH" "$SCRIPT_PATH"
    grep -q "export LD_PRELOAD" "$SCRIPT_PATH"
    grep -q "ln -sfn" "$SCRIPT_PATH"
    grep -q "isaaclab.sh --install" "$SCRIPT_PATH"
}

# Test that the script has proper error handling
@test "isaac-lab automation script contains error handling" {
    run grep -c "error" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
    [ "$output" -gt 0 ]
}

# Test that the script has proper exit handling
@test "isaac-lab automation script has set -e for error handling" {
    grep -q "set -e" "$SCRIPT_PATH"
}

# Test that the script uses the correct git clone command for Isaac Lab
@test "isaac-lab automation script uses correct Isaac Lab clone command" {
    grep -q "git clone --recursive" "$SCRIPT_PATH"
}

# Test that the script handles directory changes correctly
@test "isaac-lab automation script contains proper directory handling" {
    grep -q "cd IsaacLab" "$SCRIPT_PATH"
}

# Test that the script creates symbolic link properly
@test "isaac-lab automation script creates symbolic link" {
    # This test would require mocking the environment
    # We can at least verify the command exists in the script
    grep -q "ln -sfn" "$SCRIPT_PATH"
}

# Test that the script has proper installation command
@test "isaac-lab automation script has proper install command" {
    grep -q "./isaaclab.sh --install" "$SCRIPT_PATH"
}

# Test that the script has proper training command
@test "isaac-lab automation script has proper training command" {
    grep -q "./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py" "$SCRIPT_PATH"
}

# Test that the script sets LD_PRELOAD properly
@test "isaac-lab automation script sets LD_PRELOAD" {
    grep -q "export LD_PRELOAD.*libgomp.so.1" "$SCRIPT_PATH"
}

# Test that the script has the expected file structure
@test "isaac-lab automation script has expected file structure" {
    # Verify that key functions are present
    grep -q "install_isaac_sim\|clone_isaac_lab_repo\|setup_isaac_sim_link\|install_isaac_lab\|run_isaac_lab_training" "$SCRIPT_PATH"
}

# Test that the script includes the required documentation
@test "isaac-lab automation script includes proper documentation" {
    grep -q "# Isaac Lab Automation Script" "$SCRIPT_PATH"
    grep -q "set -e" "$SCRIPT_PATH"
    grep -q "log\|error" "$SCRIPT_PATH"
}