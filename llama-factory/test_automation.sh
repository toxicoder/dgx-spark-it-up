#!/bin/bash

# Test script for LLaMA Factory automation
# This script verifies that the automation script is properly set up

echo "=== Testing LLaMA Factory Automation Script ==="

# Check if the automation script exists
if [ ! -f "llama-factory-automation.sh" ]; then
    echo "ERROR: Automation script not found!"
    exit 1
fi

# Check if the script is executable
if [ ! -x "llama-factory-automation.sh" ]; then
    echo "ERROR: Automation script is not executable!"
    exit 1
fi

echo "✓ Automation script exists and is executable"

# Check if README exists
if [ ! -f "README.md" ]; then
    echo "ERROR: README.md not found!"
    exit 1
fi

echo "✓ README.md exists"

# Basic syntax check of the bash script
if ! bash -n llama-factory-automation.sh; then
    echo "ERROR: Syntax check failed for automation script!"
    exit 1
fi

echo "✓ Bash syntax check passed"

# Check that required directories exist
if [ ! -d "LLaMA-Factory" ]; then
    echo "Note: LLaMA-Factory directory not found (expected in container environment)"
fi

echo "=== All tests passed! ==="
echo "The LLaMA Factory automation script is properly set up."