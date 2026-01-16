# Flux Finetuning Automation - Usage Guide

This document provides step-by-step instructions for using the automated flux-finetuning workflow.

## Prerequisites

1. **Linux system** (Ubuntu/Debian recommended)
2. **Docker** installed and running
3. **Hugging Face token** with access to FLUX.1-dev model
4. Sufficient disk space (~50GB for model and datasets)

## Setup Instructions

### 1. Set your Hugging Face token

```bash
export HF_TOKEN=your_hugging_face_token_here
```

### 2. Make the automation script executable

```bash
chmod +x flux-finetuning-automation.sh
```

### 3. Run the automation script

```bash
./flux-finetuning-automation.sh
```

## What the Automation Does

The automation script performs the following steps automatically:

1. **Checks OS compatibility** - Ensures you're running on Linux
2. **Verifies Docker permissions** - Adds user to docker group if needed
3. **Clones the repository** - Downloads the dgx-spark-playbooks repository
4. **Sets up directory structure** - Creates necessary directories for models, datasets, etc.
5. **Downloads the FLUX.1-dev model** - Uses your Hugging Face token
6. **Prepares dataset** - Sets up default dataset directories
7. **Builds Docker images** - Creates both inference and training Docker images

## Post-Setup Usage

After running the automation script, you can:

### Run Training

```bash
cd flux-finetuning/assets
sh launch_train.sh
```

### Run Inference

```bash
cd flux-finetuning/assets
sh launch_comfyui.sh
```

## Directory Structure

The automation creates this structure:

```
flux-finetuning/
├── flux-finetuning-automation.sh     # Main automation script
├── README.md                         # Documentation
├── run_tests.sh                      # Test runner
├── assets/
│   ├── Dockerfile.inference          # Inference Dockerfile
│   ├── Dockerfile.train              # Training Dockerfile
│   ├── download.sh                   # Model download script
│   ├── launch_comfyui.sh             # ComfyUI launcher
│   ├── launch_train.sh               # Training launcher
│   ├── flux_data/                    # Dataset directory
│   │   ├── data.toml                 # Dataset configuration
│   │   ├── sparkgpu/                 # Spark GPU concept images
│   │   └── tjtoy/                    # Toy Jensen concept images
│   ├── models/                       # Model storage
│   │   ├── loras/                    # LoRA weights
│   │   ├── checkpoints/              # Training checkpoints
│   │   ├── text_encoders/            # Text encoder models
│   │   └── vae/                      # VAE models
│   └── workflows/                    # ComfyUI workflows
│       ├── base_flux.json            # Base model workflow
│       └── finetuned_flux.json       # Finetuned model workflow
└── tests/
    └── bats/
        └── flux-finetuning-automation.bats  # BATS tests
```

## Troubleshooting

### Docker Permission Issues

If you get Docker permission errors:

1. Run `newgrp docker` or re-login to apply group changes
2. Verify with `docker ps`

### Model Download Issues

If the model download fails:

1. Verify your HF_TOKEN is valid
2. Check internet connectivity
3. Ensure sufficient disk space

### Training Issues

If training fails:

1. Ensure you have sufficient GPU memory
2. Check that dataset images are properly formatted
3. Verify that the data.toml file has correct configuration

## Testing Your Setup

To verify your automation is working correctly:

```bash
cd flux-finetuning
./run_tests.sh
```

This will run a comprehensive check of all components and functions.
