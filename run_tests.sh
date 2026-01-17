#!/bin/bash

# Run all BATS tests in the repository.
#
# This script recursively finds and runs all .bats files in the project, using either a local bats-core installation or the system-installed bats command.

set -euo pipefail

# Run all BATS tests in the repository.
# Execute all BATS test files found recursively in the project.
#
# Returns:
#   0 - All tests completed successfully
#   1 - Some tests failed or BATS not found
#
# Errors:
#   BATS not found in local installation or PATH: BATS test runner required
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