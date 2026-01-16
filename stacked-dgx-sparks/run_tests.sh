#!/usr/bin/env bash

# Test runner script for stacked-dgx-sparks automation
# This script runs the BATS tests for the stacked DGX Sparks automation script

set -euo pipefail

echo "Running BATS tests for stacked-dgx-sparks automation..."

# Check if bats is available
if ! command -v bats &> /dev/null; then
    echo "Error: BATS (Bash Automated Testing System) is not installed."
    echo "Please install BATS to run these tests."
    echo "Installation instructions: https://github.com/bats-core/bats-core"
    exit 1
fi

# Run the BATS tests
if bats tests/bats/; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed!"
    exit 1
fi