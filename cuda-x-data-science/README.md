# CUDA-X Data Science Automation

This repository contains an automation script that sets up and runs the CUDA-X Data Science workflow as described in the NVIDIA guide.

## Overview

This automation script performs the following steps:

1. Verifies system requirements (CUDA 13, conda)
2. Installs Data Science libraries including CUDA-X libraries
3. Creates and activates a conda environment
4. Clones the dgx-spark-playbooks repository
5. Runs the example notebooks

## Prerequisites

Before running this automation script, you need to:

1. Have CUDA 13 installed on your system
2. Have conda installed
3. Have a Kaggle API key (kaggle.json) in the same directory as the script

## Usage

1. Make sure you have a `kaggle.json` file in the current directory
2. Run the automation script:

   ```bash
   ./cuda-x-data-science-automation.sh
   ```

## What the script does

- Checks for system requirements (nvcc, nvidia-smi, conda)
- Creates a conda environment named `rapids-test` with CUDA-X libraries
- Clones the NVIDIA dgx-spark-playbooks repository
- Copies your `kaggle.json` to the assets folder
- Executes the example notebooks

## Notebooks

The automation runs two example notebooks:

1. `cudf_pandas_demo.ipynb` - Demonstrates large strings data processing with pandas on GPU
2. `cuml_sklearn_demo.ipynb` - Demonstrates machine learning algorithms including UMAP and HDBSCAN

## Port Forwarding for Remote Access

If you're accessing this remotely, use the following command to forward the necessary port:

```bash
ssh -N -L YYYY:localhost:XXXX username@remote_host
```

Where:

- `YYYY`: The local port you want to use (e.g., 8888)
- `XXXX`: The port you specified when starting Jupyter Notebook on the remote machine (e.g., 8888)
- `-N`: Prevents SSH from executing a remote command
- `-L`: Specifies local port forwarding

## Testing

To run the BATS tests for this automation, execute:

```bash
./run_tests.sh
```

## License

This project is licensed under the NVIDIA License - see the LICENSE file for details.
