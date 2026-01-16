#!/bin/bash

# Run all BATS tests in the repository
# This script recursively finds and runs all .bats files

set -euo pipefail

echo "Running all BATS tests..."

# Find and run all .bats files recursively
find . -name "*.bats" -type f | while read -r test_file; do
    echo "Running test: $test_file"
    # Use the local bats-core installation when available
    if [ -f "./bats-core/bin/bats" ]; then
        ./bats-core/bin/bats "$test_file"
    elif command -v bats &> /dev/null; then
        bats "$test_file"
    else
        echo "Warning: BATS not found in local installation or PATH. Skipping $test_file"
        continue
    fi
done

echo "All tests completed."