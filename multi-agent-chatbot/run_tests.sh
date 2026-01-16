#!/usr/bin/env bash

# Test runner script for multi-agent-chatbot automation
# This script runs the BATS tests for the automation script

set -euo pipefail

echo "Running BATS tests for multi-agent-chatbot automation..."

# Check if bats is installed
if ! command -v bats &> /dev/null; then
    echo "Error: BATS is not installed. Please install BATS to run tests."
    echo "Installation instructions: https://github.com/bats-core/bats-core"
    exit 1
fi

# Run tests
echo "Executing tests..."
bats tests/bats/

echo "Tests completed."