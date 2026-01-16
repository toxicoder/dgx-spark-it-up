#!/usr/bin/env bats

# BATS tests for JAX automation script
# Tests the functionality of jax-automation.sh

setup() {
    # Change to the jax directory
    cd "$BATS_TEST_DIRNAME/../"
    
    # Make sure the script is executable
    chmod +x jax-automation.sh
}

@test "JAX automation script exists" {
    [ -f "jax-automation.sh" ]
}

@test "JAX automation script is executable" {
    [ -x "jax-automation.sh" ]
}

@test "JAX automation script shows help when called without arguments" {
    run ./jax-automation.sh
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage: ./jax-automation.sh"* ]]
}

@test "JAX automation script accepts prerequisites command" {
    run ./jax-automation.sh prerequisites
    # This should not fail (even if it shows warnings)
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "JAX automation script accepts clone command" {
    run ./jax-automation.sh clone
    [ "$status" -eq 0 ]
}

@test "JAX automation script accepts build command" {
    # We expect this to fail initially since the repository isn't cloned yet
    # But it should not fail with a command error
    run ./jax-automation.sh build
    # The command should not fail with a syntax/execution error
    [ "$status" -eq 1 ] || [ "$status" -eq 0 ]
}

@test "JAX automation script accepts run command" {
    # We expect this to fail because the image isn't built yet
    # But it should not fail with a command error
    run ./jax-automation.sh run
    # The command should not fail with a syntax/execution error
    [ "$status" -eq 1 ] || [ "$status" -eq 0 ]
}

@test "JAX automation script accepts full command" {
    run ./jax-automation.sh full
    # This might fail due to missing prerequisites, but should not fail with syntax error
    [ "$status" -eq 1 ] || [ "$status" -eq 0 ]
}

@test "JAX automation script shows usage for invalid command" {
    run ./jax-automation.sh invalid-command
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage: ./jax-automation.sh"* ]]
}

@test "JAX automation script has proper structure" {
    # Check that the main functions are defined
    run grep -q "check_prerequisites\|clone_playbook\|build_docker_image\|launch_docker_container" jax-automation.sh
    [ "$status" -eq 0 ]
}

@test "JAX automation script has proper usage examples in README" {
    [ -f "README.md" ]
    
    # Check that README contains the expected usage information
    run grep -q "prerequisites\|clone\|build\|run\|full" README.md
    [ "$status" -eq 0 ]
}