# Portfolio Optimization Automation

This directory contains automation scripts for the NVIDIA DGX Spark Portfolio Optimization workflow.

## Overview

This automation script streamlines the entire portfolio optimization process:

1. Environment verification (GPU, git, Docker)
2. Repository cloning
3. Environment setup using RAPIDS notebooks
4. JupyterLab server startup

## Prerequisites

- NVIDIA GPU with proper drivers installed
- Docker installed and running
- Git installed
- Internet connectivity

## Usage

```bash
# Make the script executable (if not already)
chmod +x portfolio-optimization-automation.sh

# Run the automation
./portfolio-optimization-automation.sh
```

The script will:

1. Verify your environment requirements
2. Clone the NVIDIA DGX Spark Playbooks repository if needed
3. Set up the portfolio optimization environment
4. Start JupyterLab at <http://127.0.0.1:8888>

## Accessing JupyterLab

Once the script is running, access JupyterLab at:

- <http://127.0.0.1:8888> (local access)
- Or create an SSH tunnel for remote access:

  ```bash
  ssh -L 8888:localhost:8888 username@spark-IP
  ```

## Stopping the Environment

To stop the environment, use `Ctrl+C` in the terminal where the script is running.

## Next Steps

After starting the environment:

1. Open JupyterLab in your browser
2. Open the `cvar_basic.ipynb` notebook
3. Change the kernel to "Portfolio Optimization"
4. Run the notebook cells
