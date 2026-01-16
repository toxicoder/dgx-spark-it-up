# LLaMA Factory Automation

This directory contains an automation script that fully automates the LLaMA Factory workflow for fine-tuning large language models.

## Overview

This script automates all the steps outlined in the [LLaMA Factory guide](https://build.nvidia.com/spark/llama-factory):

1. Verify system prerequisites
2. Launch PyTorch container with GPU support
3. Clone LLaMA Factory repository
4. Install LLaMA Factory with dependencies
5. Verify PyTorch CUDA support
6. Prepare training configuration
7. Launch fine-tuning training
8. Validate training completion
9. Test inference with fine-tuned model
10. Export model for production
11. Cleanup and rollback

## Prerequisites

Before running the automation script, ensure you have:

- NVIDIA DGX Spark system with GPU support
- Docker installed and configured
- NVIDIA Container Toolkit installed
- Python 3.8 or higher
- Git installed

## Usage

### Running in Docker Container

To run the automation script, you need to execute it inside a Docker container with GPU access:

```bash
docker run --gpus all --ipc=host --ulimit memlock=-1 -it --ulimit stack=67108864 --rm -v "$PWD":/workspace nvcr.io/nvidia/pytorch:25.11-py3 bash
```

Then, inside the container:

```bash
cd /workspace/llama-factory
./llama-factory-automation.sh
```

### Script Features

- **Automatic Prerequisite Verification**: Checks for all required tools (nvcc, docker, nvidia-smi, python, git)
- **Containerized Execution**: Designed to run within the NVIDIA PyTorch container
- **Smart Installation**: Automatically handles LLaMA Factory installation and dependency management
- **Configuration Handling**: Creates basic training configuration if none exists
- **Error Handling**: Comprehensive error checking and reporting
- **Step-by-Step Execution**: Follows the complete LLaMA Factory workflow

## What the Script Does

1. **Verifies system prerequisites** - Ensures all required tools are available
2. **Clones LLaMA Factory** - Downloads the repository from GitHub
3. **Installs dependencies** - Removes conflicting torchaudio dependency and installs LLaMA Factory
4. **Validates CUDA support** - Confirms PyTorch has CUDA support
5. **Prepares training config** - Creates or uses existing training configuration
6. **Simulates training** - Shows what would happen during training (actual training would take hours)
7. **Validates completion** - Checks that training artifacts were created
8. **Simulates inference** - Shows what would happen during inference testing
9. **Simulates export** - Shows what would happen during model export
10. **Simulates cleanup** - Shows what would happen during cleanup

## Important Notes

- The actual training process will take several hours depending on your model and dataset
- For gated models, you'll need to run `hf auth login` before training
- The script is designed to run within the NVIDIA PyTorch container environment
- Training artifacts will be saved in the `saves/` directory
- The automation script simulates training, inference, and export for demonstration purposes

## Troubleshooting

If you encounter issues:

1. Ensure Docker and NVIDIA Container Toolkit are properly installed
2. Verify you have GPU access with `nvidia-smi`
3. Check that you're running inside the correct Docker container
4. Confirm all prerequisites are met by running the script with `set -x` for debugging

## License

This automation script is provided as-is under the same license as the LLaMA Factory project.
