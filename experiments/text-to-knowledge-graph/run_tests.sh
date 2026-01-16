#!/bin/bash

# Run BATS tests for txt2kg automation

echo "Running BATS tests for txt2kg-automation.sh..."

# Run the BATS tests
if [ -f "tests/txt2kg-automation.bats" ]; then
    # Use bats from the project's bats-core directory if available
    if [ -f "../bats-core/bin/bats" ]; then
        "../bats-core/bin/bats" "tests/txt2kg-automation.bats"
    elif command -v bats &> /dev/null; then
        # Use system-installed bats if available
        bats "tests/txt2kg-automation.bats"
    else
        echo "Error: BATS testing framework not found"
        echo "Please install BATS or ensure bats-core is available"
        exit 1
    fi
else
    echo "Error: Test file not found"
    exit 1
fi