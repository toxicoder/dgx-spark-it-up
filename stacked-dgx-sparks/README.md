# NVIDIA DGX Spark Stacked Multi-Node Automation

This tool automates the complete multi-node TensorRT-LLM setup process on NVIDIA DGX Spark devices, following the official guide at [https://build.nvidia.com/spark/trt-llm/stacked-sparks](https://build.nvidia.com/spark/trt-llm/stacked-sparks).

## Features

- Configure network connectivity settings
- Verify Docker permissions and prerequisites
- Create OpenMPI hostfiles for multi-node operations
- Start TRT-LLM containers on all nodes
- Deploy models and start the TensorRT-LLM server
- Test the deployed model API
- Cleanup and rollback environment

## Installation

To use this tool, simply make the script executable:

```bash
chmod +x stacked-dgx-sparks-automation.sh
```

## Usage

### Basic Commands

```bash
# Show help
./stacked-dgx-sparks-automation.sh --help

# Configure connection settings
./stacked-dgx-sparks-automation.sh --configure

# Verify environment and prerequisites
./stacked-dgx-sparks-automation.sh --verify

# Setup multi-node stacked DGX Sparks environment
./stacked-dgx-sparks-automation.sh --setup --node 169.254.35.62 --hf-token your-hf-token

# Deploy model and start server
./stacked-dgx-sparks-automation.sh --deploy --model meta-llama/Llama-3.1-70B --hf-token your-hf-token

# Test the deployed model
./stacked-dgx-sparks-automation.sh --test

# Cleanup and rollback environment
./stacked-dgx-sparks-automation.sh --rollback
```

### Command Options

- `-h, --help`: Show help message
- `-c, --configure`: Configure connection settings
- `-v, --verify`: Verify environment and prerequisites
- `-s, --setup`: Setup multi-node stacked DGX Sparks environment
- `-d, --deploy`: Deploy model and start server
- `-t, --test`: Test the deployed model
- `-r, --rollback`: Cleanup and rollback environment
- `-u, --username USER`: Specify username (overrides config)
- `-H, --hostname HOST`: Specify hostname (overrides config)
- `-n, --node NODE`: Specify secondary node IP (for multi-node)
- `-m, --model MODEL`: Specify model to deploy (default: nvidia/Qwen3-235B-A22B-FP4)
- `-p, --port PORT`: Specify server port (default: 8355)
- `-t, --tp-size TP_SIZE`: Specify tensor parallelism size (default: 2)
- `-k, --hf-token TOKEN`: Specify Hugging Face token (required for model download)

## Configuration

Connection settings are stored in `~/.dgx-spark-stacked-config` after running `--configure`.

## Requirements

- SSH client (OpenSSH)
- Docker client
- Bash shell
- Network connectivity between nodes
- Hugging Face token for model downloads

## Troubleshooting

### Common Issues

1. **SSH connection fails** - Ensure your SSH client is installed and configured properly
2. **Docker permissions** - Run `sudo usermod -aG docker $USER` and re-login
3. **Network connectivity** - Verify physical QSFP cable connections and IP assignments
4. **Model download failures** - Ensure your Hugging Face token is valid and has access to the model

### Solutions

- For SSH connection issues, ensure the DGX Spark devices are powered on and accessible
- For Docker permissions: `sudo usermod -aG docker $USER && newgrp docker`
- For networking: Run `ip addr show` to verify interface configuration
- For model download issues, verify your Hugging Face token and model access permissions
- For SSH issues: Verify mDNS resolution with `ping spark-host.local`

## References

- [NVIDIA DGX Spark Documentation](https://build.nvidia.com/spark/trt-llm/stacked-sparks)
- [TensorRT-LLM Documentation](https://nvidia.github.io/TensorRT-LLM/)
- [SSH Protocol Documentation](https://en.wikipedia.org/wiki/Secure_Shell)

---

## Usage Examples

### Purpose

This document provides practical usage examples for the stacked DGX Sparks automation script.

#### 1. Configure Connection Settings

```bash
./stacked-dgx-sparks-automation.sh --configure
```

#### 2. Verify Environment

```bash
./stacked-dgx-sparks-automation.sh --verify
```

### Multi-Node Setup

#### 3. Setup Multi-Node Environment

```bash
./stacked-dgx-sparks-automation.sh --setup \
  --node 192.168.1.101 \
  --hf-token your-huggingface-token
```

#### 4. Deploy Model and Start Server

```bash
./stacked-dgx-sparks-automation.sh --deploy \
  --model meta-llama/Llama-3.1-70B \
  --hf-token your-huggingface-token
```

### Testing and Cleanup

#### 5. Test Deployed Model

```bash
./stacked-dgx-sparks-automation.sh --test
```

#### 6. Cleanup Environment

```bash
./stacked-dgx-sparks-automation.sh --rollback
```

### Advanced Usage

#### 7. Using Specific Parameters

```bash
./stacked-dgx-sparks-automation.sh --deploy \
  --model nvidia/Qwen3-235B-A22B-FP4 \
  --port 8356 \
  --tp-size 4 \
  --hf-token your-huggingface-token
```

#### 8. Specifying Connection Details Directly

```bash
./stacked-dgx-sparks-automation.sh --setup \
  --username myuser \
  --hostname spark-primary \
  --node 192.168.1.101 \
  --hf-token your-huggingface-token
```

### Complete Workflow Example

Here's a complete workflow to set up and run TRT-LLM on a multi-node DGX Spark cluster:

1. **Configure connection settings:**

   ```bash
   ./stacked-dgx-sparks-automation.sh --configure
   ```

2. **Setup environment on both nodes:**

   ```bash
   ./stacked-dgx-sparks-automation.sh --setup \
     --node 192.168.1.101 \
     --hf-token your-huggingface-token
   ```

3. **Deploy and start the model server:**

   ```bash
   ./stacked-dgx-sparks-automation.sh --deploy \
     --model nvidia/Qwen3-235B-A22B-FP4 \
     --hf-token your-huggingface-token
   ```

4. **Test the deployed model:**

   ```bash
   ./stacked-dgx-sparks-automation.sh --test
   ```

5. **Cleanup when done:**

   ```bash
   ./stacked-dgx-sparks-automation.sh --rollback
   ```

#### Expected Output

When running successfully, you should see output similar to:

```bash
[INFO] Verifying SSH client availability...
[INFO] SSH client version: OpenSSH_9.6p1 Ubuntu-3ubuntu13.14, OpenSSL 3.0.13 30 Jan 2024
[INFO] Verifying Docker client availability...
[INFO] Docker client version: Docker version 27.2.1, build 792c2b0
[INFO] Checking Docker permissions...
[INFO] Docker permissions are correctly configured