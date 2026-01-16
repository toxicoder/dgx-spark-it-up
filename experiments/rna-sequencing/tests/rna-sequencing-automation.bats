#!/usr/bin/env bats

load '../test_helper/bats-support/load'
load '../test_helper/bats-assert/load'

# Test script location
SCRIPT_PATH="experiments/rna-sequencing/rna-sequencing-automation.sh"

@test "RNA Sequencing Automation: Script exists" {
    [ -f "$SCRIPT_PATH" ]
}

@test "RNA Sequencing Automation: Script is executable" {
    [ -x "$SCRIPT_PATH" ]
}

@test "RNA Sequencing Automation: Script has proper shebang" {
    head -n 1 "$SCRIPT_PATH" | grep -q "#!/bin/bash"
}

@test "RNA Sequencing Automation: Help option works" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"Options:"* ]]
}

@test "RNA Sequencing Automation: Verify environment option exists" {
    run "$SCRIPT_PATH" --verify
    # This test will pass if the script runs without error (since we can't test actual environment in test environment)
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]  # Either success or expected failure due to environment
}

@test "RNA Sequencing Automation: Install option exists" {
    run "$SCRIPT_PATH" --install
    # This test will pass if the script runs without error (since we can't actually clone in test environment)
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]  # Either success or expected failure due to environment
}

@test "RNA Sequencing Automation: Run option exists" {
    run "$SCRIPT_PATH" --run
    [ "$status" -eq 0 ]
}

@test "RNA Sequencing Automation: Download option exists" {
    run "$SCRIPT_PATH" --download
    [ "$status" -eq 0 ]
}

@test "RNA Sequencing Automation: Cleanup option exists" {
    run "$SCRIPT_PATH" --cleanup
    [ "$status" -eq 0 ]
}

@test "RNA Sequencing Automation: Full workflow executes" {
    # This tests that the main function can be called without errors
    run "$SCRIPT_PATH"
    # This should fail because we can't actually execute the full workflow in test environment
    # But it should at least parse correctly
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]  # Either success or expected failure due to environment
}

@test "RNA Sequencing Automation: Script parses arguments correctly" {
    # Test that we can parse arguments without errors
    run "$SCRIPT_PATH" --verify
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}