#!/usr/bin/env bats

load '../test_helper/bats-support/load'
load '../test_helper/bats-assert/load'

# Test that the automation script exists
@test "cuda-x-data-science automation script exists" {
    [ -f "cuda-x-data-science/cuda-x-data-science-automation.sh" ]
}

# Test that the script is executable
@test "cuda-x-data-science automation script is executable" {
    [ -x "cuda-x-data-science/cuda-x-data-science-automation.sh" ]
}

# Test that the script has proper shebang
@test "cuda-x-data-science script has proper shebang" {
    head -n1 "cuda-x-data-science/cuda-x-data-science-automation.sh" | grep -q "#!/bin/bash"
}

# Test that README exists
@test "cuda-x-data-science README exists" {
    [ -f "cuda-x-data-science/README.md" ]
}

# Test that the script has required functions
@test "cuda-x-data-science script has required functions" {
    run grep -q "verify_system_requirements\|install_data_science_libraries\|activate_environment\|clone_repository\|run_notebooks" "cuda-x-data-science/cuda-x-data-science-automation.sh"
    [ "$status" -eq 0 ]
}

# Test that the script has proper error handling
@test "cuda-x-data-science script has error handling" {
    run grep -q "error\|command_exists" "cuda-x-data-science/cuda-x-data-science-automation.sh"
    [ "$status" -eq 0 ]
}

# Test that the script uses conda properly
@test "cuda-x-data-science script uses conda correctly" {
    run grep -q "conda create.*rapids.*python.*cuda-version" "cuda-x-data-science/cuda-x-data-science-automation.sh"
    [ "$status" -eq 0 ]
}

# Test that the script has proper logging
@test "cuda-x-data-science script has logging functions" {
    run grep -q "log\|warn\|error" "cuda-x-data-science/cuda-x-data-science-automation.sh"
    [ "$status" -eq 0 ]
}

# Test that the script has proper structure
@test "cuda-x-data-science script has proper structure" {
    run grep -q "main\|if.*BASH_SOURCE.*0.*0" "cuda-x-data-science/cuda-x-data-science-automation.sh"
    [ "$status" -eq 0 ]
}

# Test that the script mentions required tools
@test "cuda-x-data-science script mentions required tools" {
    run grep -q "nvcc\|nvidia-smi\|conda" "cuda-x-data-science/cuda-x-data-science-automation.sh"
    [ "$status" -eq 0 ]
}

# Test that the script mentions repository cloning
@test "cuda-x-data-science script mentions repository cloning" {
    run grep -q "git clone.*dgx-spark-playbooks" "cuda-x-data-science/cuda-x-data-science-automation.sh"
    [ "$status" -eq 0 ]
}

# Test that the script mentions notebook execution
@test "cuda-x-data-science script mentions notebook execution" {
    run grep -q "jupyter nbconvert.*execute" "cuda-x-data-science/cuda-x-data-science-automation.sh"
    [ "$status" -eq 0 ]
}

# Test that the script has proper directory structure
@test "cuda-x-data-science has proper directory structure" {
    [ -d "cuda-x-data-science" ]
    [ -d "cuda-x-data-science/tests" ]
}

# Test that the script mentions kaggle.json
@test "cuda-x-data-science script mentions kaggle.json" {
    run grep -q "kaggle.json" "cuda-x-data-science/cuda-x-data-science-automation.sh"
    [ "$status" -eq 0 ]
}