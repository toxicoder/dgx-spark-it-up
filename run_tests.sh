#!/bin/bash

# Run all BATS tests in the repository
# This script recursively finds and runs all .bats files

set -euo pipefail

echo "Running all BATS tests..."

# Find and run all .bats files recursively
find . -name "*.bats" -type f | while read -r test_file; do
    echo "Running test: $test_file"
    bats "$test_file"
done

echo "All tests completed."