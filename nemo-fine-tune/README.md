# NeMo AutoModel Fine-Tuning Automation

This directory contains automation scripts for setting up and running NeMo AutoModel fine-tuning workflows on NVIDIA DGX Spark systems.

## Overview

This automation follows the official NeMo AutoModel fine-tuning guide to:
1. Verify system requirements
2. Configure Docker permissions
3. Pull and launch the necessary container
4. Install package management tools
5. Clone and install NeMo AutoModel
6. Verify the installation
7. Run sample fine-tuning examples
8. Validate training completion
9. Optional cleanup

## Usage

```bash
# Make the script executable
chmod +x nemo-fine-tune/nemo-fine-tune-automation.sh

# Run the automation
./nemo-fine-tune/nemo-fine-tune-automation.sh
```

## Structure

- `nemo-fine-tune-automation.sh`: Main automation script
- `README.md`: This documentation
- `test_helper/`: Helper functions for testing
- `tests/`: Test suite for the automation