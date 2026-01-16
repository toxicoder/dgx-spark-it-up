# RNA Sequencing Automation

This script automates the workflow described at [NVIDIA Spark Single-Cell RNA Sequencing](https://build.nvidia.com/spark/single-cell).

## Overview

This automation script performs the following steps:

1. **Environment Verification**: Checks for required tools (nvidia-smi, git, docker)
2. **Installation**: Clones the dgx-spark-playbooks repository and sets up the environment
3. **Notebook Execution**: Guides the user on how to run the scRNA_analysis_preprocessing.ipynb notebook
4. **Work Download**: Instructions for downloading results from JupyterLab
5. **Cleanup**: Instructions for properly shutting down the Docker container

## Prerequisites

Before running this script, ensure you have:

- NVIDIA GPU with proper drivers installed
- Git installed
- Docker installed and configured

## Usage

### Basic Usage

```bash
# Run the full workflow
./rna-sequencing-automation.sh
```

### Individual Steps

```bash
# Verify environment
./rna-sequencing-automation.sh --verify

# Install playbook
./rna-sequencing-automation.sh --install

# Run notebook (simulated)
./rna-sequencing-automation.sh --run

# Download work (simulated)
./rna-sequencing-automation.sh --download

# Cleanup
./rna-sequencing-automation.sh --cleanup
```

### Help

```bash
./rna-sequencing-automation.sh --help
```

## Testing

This project includes BATS (Bash Automated Testing System) tests to verify the script functionality:

```bash
# Run all tests
cd experiments/rna-sequencing
bats tests/
```

## Features

- **Modular Design**: Each step can be executed independently
- **Error Handling**: Comprehensive error checking and reporting
- **Color Output**: Clear, color-coded status messages
- **BATS Tests**: Automated testing framework included
- **Environment Verification**: Ensures all prerequisites are met

## Important Notes

1. The installation step requires internet connectivity to clone the repository
2. The notebook execution step requires manual interaction with JupyterLab
3. Cleanup requires user interaction with the terminal where the script is running
4. Docker containers will be shut down when the script is terminated

## License

This project is licensed under the NVIDIA DGX Spark Utilities License.
