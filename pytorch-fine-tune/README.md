# NVIDIA DGX Spark PyTorch Fine-Tuning Automation

This tool automates the process of setting up and running PyTorch fine-tuning on NVIDIA DGX Spark devices, following the official guide at [https://build.nvidia.com/spark/pytorch-fine-tune](https://build.nvidia.com/spark/pytorch-fine-tune).

## Features

- Configure network connectivity
- Set up Docker permissions
- Install NVIDIA Container Toolkit
- Enable resource advertising for GPUs
- Initialize Docker Swarm
- Join worker nodes to the swarm
- Deploy fine-tuning stack
- Find and manage Docker containers
- Adapt configuration files for multi-node setup
- Run fine-tuning scripts
- Cleanup and rollback

## Installation

To use this tool, simply make the script executable:

```bash
chmod +x pytorch-fine-tune-automation.sh
```

## Usage

### Basic Commands

```bash
# Show help
./pytorch-fine-tune-automation.sh --help

# Verify system requirements
./pytorch-fine-tune-automation.sh --verify

# Configure fine-tuning settings
./pytorch-fine-tune-automation.sh --configure

# Run all steps (except cleanup)
./pytorch-fine-tune-automation.sh --all
```

### Step-by-Step Commands

```bash
# Configure network connectivity
./pytorch-fine-tune-automation.sh --network

# Configure Docker permissions
./pytorch-fine-tune-automation.sh --docker

# Enable resource advertising
./pytorch-fine-tune-automation.sh --resources

# Initialize Docker Swarm (on manager node)
./pytorch-fine-tune-automation.sh --swarm

# Join worker nodes to swarm
./pytorch-fine-tune-automation.sh --join

# Deploy fine-tuning stack
./pytorch-fine-tune-automation.sh --deploy

# Run fine-tuning
./pytorch-fine-tune-automation.sh --finetune

# Cleanup and rollback
./pytorch-fine-tune-automation.sh --cleanup
```

## Configuration

Connection settings are stored in `~/.pytorch-fine-tune-config` after running `--configure`.

## Requirements

- Docker installed on all nodes
- NVIDIA drivers and NVIDIA Container Toolkit installed
- Bash shell
- SSH access to all DGX Spark nodes
- HuggingFace token for model access

## Troubleshooting

### Common Issues

1. **Network connectivity issues** - Ensure physical QSFP cables are connected and network interfaces are properly configured
2. **Docker permission denied** - Add user to docker group or log out and back in
3. **Swarm initialization failure** - Check network interfaces and IP addresses
4. **Worker node join failure** - Ensure manager node is properly initialized and token is valid
5. **Configuration file issues** - Make sure config files are edited properly for multi-node setup

### Solutions

- For network issues, follow the official DGX Spark documentation for network setup
- For Docker permissions, run `sudo usermod -aG docker $USER` and log out/in
- For swarm issues, verify IP addresses and network connectivity
- For worker joins, get the correct join token from manager node
- For configuration issues, manually edit the YAML files with correct parameters

## Security

This tool follows security best practices:

- Uses SSH for encrypted connections
- Stores configuration in a user-specific directory
- Validates connection parameters before establishing connections
- Supports SSH key authentication

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

- [NVIDIA DGX Spark Documentation](https://build.nvidia.com/spark/pytorch-fine-tune)
- [Docker Swarm Documentation](https://docs.docker.com/engine/swarm/)
- [NVIDIA Container Toolkit Documentation](https://github.com/NVIDIA/nvidia-container-toolkit)