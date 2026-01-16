# Flux Finetuning Automation

This repository provides an automated solution for the NVIDIA FLUX.1 finetuning workflow based on the guide from <https://build.nvidia.com/spark/flux-finetuning>.

## Overview

This automation script streamlines the entire FLUX.1 finetuning process, from setting up the environment to running training and inference. It handles all the steps outlined in the NVIDIA guide, making it easier to reproduce the workflow consistently.

## Features

- Automated Docker permission setup
- Repository cloning and asset management
- Model download with Hugging Face token support
- Automated Docker image building for both inference and training
- Dataset preparation
- Comprehensive BATS testing

## Prerequisites

1. Linux system (Ubuntu/Debian recommended)
2. Docker installed and running
3. Hugging Face token with access to FLUX.1-dev model
4. Sufficient disk space (~50GB for model and datasets)

## Setup

### 1. Set your Hugging Face token

```bash
export HF_TOKEN=your_hugging_face_token_here
```

### 2. Make the automation script executable

```bash
chmod +x flux-finetuning-automation.sh
```

### 3. Run the automation script

```bash
./flux-finetuning-automation.sh
```

## Script Structure

The automation script includes the following functions:

1. **check_os** - Verifies the script is running on Linux
2. **check_docker_permissions** - Ensures proper Docker permissions
3. **clone_repository** - Clones the dgx-spark-playbooks repository
4. **setup_directories** - Creates necessary directory structure
5. **check_hf_token** - Validates Hugging Face token
6. **download_model** - Downloads the FLUX.1-dev model
7. **build_inference_image** - Builds the inference Docker image
8. **build_training_image** - Builds the training Docker image
9. **prepare_dataset** - Prepares dataset directories
10. **main** - Main execution function

## Testing

This project includes comprehensive BATS tests to verify the automation works correctly:

### Running Tests

```bash
# Run all tests
bats tests/bats/flux-finetuning-automation.bats

# Run specific test
bats tests/bats/flux-finetuning-automation.bats -t "script exists"
```

### Test Coverage

The tests verify:

- Script existence and executability
- Function presence
- Directory structure
- Required asset files
- Workflow files
- Dataset preparation
- Script syntax

## Usage Workflow

1. **Prepare environment**: Set HF_TOKEN and ensure Docker is installed
2. **Run automation**: Execute `./flux-finetuning-automation.sh`
3. **Run training**: Execute `sh flux-finetuning/assets/launch_train.sh`
4. **Run inference**: Execute `sh flux-finetuning/assets/launch_comfyui.sh`

## Important Notes

- The script will automatically add your user to the docker group but you'll need to re-login or run `newgrp docker` for permissions to take effect
- Model download can take 30-45 minutes depending on internet speed
- Training requires significant GPU resources
- The automation handles directory setup but you'll need to place your training images in the appropriate dataset directories

## Troubleshooting

### Docker Permission Issues

If you encounter Docker permission errors:

1. Run `newgrp docker` or re-login to apply group changes
2. Verify with `docker ps`

### Model Download Issues

If the model download fails:

1. Verify your HF_TOKEN is valid
2. Check internet connectivity
3. Ensure sufficient disk space

### Training Issues

If training fails:

1. Ensure you have sufficient GPU memory
2. Check that dataset images are properly formatted
3. Verify that the data.toml file has correct configuration

## Contributing

Contributions are welcome! Please submit issues and pull requests through the GitHub repository.
