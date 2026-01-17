#!/bin/bash

# Test runner script for Open WebUI automation
# This script runs the BATS tests for the Open WebUI automation script

set -e  # Exit on any error

echo "Running Open WebUI BATS tests..."

# Check if bats is available
if ! command -v bats &> /dev/null; then
    echo "Error: BATS is not installed. Please install BATS to run tests."
    exit 1
fi

# Run the BATS tests
cd open-webui
bats tests/

echo "All tests completed successfully!"