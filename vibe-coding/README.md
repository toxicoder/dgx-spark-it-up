# Vibe Coding Automation

This directory contains automation scripts and tests for setting up the Vibe Coding environment on NVIDIA DGX Spark systems, following the guide at <https://build.nvidia.com/spark/vibe-coding>.

## Automation Script

The main automation script `vibe-coding-automation.sh` performs the following steps:

1. **Install Ollama** - Installs the latest version of Ollama using the official installer
2. **Pull Model** - Pulls the `gpt-oss:120b` model for use with Vibe Coding
3. **Enable Remote Access** - Configures Ollama to accept remote connections (optional)
4. **Install VSCode** - Installs VSCode for ARM64 systems (DGX Spark)
5. **Continue.dev Extension** - Notes that manual installation is required
6. **Local Inference Setup** - Notes that manual configuration is required
7. **Remote Connection Setup** - Notes that workstation configuration is required

## BATS Tests

The BATS test file `vibe-coding.bats` verifies:

- Script existence and executability
- Proper script structure and functions
- Required commands and configurations
- Syntax validity of the script

## Usage

```bash
# Make the script executable
chmod +x vibe-coding-automation.sh

# Run the automation
./vibe-coding-automation.sh
```

## Manual Steps

Some steps require manual configuration in VSCode:

- Installing the Continue.dev extension
- Configuring local inference settings
- Setting up remote connection on workstations

## Note

This automation script is designed for ARM-based NVIDIA DGX Spark systems. Some steps (like VSCode installation) may need adjustment for different architectures.
