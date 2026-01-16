#!/bin/bash

# NeMo AutoModel Fine-Tuning Automation Script
# This script automates the entire NeMo AutoModel fine-tuning workflow
# Following the official guide from https://build.nvidia.com/spark/nemo-fine-tune/overview

set -e  # Exit on any error

echo "=== NeMo AutoModel Fine-Tuning Automation ==="

# Step 1: Verify system requirements
echo "Step 1: Verifying system requirements..."
echo "Checking CUDA installation..."
if command -v nvcc &> /dev/null; then
    echo "✅ CUDA toolkit found:"
    nvcc --version
else
    echo "❌ CUDA toolkit not found. Please install CUDA toolkit."
    exit 1
fi

echo ""
echo "Checking Python version..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
    if [[ $(printf '%s\n' "3.10" "$PYTHON_VERSION" | sort -V | head -n1) == "3.10" ]]; then
        echo "✅ Python version OK: $PYTHON_VERSION"
    else
        echo "❌ Python version too old. Need 3.10+."
        exit 1
    fi
else
    echo "❌ Python 3 not found."
    exit 1
fi

echo ""
echo "Checking GPU accessibility..."
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi
else
    echo "❌ nvidia-smi not found. GPU may not be accessible."
    exit 1
fi

echo ""
echo "Checking available system memory..."
free -h

echo ""
echo "Checking Docker permissions..."
if docker ps &> /dev/null; then
    echo "✅ Docker access OK"
else
    echo "❌ Docker permission denied. Please run:"
    echo "   sudo usermod -aG docker \$USER"
    echo "   newgrp docker"
    exit 1
fi

# Step 2: Configure Docker permissions (if needed)
echo ""
echo "Step 2: Configuring Docker permissions..."
if ! docker ps &> /dev/null; then
    echo "Docker permission issue detected. Configuring..."
    sudo usermod -aG docker $USER
    newgrp docker
    echo "Docker permissions configured. Please log out and back in for changes to take effect."
fi

# Step 3: Get the container image
echo ""
echo "Step 3: Pulling container image..."
docker pull nvcr.io/nvidia/pytorch:25.11-py3

# Step 4: Launch Docker container
echo ""
echo "Step 4: Launching Docker container..."
echo "Starting container with GPU access..."
docker run \
  --gpus all \
  --ulimit memlock=-1 \
  -it --ulimit stack=67108864 \
  --entrypoint /usr/bin/bash \
  --rm nvcr.io/nvidia/pytorch:25.11-py3

# Step 5: Install package management tools (inside container)
echo ""
echo "Step 5: Installing package management tools..."
echo "Installing uv package manager..."
if pip3 install uv; then
    echo "✅ uv installed successfully"
else
    echo "⚠️  System installation failed, trying user installation..."
    pip3 install --user uv
    export PATH="$HOME/.local/bin:$PATH"
    echo "✅ uv installed for current user"
fi

echo ""
echo "Verifying uv installation..."
uv --version

# Step 6: Clone NeMo AutoModel repository
echo ""
echo "Step 6: Cloning NeMo AutoModel repository..."
git clone https://github.com/NVIDIA-NeMo/Automodel.git
cd Automodel

# Step 7: Install NeMo AutoModel
echo ""
echo "Step 7: Installing NeMo AutoModel..."
echo "Initializing virtual environment..."
uv venv --system-site-packages

echo "Installing packages with uv..."
uv sync --inexact --frozen --all-extras \
  --no-install-package torch \
  --no-install-package torchvision \
  --no-install-package triton \
  --no-install-package nvidia-cublas-cu12 \
  --no-install-package nvidia-cuda-cupti-cu12 \
  --no-install-package nvidia-cuda-nvrtc-cu12 \
  --no-install-package nvidia-cuda-runtime-cu12 \
  --no-install-package nvidia-cudnn-cu12 \
  --no-install-package nvidia-cufft-cu12 \
  --no-install-package nvidia-cufile-cu12 \
  --no-install-package nvidia-curand-cu12 \
  --no-install-package nvidia-cusolver-cu12 \
  --no-install-package nvidia-cusparse-cu12 \
  --no-install-package nvidia-cusparselt-cu12 \
  --no-install-package nvidia-nccl-cu12 \
  --no-install-package transformer-engine \
  --no-install-package nvidia-modelopt \
  --no-install-package nvidia-modelopt-core \
  --no-install-package flash-attn \
  --no-install-package transformer-engine-cu12 \
  --no-install-package transformer-engine-torch

echo "Installing bitsandbytes..."
CMAKE_ARGS="-DCOMPUTE_BACKEND=cuda -DCOMPUTE_CAPABILITY=80;86;87;89;90" \
CMAKE_BUILD_PARALLEL_LEVEL=8 \
uv pip install --no-deps git+https://github.com/bitsandbytes-foundation/bitsandbytes.git

# Step 8: Verify installation
echo ""
echo "Step 8: Verifying installation..."
echo "Testing NeMo AutoModel import..."
uv run --frozen --no-sync python -c "import nemo_automodel; print('✅ NeMo AutoModel ready')"

echo "Checking available examples..."
ls -la examples/

# Step 9: Explore available examples
echo ""
echo "Step 9: Exploring available examples..."
echo "Listing LLM fine-tuning examples..."
ls examples/llm_finetune/

echo "Viewing example recipe configuration..."
cat examples/llm_finetune/finetune.py | head -20

# Step 10: Run sample fine-tuning (this would normally be run by user)
echo ""
echo "Step 10: Sample fine-tuning commands (not executed automatically)"
echo "To run LoRA fine-tuning example:"
echo "uv run --frozen --no-sync examples/llm_finetune/finetune.py -c examples/llm_finetune/llama3_2/llama3_2_1b_squad_peft.yaml --model.pretrained_model_name_or_path meta-llama/Llama-3.1-8B --packed_sequence.packed_sequence_size 1024 --step_scheduler.max_steps 20"

echo ""
echo "To run QLoRA fine-tuning example:"
echo "uv run --frozen --no-sync examples/llm_finetune/finetune.py -c examples/llm_finetune/llama3_1/llama3_1_8b_squad_qlora.yaml --model.pretrained_model_name_or_path meta-llama/Meta-Llama-3-70B --loss_fn._target_ nemo_automodel.components.loss.te_parallel_ce.TEParallelCrossEntropy --step_scheduler.local_batch_size 1 --packed_sequence.packed_sequence_size 1024 --step_scheduler.max_steps 20"

echo ""
echo "To run Full Fine-tuning example:"
echo "uv run --frozen --no-sync examples/llm_finetune/finetune.py -c examples/llm_finetune/qwen/qwen3_8b_squad_spark.yaml --model.pretrained_model_name_or_path Qwen/Qwen3-8B --step_scheduler.local_batch_size 1 --step_scheduler.max_steps 20 --packed_sequence.packed_sequence_size 1024"

# Step 11: Validate successful training completion
echo ""
echo "Step 11: Training validation (example output)"
echo "After training, inspect the checkpoint directory:"
echo "ls -lah checkpoints/LATEST/"

# Step 12: Cleanup and rollback (optional)
echo ""
echo "Step 12: Cleanup commands (not executed automatically)"
echo "To remove virtual environment:"
echo "rm -rf .venv"
echo ""
echo "To remove cloned repository:"
echo "cd .."
echo "rm -rf Automodel"
echo ""
echo "To remove uv:"
echo "pip3 uninstall uv"
echo ""
echo "To clear Python cache:"
echo "rm -rf ~/.cache/pip"

# Step 13: Optional publish to Hugging Face Hub
echo ""
echo "Step 13: Optional publishing to Hugging Face Hub"
echo "To publish the fine-tuned model:"
echo "hf upload my-cool-model checkpoints/LATEST/model"

# Step 14: Next steps
echo ""
echo "Step 14: Next steps"
echo "Copy a recipe for customization:"
echo "cp recipes/llm_finetune/finetune.py my_custom_training.py"
echo ""
echo "Edit configuration for your specific model and data"
echo "Then run: uv run my_custom_training.py"

echo ""
echo "=== NeMo AutoModel Fine-Tuning Automation Complete ==="
echo "Please review the documentation and follow the steps manually for the fine-tuning execution."