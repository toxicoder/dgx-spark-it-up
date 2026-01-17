#!/usr/bin/env bats

# Simple test to verify the automation script structure

@test "automation script exists" {
    [ -f "./isaac-sim-automation.sh" ]
}

@test "automation script is executable" {
    [ -x "./isaac-sim-automation.sh" ]
}

@test "automation script has proper structure" {
    # Check that main functions are defined
    grep -q "install_dependencies" "./isaac-sim-automation.sh"
    grep -q "clone_isaac_sim" "./isaac-sim-automation.sh"
    grep -q "build_isaac_sim" "./isaac-sim-automation.sh"
    grep -q "setup_environment" "./isaac-sim-automation.sh"
    grep -q "run_isaac_sim" "./isaac-sim-automation.sh"
    grep -q "clone_isaac_lab" "./isaac-sim-automation.sh"
    grep -q "setup_isaac_sim_link" "./isaac-sim-automation.sh"
    grep -q "install_isaac_lab" "./isaac-sim-automation.sh"
    grep -q "run_isaac_lab_training" "./isaac-sim-automation.sh"
}

@test "automation script syntax is valid" {
    bash -n "./isaac-sim-automation.sh"
}