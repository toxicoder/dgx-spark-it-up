#!/bin/bash

# Run tests for the Tailscale automation module
# This script runs the BATS tests for the Tailscale automation script

set -e  # Exit on any error

echo "Running Tailscale automation tests..."

# Check if bats is available
if ! command -v bats &> /dev/null; then
    echo "Error: bats could not be found. Please install bats to run tests."
    exit 1
fi

# Run the bats tests
bats tailscale/tests/bats/tailscale-automation.bats

echo "All Tailscale automation tests completed successfully!"