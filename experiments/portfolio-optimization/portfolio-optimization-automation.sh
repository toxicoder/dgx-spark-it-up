#!/bin/bash

# Portfolio Optimization Automation Script
# This script automates the entire portfolio optimization workflow from environment verification to JupyterLab setup

set -e  # Exit on any error

echo "=== Portfolio Optimization Automation ==="

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: Verify environment
echo "Step 1: Verifying environment..."
if ! command_exists nvidia-smi; then
    echo "ERROR: nvidia-smi not found. Please ensure NVIDIA drivers are properly installed."
    exit 1
fi

if ! command_exists git; then
    echo "ERROR: git not found. Please install git."
    exit 1
fi

if ! command_exists docker; then
    echo "ERROR: docker not found. Please install Docker."
    exit 1
fi

echo "✓ All required tools (nvidia-smi, git, docker) are available"

# Get nvidia-smi output to verify GPU is working
echo "Verifying GPU..."
nvidia-smi --query-gpu=name --format=csv,noheader,nounits | head -n1
if [ $? -ne 0 ]; then
    echo "ERROR: GPU not properly configured"
    exit 1
fi
echo "✓ GPU is properly configured"

# Step 2: Clone repository if not already present
echo "Step 2: Setting up repository..."
REPO_DIR="dgx-spark-playbooks/nvidia/portfolio-optimization"
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning repository..."
    git clone https://github.com/NVIDIA/dgx-spark-playbooks.git
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to clone repository"
        exit 1
    fi
else
    echo "Repository already exists"
fi

# Step 3: Setup the playbook environment
echo "Step 3: Setting up playbook environment..."
cd "$REPO_DIR/assets"
echo "Current directory: $(pwd)"

# Make sure the setup script is executable
chmod +x ./setup/start_playbook.sh

echo "Starting playbook environment..."
# Run the start script in background
./setup/start_playbook.sh &
START_PID=$!

# Give it a moment to start
sleep 5

# Check if it's running
if kill -0 $START_PID 2>/dev/null; then
    echo "✓ Playbook environment started successfully"
else
    echo "WARNING: Playbook may not have started correctly"
fi

echo "Playbook environment setup complete!"
echo "Access JupyterLab at http://127.0.0.1:8888"
echo "To stop the environment, use Ctrl+C in this terminal"

# Keep the script running to maintain the container
wait $START_PID