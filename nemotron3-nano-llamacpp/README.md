# Nemotron-3-Nano-30B-A3B GGUF Setup Script

This repository contains an automated setup script for the Nemotron-3-Nano-30B-A3B GGUF model on DGX Spark systems.

## Overview

The `setup-nemotron3-nano-llamacpp.sh` script automates the entire process of setting up and running the Nemotron-3-Nano-30B-A3B GGUF model using llama.cpp. This includes:

- Checking system prerequisites
- Setting up a Python virtual environment
- Cloning the llama.cpp repository
- Building llama.cpp with CUDA support
- Downloading the Nemotron GGUF model (~38GB)
- Starting the llama.cpp server

## Prerequisites

Before running the setup script, ensure you have:

- Git installed
- CMake installed
- NVIDIA CUDA toolkit installed
- At least 40GB of free disk space
- Internet connectivity (for downloading the model)

## Usage

### Running the Setup Script

```bash
chmod +x setup-nemotron3-nano-llamacpp.sh
./setup-nemotron3-nano-llamacpp.sh
```

### Testing the Script

To run unit tests for the setup script:

```bash
chmod +x test-setup-nemotron3-nano-llamacpp.sh
./test-setup-nemotron3-nano-llamacpp.sh
```

## Testing

Unit tests are provided to verify the functionality of each component of the setup script:

1. `test_check_prerequisites` - Tests prerequisite checking
2. `test_setup_virtual_environment` - Tests virtual environment setup
3. `test_clone_llama_cpp` - Tests cloning of llama.cpp repository
4. `test_build_llama_cpp` - Tests building of llama.cpp with CUDA support
5. `test_download_model` - Tests downloading of the Nemotron GGUF model
6. `test_start_server` - Tests starting the llama.cpp server

Tests mock external commands to ensure reliable execution without requiring actual system resources.

## Components

### Functions

1. `check_prerequisites` - Verifies that git, cmake, and nvcc are installed
2. `setup_virtual_environment` - Sets up a Python virtual environment with huggingface_hub
3. `clone_llama_cpp` - Clones the llama.cpp repository from GitHub
4. `build_llama_cpp` - Builds llama.cpp with CUDA support
5. `download_model` - Downloads the Nemotron GGUF model using Hugging Face CLI
6. `start_server` - Starts the llama.cpp server with specified parameters

## Configuration

The script uses the following environment variables and paths:

- `MODELS_DIR`: Directory where models are stored (`~/models/nemotron3-gguf`)
- `VENV_DIR`: Virtual environment directory (`./nemotron-venv`)
- `LLAMA_CPP_DIR`: Directory where llama.cpp is cloned (`./llama.cpp`)
- `SERVER_LOG`: Server log file name (`server.log`)

## Server Information

After successful setup, the server will be running on:
- Host: 0.0.0.0
- Port: 30000
- Model: Nemotron-3-Nano-30B-A3B-UD-Q8_K_XL.gguf

To test the API:
```bash
curl http://localhost:30000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "nemotron", "messages": [{"role": "user", "content": "Hello"}], "max_tokens": 50}'
```

To stop the server:
```bash
ps aux | grep llama-server
kill [PID]
```

## Troubleshooting

If you encounter any issues:

1. Make sure all prerequisites are installed
2. Check that you have sufficient disk space
3. Ensure your NVIDIA drivers are properly installed
4. Verify that CUDA is correctly configured in your PATH

## Contributing

Contributions are welcome! Please follow the project's style guides for code and documentation.

## License

This project is licensed under the terms specified in the LICENSE file.