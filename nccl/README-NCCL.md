# NVIDIA DGX Spark NCCL Automation

This script automates the complete NCCL (NVIDIA Collective Communications Library) setup process for NVIDIA DGX Spark nodes, following the official guide from [NVIDIA Build](https://build.nvidia.com/spark/nccl).

## Overview

The NCCL automation script streamlines the process of setting up NCCL with Blackwell architecture support on DGX Spark systems. It handles all the steps required for multi-node distributed training workloads.

## Features

- Automated NCCL build with Blackwell support
- Automated NCCL tests suite compilation
- Network interface detection and configuration
- Multi-node communication testing
- Cleanup functionality for easy rollback

## Prerequisites

Before running this script, ensure you have:

1. **Physical Hardware**: 
   - Two DGX Spark nodes connected with QSFP cables
   - Proper network infrastructure set up

2. **System Requirements**:
   - Ubuntu/Debian-based Linux system
   - SSH access between nodes (passwordless SSH setup)
   - Network connectivity between nodes

3. **Software Dependencies**:
   - Git
   - Make
   - GCC compiler
   - OpenMPI development libraries
   - CUDA Toolkit (required for building NCCL, but not for running the automation script)

## Usage

### Basic Usage

```bash
# Run the full automation process
./nccl-automation.sh

# Run with specific node IP for multi-node testing
./nccl-automation.sh --node 169.254.35.62

# Run with specific network interface
./nccl-automation.sh --node 169.254.35.62 --interface enp1s0f1np1

# Cleanup NCCL and NCCL-tests directories
./nccl-automation.sh --cleanup
```

### Command Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message |
| `-n, --node NODE` | Specify remote node IP address for multi-node setup |
| `-i, --interface IFACE` | Specify network interface name |
| `-c, --cleanup` | Cleanup NCCL and NCCL tests directories |
| `-v, --verbose` | Enable verbose output |

## Automation Steps

1. **Network Connectivity Configuration**
   - Manual setup required for physical connections and SSH configuration
   - Verifies network interface status

2. **NCCL Build with Blackwell Support**
   - Installs required dependencies
   - Clones NCCL repository (v2.28.9-1)
   - Builds NCCL with Blackwell architecture support

3. **NCCL Tests Suite Compilation**
   - Clones NCCL tests repository
   - Compiles test suite with MPI support

4. **Network Interface Detection**
   - Identifies active network interfaces
   - Determines IP addresses for communication

5. **NCCL Communication Testing**
   - Runs all_gather performance tests
   - Tests with different buffer sizes

6. **Cleanup**
   - Removes build directories (optional)

## Important Notes

### Manual Configuration Required

Some steps in the NCCL setup require manual configuration:
- Physical QSFP cable connections
- Network interface configuration (IP assignment)
- Passwordless SSH setup between nodes
- Network connectivity verification

The script will prompt you to verify these manually before proceeding.

### Multi-Node Testing

To run multi-node tests:
1. Ensure passwordless SSH is configured between nodes
2. Set the `--node` parameter with the remote node's IP address
3. Specify the correct network interface with `--interface`

### Environment Variables

The script automatically sets these environment variables:
- `CUDA_HOME`
- `MPI_HOME` 
- `NCCL_HOME`
- `LD_LIBRARY_PATH`

## Troubleshooting

### Common Issues

1. **Missing Dependencies**:
   ```bash
   # Install missing dependencies manually
   sudo apt-get update && sudo apt-get install -y libopenmpi-dev
   ```

2. **Network Connectivity**:
   - Verify SSH access between nodes
   - Check that network interfaces are up and properly configured
   - Confirm IP addresses are accessible

3. **Build Failures**:
   - Ensure sufficient disk space
   - Check that CUDA development tools are available
   - Verify that the repository branches exist

## Next Steps

After successful automation:
- Run distributed training workloads such as TRT-LLM or vLLM inference
- Use the built test suite for performance verification
- Configure additional distributed computing frameworks

## License

This automation script is provided as part of the NVIDIA DGX Spark Utilities project and is licensed under the MIT License.