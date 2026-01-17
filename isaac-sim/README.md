# Isaac Sim and Isaac Lab Automation

This repository provides automation scripts and tests for installing and setting up NVIDIA Isaac Sim and Isaac Lab.

## Overview

This automation script follows the official NVIDIA Isaac Sim installation guide to:

1. Install required dependencies (gcc-11, git-lfs)
2. Clone the Isaac Sim repository
3. Build Isaac Sim
4. Set up environment variables
5. Clone and setup Isaac Lab
6. Install Isaac Lab dependencies
7. Run Isaac Lab training in headless mode

## Prerequisites

- Ubuntu/Debian-based Linux system
- Internet connection for downloading packages and repositories
- Sufficient disk space (Isaac Sim is large, ~10GB+)
- sudo privileges for package installation

## Usage

### Running the Automation Script

```bash
# Make the script executable
chmod +x isaac-sim-automation.sh

# Run the automation script
./isaac-sim-automation.sh
```

### Running Tests

```bash
# Run the BATS tests
./run_tests.sh
```

## Script Structure

The automation script is divided into the following main functions:

1. **install_dependencies()** - Installs gcc-11, g++-11, and git-lfs
2. **clone_isaac_sim()** - Clones the Isaac Sim repository with LFS support
3. **build_isaac_sim()** - Builds Isaac Sim and verifies successful build
4. **setup_environment()** - Sets up required environment variables
5. **run_isaac_sim()** - Prepares Isaac Sim for execution
6. **clone_isaac_lab()** - Clones the Isaac Lab repository
7. **setup_isaac_sim_link()** - Creates symbolic link to Isaac Sim for Isaac Lab
8. **install_isaac_lab()** - Installs Isaac Lab dependencies
9. **run_isaac_lab_training()** - Runs Isaac Lab training in headless mode

## Testing

This project includes BATS (Bash Automated Testing System) tests to verify the automation script functionality:

- `tests/isaac-sim-automation.bats` - Main test suite for the automation script
