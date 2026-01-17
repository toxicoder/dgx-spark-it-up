#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

# Test that the automation script exists
@test "portfolio-optimization automation script exists" {
    [ -f "experiments/portfolio-optimization/portfolio-optimization-automation.sh" ]
}

# Test that the script is executable
@test "portfolio-optimization automation script is executable" {
    [ -x "experiments/portfolio-optimization/portfolio-optimization-automation.sh" ]
}

# Test that the script has proper shebang
@test "portfolio-optimization script has proper shebang" {
    head -n1 "experiments/portfolio-optimization/portfolio-optimization-automation.sh" | grep -q "#!/bin/bash"
}

# Test that README exists
@test "portfolio-optimization README exists" {
    [ -f "experiments/portfolio-optimization/README.md" ]
}

# Test that the script has required functions
@test "portfolio-optimization script has required functions" {
    run grep -q "command_exists\|verify_environment\|setup_repository\|setup_playbook\|start_jupyter" "experiments/portfolio-optimization/portfolio-optimization-automation.sh"
    [ "$status" -eq 0 ]
}

# Test that the script has proper error handling
@test "portfolio-optimization script has error handling" {
    run grep -q "set -e\|exit 1\|ERROR" "experiments/portfolio-optimization/portfolio-optimization-automation.sh"
    [ "$status" -eq 0 ]
}

# Test that the script mentions required tools
@test "portfolio-optimization script mentions required tools" {
    run grep -q "nvidia-smi\|git\|docker" "experiments/portfolio-optimization/portfolio-optimization-automation.sh"
    [ "$status" -eq 0 ]
}

# Test that the script mentions repository cloning
@test "portfolio-optimization script mentions repository cloning" {
    run grep -q "git clone.*dgx-spark-playbooks" "experiments/portfolio-optimization/portfolio-optimization-automation.sh"
    [ "$status" -eq 0 ]
}

# Test that the script mentions JupyterLab
@test "portfolio-optimization script mentions JupyterLab" {
    run grep -q "jupyter-lab\|8888" "experiments/portfolio-optimization/portfolio-optimization-automation.sh"
    [ "$status" -eq 0 ]
}

# Test that the script has proper directory structure
@test "portfolio-optimization has proper directory structure" {
    [ -d "experiments/portfolio-optimization" ]
    [ -d "experiments/portfolio-optimization/tests" ]
}

# Test that the script verifies GPU
@test "portfolio-optimization script verifies GPU" {
    run grep -q "nvidia-smi.*query-gpu" "experiments/portfolio-optimization/portfolio-optimization-automation.sh"
    [ "$status" -eq 0 ]
}

# Test that the script mentions proper access URL
@test "portfolio-optimization script mentions access URL" {
    run grep -q "http://127.0.0.1:8888" "experiments/portfolio-optimization/portfolio-optimization-automation.sh"
    [ "$status" -eq 0 ]
}

# Test that the script handles background processes
@test "portfolio-optimization script handles background processes" {
    run grep -q "wait\|&.*START_PID" "experiments/portfolio-optimization/portfolio-optimization-automation.sh"
    [ "$status" -eq 0 ]
}

# Test that the script validates environment
@test "portfolio-optimization script validates environment" {
    run grep -q "command_exists.*nvidia-smi\|command_exists.*git\|command_exists.*docker" "experiments/portfolio-optimization/portfolio-optimization-automation.sh"
    [ "$status" -eq 0 ]
}