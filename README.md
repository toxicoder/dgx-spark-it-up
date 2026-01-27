# NVIDIA DGX Spark Utilities

[![NVIDIA DGX Spark Utilities banner](static/images/nvidia-dgx-spark-utilities-banner.png)]()

This repository contains various utilities and tools for NVIDIA DGX Spark devices. These utilities are designed to help with development, deployment, and management of applications running on NVIDIA DGX Spark systems with seamless integration.

## Overview

NVIDIA DGX Spark systems are purpose-built AI supercomputers that combine powerful GPU hardware with optimized software stacks for accelerated machine learning and data processing. This repository provides helpful utilities to streamline workflows when working with NVIDIA DGX Spark devices and Spark frameworks.

## Key Components Architecture

The following diagram shows the architecture of the NVIDIA DGX Spark Utilities ecosystem:

```mermaid
flowchart TD
    A[NVIDIA DGX Spark] --> B[AI Frameworks]
    A --> C[Infrastructure Setup]
    A --> D[Deployment Tools]
    
    B --> E[LLaMA Factory<br/>Fine-tuning Workflow]
    B --> F[PyTorch Fine-tuning]
    B --> G[NVFP4 Quantization]
    B --> H[JAX Optimized ML]
    
    C --> I[NCCL Multi-node Setup]
    C --> J[CUDA-X Data Science Tools]
    C --> K[Tailscale Secure Access]
    
    D --> L[TRT-LLM Inference]
    D --> M[Open WebUI with Ollama]
    D --> N[NIM API Management]
    D --> O[Vibe Coding in VS Code]
```

## Contents

This repository includes:

### AI Frameworks

- **LLaMA Factory automation** - Script to automate the complete LLaMA Factory workflow for fine-tuning large language models
- **PyTorch Fine-tuning** - Tools for fine-tuning machine learning models using PyTorch
- **NVFP4 Quantization** - Utilities for neural network quantization using FP4 format
- **JAX Optimized ML** - Scripts for optimizing machine learning workloads using JAX

### Infrastructure Setup

- **NCCL automation** - Script to automate the complete NCCL setup process for DGX Spark nodes
- **CUDA-X Data Science** - Tools for data science workflows using NVIDIA CUDA-X libraries
- **Tailscale Secure Access** - Scripts for setting up secure network connections between DGX nodes

### Deployment Tools

- **TRT-LLM Inference** - Tools for deploying LLM inference using TensorRT-LLM
- **Open WebUI with Ollama** - Web interface for running local LLMs with Ollama
- **NIM API Management** - Utilities for managing NVIDIA Inference Microservices
- **Vibe Coding in VS Code** - VS Code integration for AI coding assistance

## Core Workflows

### NCCL Setup Process

The following diagram illustrates the NCCL automation workflow:

```mermaid
flowchart TD
    Start[Start] --> CheckPrereq{Check Prerequisites?}
    CheckPrereq -- Yes --> SetupNCCL[Setup NCCL]
    SetupNCCL --> ConfigureNetwork[Configure Network Interfaces]
    ConfigureNetwork --> RunTests[Run Multi-node Tests]
    RunTests -- Pass --> Done[Done]
    RunTests -- Fail --> Troubleshoot[Troubleshoot]
    Troubleshoot --> Retry[Retry Configuration]
```

### LLaMA Factory Automation

The LLaMA Factory workflow automation follows these steps:

```mermaid
flowchart TD
    A[Verify Prerequisites] --> B[Launch PyTorch Container]
    B --> C[Clone LLaMA Factory]
    C --> D[Install Dependencies]
    D --> E[Validate CUDA Support]
    E --> F[Prepare Training Config]
    F --> G[Simulate Training]
    G --> H[Validate Completion]
    H --> I[Simulate Inference]
    I --> J[Simulate Export]
    J --> K[Simulate Cleanup]
```

## Prerequisites

- NVIDIA DGX system with appropriate drivers
- Spark framework installed
- Python 3.8 or higher
- Docker (for containerized utilities)
- Git installed

## Getting Started

1. Clone this repository
2. Navigate to the desired utility directory
3. Read the specific README for that utility
4. Follow the usage instructions for your workflow

## Usage

Each utility is contained in its own directory with specific documentation. Please refer to individual utility READMEs for detailed usage instructions.

## Contributing

Contributions are welcome! Please follow the guidelines in AGENTS.md for documentation standards and code quality requirements.

## Support My Projects

If you find this repository helpful and would like to support its development, consider making a donation:

### GitHub Sponsors

[![Sponsor](https://img.shields.io/badge/Sponsor-%23EA4AAA?style=for-the-badge&logo=github)](https://github.com/sponsors/toxicoder)

### Buy Me a Coffee

<a href="https://www.buymeacoffee.com/toxicoder" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="41" width="174">
</a>

### PayPal

[![PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/donate/?hosted_button_id=LSHNL8YLSU3W6)

### Ko-fi

<a href="https://ko-fi.com/toxicoder" target="_blank">
    <img src="https://storage.ko-fi.com/cdn/kofi3.png" alt="Ko-fi" height="41" width="174">
</a>

### Coinbase

[![Donate via Coinbase](https://img.shields.io/badge/Donate%20via-Coinbase-0052FF?style=for-the-badge&logo=coinbase&logoColor=white)](https://commerce.coinbase.com/checkout/e07dc140-d9f7-4818-b999-fdb4f894bab7)

Your support helps maintain and improve this collection of development tools and templates. Thank you for contributing to open source!

## License

This project is licensed under the MIT License - see the LICENSE file for details.
