# JAX on Spark Automation

This repository contains an automation script that follows the NVIDIA JAX guide for setting up a JAX development environment on Spark systems.

## Overview

This automation script follows the steps from the NVIDIA JAX guide at <https://build.nvidia.com/spark/jax> to:

1. Verify system prerequisites
2. Clone the playbook repository
3. Build the Docker image
4. Launch the Docker container with GPU support
5. Access the marimo interface for the JAX tutorial

## Prerequisites

Before running this automation, ensure you have:

- NVIDIA GPU with proper drivers installed
- Docker installed and configured with GPU support
- `nvidia-smi` command available
- `git` installed

## Usage

### Basic Usage

```bash
# Make the script executable
chmod +x jax-automation.sh

# Check system prerequisites
./jax-automation.sh prerequisites

# Clone the playbook repository
./jax-automation.sh clone

# Build the Docker image
./jax-automation.sh build

# Run the Docker container (this will start the JAX environment)
./jax-automation.sh run

# Run all steps in sequence
./jax-automation.sh full
```

### Detailed Steps

1. **Prerequisites Check** (`prerequisites`): Verifies GPU access, Docker installation, and architecture compatibility
2. **Clone** (`clone`): Clones the NVIDIA dgx-spark-playbooks repository
3. **Build** (`build`): Builds the JAX Docker image
4. **Run** (`run`): Launches the Docker container with GPU support and port forwarding
5. **Full** (`full`): Executes all steps in sequence

## Accessing the JAX Tutorial

After running the `run` command, the JAX environment will be accessible at:

- **URL**: <http://localhost:8080>
- **Interface**: marimo notebook server

## BATS Tests

This automation includes BATS tests to verify the functionality. Run them with:

```bash
# Run BATS tests
./run_tests.sh
```

## Notes

- The Docker container requires GPU access, so make sure your user is in the docker group
- The container will run interactively and may need to be stopped with Ctrl+C when done
- The marimo interface will load with the JAX tutorial notebooks
