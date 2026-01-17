#!/bin/bash

# Run BATS tests for VS Code automation

# Check if bats is installed
if ! command -v bats &> /dev/null; then
    echo "BATS is not installed. Please install BATS to run tests."
    exit 1
fi

# Run the BATS tests
echo "Running VS Code automation tests..."
bats vscode.bats