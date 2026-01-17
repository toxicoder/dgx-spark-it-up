# Video Search and Summarization (VSS) Automation

This repository provides an automated solution for setting up and deploying the NVIDIA Video Search and Summarization (VSS) system based on the official guide from <https://build.nvidia.com/spark/vss>.

## Overview

The VSS system allows for advanced video analysis, including event detection, summarization, and Q&A capabilities. This automation script streamlines the entire setup process, making it easier to deploy both the Event Reviewer and Standard VSS configurations.

## Features

- Automated environment verification (driver, CUDA, Docker)
- Docker configuration and NVIDIA Container Runtime setup
- Repository cloning from NVIDIA's official repository
- Cache cleaner initialization
- Docker network creation
- NVIDIA Container Registry authentication
- Support for both deployment scenarios:
  - **VSS Event Reviewer**: Completely local deployment
  - **Standard VSS**: Hybrid deployment with remote LLMs
- Service validation and workflow testing
- Cleanup functionality for easy teardown

## Prerequisites

Before using this automation, ensure you have:

1. NVIDIA GPU with appropriate drivers (580.82.09 or higher)
2. CUDA toolkit 13.0 or higher
3. Docker and Docker Compose installed
4. An NVIDIA NGC API key
5. For Standard VSS: An NVIDIA API key (for remote LLMs)

## Installation

The automation script is self-contained. Simply clone this repository and run the script:

```bash
cd experiments/video-search-and-summarization-agent
```

## Usage

### Basic Setup

```bash
# Set required environment variables
export NGC_API_KEY="your-ngc-api-key-here"
export NVIDIA_API_KEY="your-nvidia-api-key-here"  # For Standard VSS only

# Run the automation script
./vss-automation.sh
```

### Cleanup

To clean up deployed services and remove resources:

```bash
./vss-automation.sh cleanup
```

## Deployment Scenarios

### 1. VSS Event Reviewer (Completely Local)

This deployment runs all components locally on your system:

- VSS Engine (VLM pipeline)
- Alert Inspector UI
- Video Storage Toolkit
- Computer Vision Event Detector (local)

### 2. Standard VSS (Hybrid)

This deployment uses remote LLMs via NVIDIA's NIM service:

- VSS Engine (with remote LLMs)
- VSS UI for interaction

## Testing

The automation includes a comprehensive BATS test suite to validate functionality:

```bash
# Run tests
./run_tests.sh
```

## File Structure

```
experiments/video-search-and-summarization-agent/
├── vss-automation.sh          # Main automation script
├── run_tests.sh               # Test runner script
├── vss-automation.bats        # BATS test suite
└── README.md                  # This documentation
```

## Environment Variables

- `NGC_API_KEY`: Required for authentication with NVIDIA Container Registry
- `NVIDIA_API_KEY`: Required for Standard VSS deployment with remote LLMs

## Contributing

This automation script follows the same patterns and guidelines as the rest of the NVIDIA DGX Spark Utilities project. Contributions should adhere to the established style guides and code quality requirements.
