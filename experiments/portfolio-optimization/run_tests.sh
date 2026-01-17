#!/bin/bash

# Run BATS tests for portfolio optimization automation

echo "Running BATS tests for portfolio optimization automation..."

# Check if bats is installed
if ! command -v bats >/dev/null 2>&1; then
    echo "ERROR: bats is not installed. Please install bats to run tests."
    echo "On Ubuntu/Debian: sudo apt install bats"
    echo "On macOS with Homebrew: brew install bats"
    exit 1
fi

# Run the BATS tests
cd "$(dirname "${BASH_SOURCE[0]}")"
bats tests/

echo "Tests completed."