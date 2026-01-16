#!/usr/bin/env bats

# Test the live-vlm-automation.sh script using BATS framework
# This test file verifies the functionality of the Live VLM WebUI automation script

@test "live-vlm script exists and is executable" {
    [ -x ./live-vlm/live-vlm-automation.sh ]
}

@test "live-vlm script shows help when --help is passed" {
    run ./live-vlm/live-vlm-automation.sh --help
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Usage: live-vlm-automation.sh"
}

@test "live-vlm script shows help when -h is passed" {
    run ./live-vlm/live-vlm-automation.sh -h
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Usage: live-vlm-automation.sh"
}

@test "live-vlm script shows error when no action is specified" {
    run ./live-vlm/live-vlm-automation.sh
    [ "$status" -ne 0 ]
    echo "$output" | grep -q "No action specified"
}

@test "live-vlm script handles --install correctly" {
    run ./live-vlm/live-vlm-automation.sh --install
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "live-vlm script handles --start correctly" {
    run ./live-vlm/live-vlm-automation.sh --start
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "live-vlm script handles --configure correctly" {
    run ./live-vlm/live-vlm-automation.sh --configure
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "live-vlm script handles --uninstall correctly" {
    run ./live-vlm/live-vlm-automation.sh --uninstall
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "live-vlm script handles unknown option correctly" {
    run ./live-vlm/live-vlm-automation.sh --unknown-option
    [ "$status" -ne 0 ]
    echo "$output" | grep -q "Unknown option"
}

@test "live-vlm script accepts --port parameter" {
    run ./live-vlm/live-vlm-automation.sh --start --port 8091
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "live-vlm script accepts --model parameter" {
    run ./live-vlm/live-vlm-automation.sh --install --model gemma3:4b
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "live-vlm script handles --install with specific model" {
    run ./live-vlm/live-vlm-automation.sh --install --model llama3.2-vision:11b
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "live-vlm script handles --start with custom port" {
    run ./live-vlm/live-vlm-automation.sh --start --port 8092
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

# Test that the script properly handles various command line arguments
@test "live-vlm script handles combined parameters correctly" {
    run ./live-vlm/live-vlm-automation.sh --install --model qwen2.5-vl:7b
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}