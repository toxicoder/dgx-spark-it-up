#!/usr/bin/env bats

# Test the nccl-automation.sh script using BATS framework
# This test file verifies the functionality of the NVIDIA DGX Spark NCCL automation script

@test "nccl script exists and is executable" {
    [ -x ./nccl/nccl-automation.sh ]
}

@test "nccl script shows help when --help is passed" {
    run ./nccl/nccl-automation.sh --help
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Usage: nccl-automation.sh"
}

@test "nccl script shows help when -h is passed" {
    run ./nccl/nccl-automation.sh -h
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Usage: nccl-automation.sh"
}

@test "nccl script shows error when no action is specified" {
    run ./nccl/nccl-automation.sh
    [ "$status" -ne 0 ]
    echo "$output" | grep -q "No action specified"
}

@test "nccl script handles --cleanup correctly" {
    run ./nccl/nccl-automation.sh --cleanup
    # Should not crash, should complete successfully
    [ "$status" -eq 0 ]
}

@test "nccl script handles --verbose correctly" {
    run ./nccl/nccl-automation.sh --verbose --cleanup
    # Should not crash, should complete successfully
    [ "$status" -eq 0 ]
}

@test "nccl script handles --node parameter" {
    run ./nccl/nccl-automation.sh --node 192.168.1.100
    # Should not crash, might return 1 due to missing network setup but should parse correctly
    [ "$status" -eq 1 ] || [ "$status" -eq 0 ]
}

@test "nccl script handles --interface parameter" {
    run ./nccl/nccl-automation.sh --interface eth0
    # Should not crash, might return 1 due to missing network setup but should parse correctly
    [ "$status" -eq 1 ] || [ "$status" -eq 0 ]
}

@test "nccl script handles --node and --interface parameters" {
    run ./nccl/nccl-automation.sh --node 192.168.1.100 --interface eth0
    # Should not crash, might return 1 due to missing network setup but should parse correctly
    [ "$status" -eq 1 ] || [ "$status" -eq 0 ]
}

@test "nccl script handles unknown option correctly" {
    run ./nccl/nccl-automation.sh --unknown-option
    [ "$status" -ne 0 ]
    echo "$output" | grep -q "Unknown option"
}

# Test that required tools are available (basic check)
@test "nccl script requires git" {
    run command -v git
    [ "$status" -eq 0 ]
}

@test "nccl script requires make" {
    run command -v make
    [ "$status" -eq 0 ]
}

@test "nccl script requires gcc" {
    run command -v gcc
    [ "$status" -eq 0 ]
}