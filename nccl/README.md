# NVIDIA DGX Spark NCCL Automation

This directory contains the NCCL automation script for NVIDIA DGX Spark nodes, following the official guide from [NVIDIA Build](https://build.nvidia.com/spark/nccl).

## Files

- `nccl-automation.sh` - Main automation script that follows all steps from the NCCL guide
- `README-NCCL.md` - Detailed documentation for the automation script
- `tests/` - Test suite using BATS framework

## Overview

The NCCL automation script streamlines the process of setting up NCCL with Blackwell architecture support on DGX Spark systems. It handles all the steps required for multi-node distributed training workloads.

## Features

- Automated NCCL build with Blackwell support
- Automated NCCL tests suite compilation
- Network interface detection and configuration
- Multi-node communication testing
- Cleanup functionality for easy rollback

## Usage

```bash
# Run the full automation process
./nccl/nccl-automation.sh

# Run with specific node IP for multi-node testing
./nccl/nccl-automation.sh --node 169.254.35.62

# Run with specific network interface
./nccl/nccl-automation.sh --node 169.254.35.62 --interface enp1s0f1np1

# Cleanup NCCL and NCCL-tests directories
./nccl/nccl-automation.sh --cleanup
```

## Testing

To run the test suite:

```bash
# Run all tests
cd nccl
bats tests/nccl-automation.bats
```

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