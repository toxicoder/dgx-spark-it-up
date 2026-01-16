# NVIDIA DGX Spark Unsloth Automation

This tool automates the process of setting up and testing Unsloth on NVIDIA DGX Spark devices, following the official guide at [https://build.nvidia.com/spark/unsloth](https://build.nvidia.com/spark/unsloth).

## Features

- Verify prerequisites (CUDA toolkit and GPU resources)
- Pull the required Docker container image
- Launch Docker container with proper GPU and memory settings
- Install required Python dependencies inside the container
- Create and run validation test script
- Provide next steps for custom model and dataset usage

## Installation

To use this tool, simply download the script and make it executable:

```bash
chmod +x unsloth-automation.sh
```

## Usage

### Basic Commands

```bash
# Show help
./unsloth-automation.sh --help

# Run all steps automatically (default)
./unsloth-automation.sh --auto

# Verify prerequisites
./unsloth-automation.sh --verify

# Pull Docker image
./unsloth-automation.sh --pull

# Launch Docker container
./unsloth-automation.sh --launch

# Install dependencies in container
./unsloth-automation.sh --install

# Create and run test script
./unsloth-automation.sh --test

# Show next steps information
./unsloth-automation.sh --next-steps
```

### Command Options

- `-h, --help`: Show help message
- `-a, --auto`: Run all steps automatically (default)
- `-v, --verify`: Verify prerequisites (CUDA, GPU)
- `-p, --pull`: Pull Docker image
- `-l, --launch`: Launch Docker container
- `-i, --install`: Install dependencies in container
- `-t, --test`: Create and run test script
- `-n, --next-steps`: Show next steps information

## Requirements

- NVIDIA DGX Spark device with appropriate drivers
- Docker installed on the host system
- CUDA toolkit 13.0
- NVIDIA GPU with proper drivers

## Prerequisites Verification

The automation script will verify:
1. CUDA toolkit version 13.0 is installed
2. NVIDIA GPU drivers are available
3. Docker is installed and accessible

## Docker Container Details

The automation uses the following Docker container:
- Image: `nvcr.io/nvidia/pytorch:25.11-py3`
- GPU access: `--gpus all`
- Memory limits: `--ulimit memlock=-1`
- Stack size: `--ulimit stack=67108864`
- Entry point: `/usr/bin/bash`

## Test Script

The automation downloads and runs a validation test script from:
`https://raw.githubusercontent.com/NVIDIA/dgx-spark-playbooks/refs/heads/main/nvidia/unsloth/assets/test_unsloth.py`

Expected output includes:
- "Unsloth: Will patch your computer to enable 2x faster free finetuning"
- Training progress bars showing loss decreasing over 60 steps
- Final training metrics showing completion

## Next Steps

After successful installation, you can:
1. Update the test_unsloth.py file with your model choice
2. Load your custom dataset
3. Adjust training parameters

For advanced usage instructions, visit: https://github.com/unslothai/unsloth/wiki

## Troubleshooting

### Common Issues

1. **Docker not found** - Ensure Docker is installed and in your PATH
2. **CUDA version mismatch** - Verify CUDA toolkit version 13.0 is installed
3. **GPU drivers not available** - Check that NVIDIA GPU drivers are properly installed
4. **Permission denied** - Ensure proper permissions for Docker and GPU access

### Solutions

- For Docker issues, install Docker following official installation guides
- For CUDA issues, install the correct CUDA toolkit version
- For GPU driver issues, ensure NVIDIA drivers are properly installed
- For permission issues, check user group memberships and Docker permissions

## Security

This tool follows security best practices:
- Uses Docker for isolated execution environment
- Validates prerequisites before proceeding
- Provides clear instructions for manual steps that require interaction

## Contributing

We welcome contributions to improve this tool. To contribute:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

[MIT](/LICENSE)

## References

- [NVIDIA DGX Spark Documentation](https://build.nvidia.com/spark/unsloth)
- [Unsloth GitHub Repository](https://github.com/unslothai/unsloth)