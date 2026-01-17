# Open WebUI Automation for DGX Spark

This module provides automation scripts and tests for setting up Open WebUI with Ollama on NVIDIA DGX Spark systems.

## Overview

This automation script follows the official guide from <https://build.nvidia.com/spark/open-webui> to:

1. Configure Docker permissions
2. Pull the Open WebUI container image with integrated Ollama
3. Start the Open WebUI container
4. Download and configure the gpt-oss:20b model
5. Provide cleanup functionality

## Features

- Fully automated setup process
- Docker permission checking and configuration
- Container management (start, stop, cleanup)
- Model download automation
- Comprehensive BATS testing
- Support for cleanup and rollback operations

## Prerequisites

- Docker installed and running
- NVIDIA GPU with CUDA support
- `docker` command accessible (user in docker group or sudo access)
- `bash` shell

## Usage

### Basic Setup

```bash
# Make the script executable (if not already)
chmod +x open-webui-automation.sh

# Run the full automation
./open-webui-automation.sh
```

### Available Commands

```bash
# Run the full setup
./open-webui-automation.sh

# Install only (pull container, start container, download model)
./open-webui-automation.sh --install

# Verify the setup
./open-webui-automation.sh --verify

# Cleanup all resources
./open-webui-automation.sh --cleanup
```

## Script Components

### Main Functions

1. **`check_docker`** - Verifies Docker installation and permissions
2. **`pull_container`** - Pulls the Open WebUI container image
3. **`start_container`** - Starts the Open WebUI container with GPU support
4. **`download_model`** - Downloads the gpt-oss:20b model
5. **`verify_setup`** - Validates that all components are properly installed
6. **`cleanup`** - Removes all Open WebUI resources

### Docker Configuration

- Container port: `8080:8080`
- GPU support: `--gpus=all`
- Data volumes:
  - `open-webui:/app/backend/data` (application data)
  - `open-webui-ollama:/root/.ollama` (model data)

## Testing

This module includes comprehensive BATS tests to verify the automation script:

```bash
# Run the tests
cd open-webui
bats tests/
```

## Next Steps

1. Access Open WebUI at <http://localhost:8080>
2. Create an administrator account
3. Download different models from the Ollama library at <https://ollama.com/library>

## Cleanup

To completely remove Open WebUI and free up resources:

```bash
./open-webui-automation.sh --cleanup
```

**Warning**: This will permanently delete all Open WebUI data and downloaded models.

## Troubleshooting

### Docker Permission Issues

If you encounter permission denied errors, ensure your user is in the docker group:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Then log out and back in for changes to take effect.

### GPU Access Issues

Ensure NVIDIA drivers and Docker GPU support are properly configured.
