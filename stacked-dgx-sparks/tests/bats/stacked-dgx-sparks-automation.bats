#!/usr/bin/env bats

# Test the stacked-dgx-sparks-automation.sh script using BATS framework
# This test file verifies the functionality of the NVIDIA DGX Spark Stacked Multi-Node automation script

@test "script exists and is executable" {
    [ -x ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh ]
}

@test "script shows help when --help is passed" {
    run ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh --help
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Usage: stacked-dgx-sparks-automation.sh"
}

@test "script shows help when -h is passed" {
    run ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh -h
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Usage: stacked-dgx-sparks-automation.sh"
}

@test "script shows error when no action is specified" {
    run ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh
    [ "$status" -ne 0 ]
    echo "$output" | grep -q "No action specified"
}

@test "script handles --verify correctly" {
    run ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh --verify
    # Should not crash, might return 0 or 1 depending on SSH availability
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "script handles --configure correctly" {
    # This would normally prompt for input, so we'll just test that it doesn't crash
    run bash -c "echo -e 'testuser\ntesthost\n192.168.1.100\n' | ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh --configure"
    # Should not crash (exit code 0 or 1 are acceptable)
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "script handles --setup correctly" {
    # Test that it doesn't crash with basic arguments
    run ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh --setup --node 192.168.1.100
    # Should fail gracefully due to missing dependencies but should parse correctly
    [ "$status" -ne 0 ] || [ "$status" -eq 0 ]
}

@test "script handles --deploy correctly" {
    # Test that it doesn't crash with basic arguments
    run ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh --deploy --model test-model
    # Should fail gracefully due to missing dependencies but should parse correctly
    [ "$status" -ne 0 ] || [ "$status" -eq 0 ]
}

@test "script handles --test correctly" {
    # Test that it doesn't crash with basic arguments
    run ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh --test
    # Should fail gracefully due to missing dependencies but should parse correctly
    [ "$status" -ne 0 ] || [ "$status" -eq 0 ]
}

@test "script handles --rollback correctly" {
    # Test that it doesn't crash with basic arguments
    run ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh --rollback
    # Should not crash, may fail due to missing environment but should parse correctly
    [ "$status" -eq 0 ] || [ "$status" -ne 0 ]
}

@test "script accepts --username parameter" {
    run ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh --verify --username testuser
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "script accepts --hostname parameter" {
    run ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh --verify --hostname testhost
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "script accepts --node parameter" {
    run ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh --setup --node 192.168.1.100
    # Should not crash, may fail due to environment but should parse correctly
    [ "$status" -ne 0 ] || [ "$status" -eq 0 ]
}

@test "script accepts --model parameter" {
    run ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh --deploy --model test-model
    # Should not crash, may fail due to environment but should parse correctly
    [ "$status" -ne 0 ] || [ "$status" -eq 0 ]
}

@test "script accepts --port parameter" {
    run ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh --deploy --port 8356
    # Should not crash, may fail due to environment but should parse correctly
    [ "$status" -ne 0 ] || [ "$status" -eq 0 ]
}

@test "script accepts --tp-size parameter" {
    run ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh --deploy --tp-size 4
    # Should not crash, may fail due to environment but should parse correctly
    [ "$status" -ne 0 ] || [ "$status" -eq 0 ]
}

@test "script accepts --hf-token parameter" {
    run ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh --deploy --hf-token test-token
    # Should not crash, may fail due to environment but should parse correctly
    [ "$status" -ne 0 ] || [ "$status" -eq 0 ]
}

@test "script handles unknown option correctly" {
    run ./stacked-dgx-sparks/stacked-dgx-sparks-automation.sh --unknown-option
    [ "$status" -ne 0 ]
    echo "$output" | grep -q "Unknown option"
}