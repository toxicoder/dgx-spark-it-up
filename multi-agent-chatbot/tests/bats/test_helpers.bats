#!/usr/bin/env bats

# Helper functions for multi-agent-chatbot tests
# This file contains common test utilities and setup functions

# Load the script to test
load '../dgx-spark-ssh-tools/test_helper/bats-support/load.bash'
load '../dgx-spark-ssh-tools/test_helper/bats-assert/load.bash'

# Set up test environment
setup() {
    # Create a temporary directory for testing
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
}

# Tear down test environment
teardown() {
    # Clean up temporary directory
    cd /
    rm -rf "$TEST_DIR"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}