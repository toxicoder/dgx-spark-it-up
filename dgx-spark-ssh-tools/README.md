# NVIDIA DGX Spark SSH Automation

This tool automates the process of connecting to NVIDIA DGX Spark devices via SSH, following the official guide at <https://build.nvidia.com/spark/connect-to-your-spark>.

## Features

- Verify SSH client availability
- Gather and store connection information
- Test mDNS resolution
- Test SSH connectivity
- Verify remote connection
- Set up SSH tunnels for web applications

## Installation

To use this tool, simply download the script and make it executable:

```bash
chmod +x dgx-spark-ssh-automation.sh
```

## Usage

### Basic Commands

```bash
# Show help
./dgx-spark-ssh-automation.sh --help

# Verify SSH client
./dgx-spark-ssh-automation.sh --verify

# Configure connection settings
./dgx-spark-ssh-automation.sh --configure

# Test SSH connection
./dgx-spark-ssh-automation.sh --test

# Set up SSH tunnel for web app (e.g., DGX Dashboard on port 11000)
./dgx-spark-ssh-automation.sh --port-forward 11000
```

### Command Options

- `-h, --help`: Show help message
- `-c, --configure`: Configure connection settings
- `-t, --test`: Test SSH connection
- `-v, --verify`: Verify SSH client and connection
- `-p, --port-forward PORT`: Set up SSH tunnel for web app
- `-u, --username USER`: Specify username (overrides config)
- `-H, --hostname HOST`: Specify hostname (overrides config)

## Configuration

Connection settings are stored in `~/.dgx-spark-config` after running `--configure`.

## Examples

```bash
# Configure connection
./dgx-spark-ssh-automation.sh --configure

# Test connection
./dgx-spark-ssh-automation.sh --test

# Set up tunnel to access DGX Dashboard
./dgx-spark-ssh-automation.sh --port-forward 11000

# Specify username and hostname directly
./dgx-spark-ssh-automation.sh --test --username myuser --hostname spark-abcd
```

## Requirements

- SSH client (OpenSSH)
- Bash shell
- Ping utility for mDNS resolution testing

## Troubleshooting

### Common Issues

1. **SSH connection fails** - Ensure your SSH client is installed and configured properly
2. **mDNS resolution fails** - Check your network configuration and DNS settings
3. **Permission denied** - Verify your SSH keys and username
4. **Port already in use** - Check if another process is using the port

### Solutions

- For SSH connection issues, ensure the DGX Spark device is powered on and accessible
- For mDNS resolution issues, try specifying the hostname directly with the `--hostname` flag
- For permission issues, check that you have the proper SSH keys and access rights
- For port conflicts, choose a different local port for forwarding

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

- [NVIDIA DGX Spark Documentation](https://build.nvidia.com/spark/connect-to-your-spark)
- [SSH Protocol Documentation](https://en.wikipedia.org/wiki/Secure_Shell)
