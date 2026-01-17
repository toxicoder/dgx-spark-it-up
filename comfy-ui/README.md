# ComfyUI Automation Script

This repository contains an automated installation script for ComfyUI on NVIDIA DGX Spark devices, following the official installation guide from <https://build.nvidia.com/spark/comfy-ui>.

## Features

- Fully automated ComfyUI installation process
- BATS tests for validation
- Cleanup functionality for easy rollback
- Comprehensive error handling
- Step-by-step execution following the official guide

## Prerequisites

Before running the automation script, ensure the following tools are installed:

- Python 3.8+
- pip3
- Git
- curl
- wget
- nvidia-smi (for GPU detection)
- nvcc (optional, but recommended for CUDA support)

## Installation

1. Clone this repository:

```bash
git clone <repository-url>
cd comfy-ui
```

1. Make the automation script executable:

```bash
chmod +x comfy-ui-automation.sh
```

1. Run the automation script:

```bash
./comfy-ui-automation.sh
```

## Testing

To run the BATS tests:

```bash
chmod +x run_tests.sh
./run_tests.sh
```

## Structure

- `comfy-ui-automation.sh` - Main automation script implementing all 10 steps from the guide
- `comfy-ui.bats` - BATS test suite for validating the automation
- `test_helper.bash` - Helper functions for tests
- `run_tests.sh` - Test runner script
- `README.md` - This documentation file

## Automation Steps

1. **Verify system prerequisites** - Check Python, pip, CUDA, and GPU
2. **Create Python virtual environment** - Isolated environment for ComfyUI
3. **Install PyTorch with CUDA support** - Install PyTorch 13.0 compatible with Blackwell architecture
4. **Clone ComfyUI repository** - Download the official ComfyUI source
5. **Install ComfyUI dependencies** - Install all required Python packages
6. **Download Stable Diffusion checkpoint** - Download the v1.5 model
7. **Launch ComfyUI server** - Start the web server
8. **Validate installation** - Check that the server is responding
9. **Cleanup and rollback** - Optional cleanup of installations
10. **Next steps** - Instructions for testing the installation

## Usage

After running the automation script, access the ComfyUI web interface at:

```bash
http://<SPARK_IP>:8188
```

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Create a new Pull Request
