#!/bin/bash

# Run BATS tests for Isaac Sim automation script

set -e

echo "Running BATS tests for Isaac Sim automation..."

# Run the tests
echo "Executing tests..."
bats tests/simple_test.bats

echo "All tests completed successfully!"