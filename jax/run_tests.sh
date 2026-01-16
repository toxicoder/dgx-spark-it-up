#!/bin/bash

# Run BATS tests for JAX automation
# This script executes the BATS test suite for the JAX automation script

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to the script directory
cd "$SCRIPT_DIR"

# Check if bats is installed
if ! command -v bats &> /dev/null; then
    echo "BATS is not installed. Please install BATS to run tests."
    echo "Installation instructions: https://github.com/bats-core/bats-core"
    exit 1
fi

# Run BATS tests
echo "Running BATS tests for JAX automation..."
bats tests/