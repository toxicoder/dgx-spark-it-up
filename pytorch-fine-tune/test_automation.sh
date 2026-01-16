#!/usr/bin/env bash

# Test script for PyTorch fine-tuning automation
# This script verifies that the automation script is properly structured

set -euo pipefail

echo "Testing PyTorch fine-tuning automation script..."

# Check if the main script exists
if [[ ! -f "pytorch-fine-tune-automation.sh" ]]; then
    echo "ERROR: Main automation script not found"
    exit 1
fi

# Check if script is executable
if [[ ! -x "pytorch-fine-tune-automation.sh" ]]; then
    echo "ERROR: Main automation script is not executable"
    exit 1
fi

# Test that script can be parsed without errors
if ! bash -n "pytorch-fine-tune-automation.sh"; then
    echo "ERROR: Main automation script has syntax errors"
    exit 1
fi

echo "SUCCESS: PyTorch fine-tuning automation script is properly structured"

# Check that all required functions exist
required_functions=(
    "verify_requirements"
    "gather_config"
    "configure_network"
    "configure_docker_permissions"
    "install_nvidia_toolkit"
    "enable_resource_advertising"
    "initialize_swarm"
    "join_worker_nodes"
    "deploy_stack"
    "find_container_id"
    "adapt_config_files"
    "run_finetune"
    "cleanup"
    "main"
)

echo "Checking required functions..."
for func in "${required_functions[@]}"; do
    if ! grep -q "^[[:space:]]*${func}()[[:space:]]*{" "pytorch-fine-tune-automation.sh"; then
        echo "ERROR: Required function $func not found"
        exit 1
    fi
done

echo "SUCCESS: All required functions found"

# Test help output
echo "Testing help output..."
if ! ./pytorch-fine-tune-automation.sh --help > /dev/null 2>&1; then
    echo "ERROR: Help command failed"
    exit 1
fi

echo "SUCCESS: Help command works"

echo "All tests passed!"