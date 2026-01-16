# Live VLM WebUI Automation

This repository contains an automation script for setting up and running the Live VLM WebUI on NVIDIA DGX Spark systems with Blackwell GPUs.

## Overview

The Live VLM WebUI provides a real-time video analysis interface that leverages Vision Language Models (VLMs) to process webcam feeds and provide AI-powered insights. This automation script streamlines the setup process by:

1. Installing Ollama as the VLM backend
2. Downloading a lightweight VLM model (gemma3:4b by default)
3. Installing the Live VLM WebUI Python package
4. Starting the WebUI server with automatic SSL certificate generation

## Prerequisites

- NVIDIA DGX Spark system with Blackwell GPU
- Internet connectivity for downloading models
- Python 3 and pip installed
- Docker (optional, for containerized deployment)

## Installation

The automation script can be run directly without additional setup:

```bash
# Make the script executable
chmod +x live-vlm-automation.sh

# Install Ollama and Live VLM WebUI
./live-vlm-automation.sh --install
```

## Usage

### Install Components

```bash
# Install with default model (gemma3:4b)
./live-vlm-automation.sh --install

# Install with a specific model
./live-vlm-automation.sh --install --model llama3.2-vision:11b
```

### Start Server

```bash
# Start server on default port (8090)
./live-vlm-automation.sh --start

# Start server on custom port
./live-vlm-automation.sh --start --port 8091

# Start server with specific model
./live-vlm-automation.sh --start --model llama3.2-vision:11b
```

### Configure Settings

```bash
# Configure VLM settings
./live-vlm-automation.sh --configure
```

### Uninstall

```bash
# Uninstall Live VLM WebUI and Ollama
./live-vlm-automation.sh --uninstall
```

## Features

- **Automated Setup**: Complete installation of Ollama and Live VLM WebUI
- **Model Management**: Easy model selection and downloading
- **Port Configuration**: Customizable server port
- **GPU Detection**: Automatic detection of Blackwell GPU
- **SSL Certificate Generation**: Automatic HTTPS certificate creation
- **Cleanup**: Easy uninstallation of components

## System Requirements

- NVIDIA DGX Spark with Blackwell GPU
- At least 8GB VRAM (recommended 16GB+)
- 4GB RAM minimum (recommended 8GB+)
- Internet connection for model downloads

## Performance Optimization

For best performance on DGX Spark Blackwell GPU:

- **Model Selection**: `gemma3:4b` gives 1-2s/frame, `llama3.2-vision:11b` gives slower speed
- **Frame Interval**: Set to 60 frames (2 seconds at 30 fps) or bigger for comfortable viewing
- **Max Tokens**: Reduce to 100 for faster responses

## Security

The WebUI uses HTTPS with automatically generated SSL certificates. When accessing the interface:

1. Your browser will show a security warning due to self-signed certificates
2. You must manually accept the certificate to access the webcam
3. All communication happens over secure HTTPS connections

## Troubleshooting

### Common Issues

1. **Connection Problems**: Ensure you're using HTTPS and have accepted the SSL certificate
2. **Model Download Failures**: Check internet connectivity and available disk space
3. **Port Conflicts**: Use a different port with `--port` option
4. **Permission Denied**: Run with appropriate privileges if needed

### Accessing the WebUI

1. Find your DGX Spark's IP address:

   ```bash
   hostname -I | awk '{print $1}'
   ```

2. Open your browser and navigate to:

   ```bash
   https://<YOUR_SPARK_IP>:8090
   ```

3. Accept the SSL certificate warning in your browser

## References

- [Live VLM WebUI Official Guide](https://build.nvidia.com/spark/live-vlm-webui)
- [Ollama Documentation](https://ollama.com/)
- [NVIDIA DGX Spark Documentation](https://docs.nvidia.com/dgx/)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
