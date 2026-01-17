# Isaac Lab Automation

This repository provides automation scripts and tests for installing and setting up NVIDIA Isaac Lab.

## Overview

This automation script follows the official NVIDIA Isaac Lab installation guide to:

1. Install Isaac Sim (assumed to be already installed)
2. Clone the Isaac Lab repository
3. Create a symbolic link to the Isaac Sim installation
4. Install Isaac Lab dependencies
5. Run Isaac Lab training in headless mode

## Prerequisites

- Isaac Sim already installed and ISAACSIM_PATH environment variable set
- Ubuntu/Debian-based Linux system
- Internet connection for downloading repositories
- Sufficient disk space (~10GB+)

## Usage

### Running the Automation Script

```bash
# Make the script executable
chmod +x isaac-lab-automation.sh

# Set ISAACSIM_PATH to your Isaac Sim installation directory
export ISAACSIM_PATH=/path/to/your/isaac-sim/installation

# Run the automation script
./isaac-lab-automation.sh
```

### Running Tests

```bash
# Run the BATS tests
./run_tests.sh
```

## Script Structure

The automation script is divided into the following main functions:

1. **install_isaac_sim()** - Validates Isaac Sim installation
2. **clone_isaac_lab_repo()** - Clones the Isaac Lab repository
3. **setup_isaac_sim_link()** - Creates symbolic link to Isaac Sim for Isaac Lab
4. **install_isaac_lab()** - Installs Isaac Lab dependencies
5. **run_isaac_lab_training()** - Runs Isaac Lab training in headless mode

## Testing

This project includes BATS (Bash Automated Testing System) tests to verify the automation script functionality:

- `tests/isaac-lab-automation.bats` - Main test suite for the automation script
- `tests/integration_test.bats` - Integration tests for the automation script

## Environment Variables

- `ISAACSIM_PATH` - Path to your Isaac Sim installation directory

## Features

- Full compliance with the NVIDIA Isaac Lab guide
- Comprehensive error handling
- Headless training mode support
- Visualization mode support (optional)
- Proper symbolic link creation
- LD_PRELOAD configuration for required libraries
