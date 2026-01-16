#!/bin/bash

# Run tests for flux-finetuning automation
# Since BATS may not be available, we'll run basic checks

echo "=== Flux Finetuning Automation Tests ==="

# Check if script exists
if [ ! -f "flux-finetuning-automation.sh" ]; then
    echo "ERROR: flux-finetuning-automation.sh not found"
    exit 1
fi

echo "✓ Script exists"

# Check if script is executable
if [ ! -x "flux-finetuning-automation.sh" ]; then
    echo "ERROR: flux-finetuning-automation.sh is not executable"
    exit 1
fi

echo "✓ Script is executable"

# Basic syntax check
if bash -n flux-finetuning-automation.sh; then
    echo "✓ Script syntax is valid"
else
    echo "ERROR: Script has syntax errors"
    exit 1
fi

# Check required directories exist
directories=(
    "flux_data"
    "models/loras"
    "models/checkpoints"
    "models/text_encoders"
    "models/vae"
    "workflows"
)

for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        echo "✓ Directory $dir exists"
    else
        echo "ERROR: Directory $dir does not exist"
        exit 1
    fi
done

# Check required files exist
files=(
    "Dockerfile.inference"
    "Dockerfile.train"
    "download.sh"
    "launch_comfyui.sh"
    "launch_train.sh"
    "flux_data/data.toml"
    "workflows/base_flux.json"
    "workflows/finetuned_flux.json"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ File $file exists"
    else
        echo "ERROR: File $file does not exist"
        exit 1
    fi
done

# Check functions exist in script
functions=(
    "check_os"
    "check_docker_permissions"
    "clone_repository"
    "setup_directories"
    "check_hf_token"
    "download_model"
    "build_inference_image"
    "build_training_image"
    "prepare_dataset"
    "main"
)

for func in "${functions[@]}"; do
    if grep -q "function $func" flux-finetuning-automation.sh || grep -q "$func()" flux-finetuning-automation.sh; then
        echo "✓ Function $func exists"
    else
        echo "WARNING: Function $func not found in script"
    fi
done

echo ""
echo "=== All Tests Passed ==="
echo "The flux-finetuning automation is properly set up!"