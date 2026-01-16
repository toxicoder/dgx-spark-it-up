# NVIDIA DGX Spark Tailscale Automation

This script automates the setup and configuration of Tailscale on NVIDIA DGX Spark devices, enabling secure remote access and network connectivity.

## Overview

This automation script follows the official Tailscale setup guide to:
1. Verify system requirements
2. Install and configure SSH server
3. Install Tailscale client
4. Connect to Tailscale network
5. Provide instructions for client device setup
6. Configure SSH authentication
7. Test connectivity and validate installation

## Prerequisites

- NVIDIA DGX Spark device running Ubuntu 20.04 or newer
- Internet connectivity
- Sudo access

## Usage

### Make the script executable
```bash
chmod +x tailscale-automation.sh
```

### Run the automation script
```bash
./tailscale-automation.sh
```

The script will guide you through each step of the Tailscale setup process, providing detailed instructions where manual intervention is required.

## Features

- **Automated Setup**: Handles most of the Tailscale installation and configuration automatically
- **System Verification**: Checks Ubuntu version, internet connectivity, and sudo access
- **SSH Configuration**: Installs and configures SSH server if needed
- **Tailscale Installation**: Installs Tailscale from the official repository
- **Network Verification**: Verifies Tailscale installation and service status
- **Client Instructions**: Provides detailed instructions for installing Tailscale on client devices
- **SSH Authentication**: Generates SSH keys and provides instructions for configuration
- **Validation Steps**: Includes steps to test SSH connectivity and validate the installation
- **Cleanup Options**: Provides instructions for removing Tailscale completely

## Manual Steps Required

Some steps require manual intervention:
1. Tailscale authentication (browser-based login)
2. Adding SSH public key to Spark device
3. Client device installation and authentication
4. SSH connection testing

## Next Steps

After running this automation:
1. Follow the authentication instructions to connect your device to Tailscale
2. Install Tailscale on your client devices
3. Configure SSH keys as instructed
4. Test SSH connectivity using the provided examples

## Troubleshooting

If you encounter issues:
1. Ensure your device has internet connectivity
2. Verify you have sudo access
3. Check that Ubuntu version is 20.04 or newer
4. Review error messages for specific troubleshooting steps

## License

This project is licensed under the MIT License - see the LICENSE file for details.