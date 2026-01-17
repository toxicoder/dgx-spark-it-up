#!/bin/bash

# Run all BATS tests for Isaac Lab automation

set -e  # Exit on any error

echo "Running Isaac Lab automation tests..."

# Make sure we're in the isaac-lab directory
cd "$(dirname "$0")"

# Check if bats is installed
if ! command -v bats &> /dev/null; then
    echo "Error: bats could not be found. Please install bats to run tests."
    echo "On Ubuntu/Debian: sudo apt install bats"
    echo "On macOS: brew install bats"
    exit 1
fi

# Run all tests
echo "Running BATS tests..."
bats tests/

echo "All tests completed successfully!"