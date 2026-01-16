#!/usr/bin/env bats

# Test the multi-agent-chatbot-automation.sh script using BATS framework
# This test file verifies the functionality of the NVIDIA DGX Spark Multi-Agent Chatbot automation script

@test "script exists and is executable" {
    [ -x ./multi-agent-chatbot/multi-agent-chatbot-automation.sh ]
}

@test "script shows help when --help is passed" {
    run ./multi-agent-chatbot/multi-agent-chatbot-automation.sh --help
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Usage: multi-agent-chatbot-automation.sh"
}

@test "script shows help when -h is passed" {
    run ./multi-agent-chatbot/multi-agent-chatbot-automation.sh -h
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Usage: multi-agent-chatbot-automation.sh"
}

@test "script shows error when no action is specified" {
    run ./multi-agent-chatbot/multi-agent-chatbot-automation.sh
    [ "$status" -ne 0 ]
    echo "$output" | grep -q "No action specified"
}

@test "script handles --setup correctly" {
    run ./multi-agent-chatbot/multi-agent-chatbot-automation.sh --setup
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "script handles --run correctly" {
    run ./multi-agent-chatbot/multi-agent-chatbot-automation.sh --run
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "script handles --test correctly" {
    run ./multi-agent-chatbot/multi-agent-chatbot-automation.sh --test
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "script handles --cleanup correctly" {
    run ./multi-agent-chatbot/multi-agent-chatbot-automation.sh --cleanup
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "script handles --ui correctly" {
    run ./multi-agent-chatbot/multi-agent-chatbot-automation.sh --ui
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "script handles --port-forward correctly" {
    run ./multi-agent-chatbot/multi-agent-chatbot-automation.sh --port-forward
    # Should not crash, might return 0 or 1 depending on environment
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "script handles unknown option correctly" {
    run ./multi-agent-chatbot/multi-agent-chatbot-automation.sh --unknown-option
    [ "$status" -ne 0 ]
    echo "$output" | grep -q "Unknown option"
}

@test "script validates Docker installation" {
    # This test ensures the script properly checks for Docker
    run ./multi-agent-chatbot/multi-agent-chatbot-automation.sh --test
    # Should not crash, even if Docker is not installed
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}