#!/bin/bash

# Test runner for vibe-coding automation

echo "Running Vibe Coding automation tests..."

# Change to the vibe-coding directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

# Run BATS tests
if bats vibe-coding.bats; then
    echo "All tests passed! ✓"
    exit 0
else
    echo "Some tests failed! ✗"
    exit 1
fi