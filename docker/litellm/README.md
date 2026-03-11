# LiteLLM Proxy Server with Docker Compose

This directory contains the configuration for running [LiteLLM](https://litellm.ai) - a lightweight proxy that standardizes API calls across different LLM providers - using Docker Compose with PostgreSQL backend storage.

## Features

- **LiteLLM Proxy**: Standardize API calls across OpenAI, Anthropic, Gemini, and more
- **PostgreSQL Database**: Persistent storage for models, users, and spending metrics
- **NVIDIA NIM Integration**: Access local NVIDIA NIM models via `host.docker.internal`
- **Ollama Integration**: Access local Ollama models via `host.docker.internal`
- **Hybrid Cloud/Local**: Mix local models with cloud API providers
- **Preconfigured Setup**: Ready-to-use configuration files
- **Single GPU Sharing**: Multiple inference services share GPU via `--gpus "all"`

## Prerequisites

- Docker (v24 or later recommended)
- Docker Compose (v2.20 or later recommended)
- NVIDIA Container Toolkit (for GPU-accelerated containers)
- At least 4GB RAM available
- At least 10GB disk space for data persistence

## Installation

### Step 1: Clone and Navigate

```bash
cd docker/litellm
```

### Step 2: Configure Environment

Copy the example environment file and customize it:

```bash
cp .env.example .env
```

Edit `.env` with your specific configuration:

```bash
# Required: Set your master key for proxy authentication
LITELLM_MASTER_KEY=sk-$(openssl rand -base64 32 | head -c 32)

# Required: Set your API keys for the models you want to use
OPENAI_API_KEY=sk-proj-your-openai-key
ANTHROPIC_API_KEY=sk-ant-your-anthropic-key
GEMINI_API_KEY=your-gemini-key

# Required: NVIDIA NGC API key for local NIM models
NGC_API_KEY=your-ngc-api-key

# Recommended: Set a strong database password
# Use: openssl rand -base64 32
POSTGRES_PASSWORD=your_secure_password_here
```

### Step 3: Configure Models (Optional)

The `litellm_config.yaml` file is preconfigured with:

- **NVIDIA NIM Models**: Llama 3.1 8B, Qwen 3 32B
- **Ollama Models**: Llama 4 8B, DeepSeek Coder 16B
- **NVIDIA API Catalog**: Llama 3.1 Nemotron 70B

Edit `litellm_config.yaml` to add or modify models as needed.

### Step 4: Start the Services

Using the spark_init.sh script (recommended):

```bash
./spark_init.sh start
```

Or using docker-compose directly:

```bash
docker-compose up -d
```

### Step 5: Verify Installation

Check that all containers are running:

```bash
./spark_init.sh status
```

Or:

```bash
docker-compose ps
```

Expected output:
```
NAME               IMAGE                        STATUS
litellm-proxy      ghcr.io/berriai/litellm:...  Up (healthy)
ollama             ollama/ollama:latest         Up (healthy)
nim-llama-8b       nvcr.io/...                  Up (healthy)
nim-qwen-32b       nvcr.io/...                  Up (healthy)
litellm-database   postgres:16-alpine           Up (healthy)
```

### Step 6: Test LiteLLM

Test the proxy with a simple API call:

```bash
# Test with OpenAI-compatible endpoint
curl http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  -d '{
    "model": "nim-llama-3.1-8b",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

## Usage

### Using the spark_init.sh Script

The `spark_init.sh` script provides convenient commands for managing services:

```bash
# Start all services
./spark_init.sh start

# Stop all services
./spark_init.sh stop

# Restart services
./spark_init.sh restart

# Show service status
./spark_init.sh status

# View logs (follow mode)
./spark_init.sh logs

# Full cleanup (stops and removes containers + volumes)
./spark_init.sh cleanup

# Show GPU information
./spark_init.sh gpu-info

# Show help
./spark_init.sh help
```

### Using Docker Compose Directly

```bash
# Start in background
docker-compose up -d

# Start and view logs
docker-compose up

# Stop containers (keeps data)
docker-compose down

# Stop and remove everything including volumes
docker-compose down -v

# Pull latest images
docker-compose pull

# Update and restart
docker-compose up -d --build
```

### Viewing Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f litellm
docker-compose logs -f ollama
docker-compose logs -f nim-llama-8b
docker-compose logs -f nim-qwen-32b
docker-compose logs -f db
```

### Running Commands

```bash
# Execute command in container
docker-compose exec litellm litellm --help

# Access PostgreSQL database
docker-compose exec db psql -U llmproxy -d litellm
```

### Checking Health

```bash
# LiteLLM health endpoint
curl http://localhost:4000/health

# Available models
curl http://localhost:4000/models \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY"

# Ollama health
curl http://localhost:11434/api/health

# NIM Llama health
curl http://localhost:8000/v1/models

# NIM Qwen health
curl http://localhost:8001/v1/models
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `LITELLM_MASTER_KEY` | `sk-admin-1234` | Admin key for proxy (must start with `sk-`) |
| `POSTGRES_USER` | `llmproxy` | PostgreSQL username |
| `POSTGRES_PASSWORD` | *(required)* | PostgreSQL password |
| `POSTGRES_DB` | `litellm` | PostgreSQL database name |
| `DATABASE_URL` | *(auto-generated)* | PostgreSQL connection string |
| `OPENAI_API_KEY` | *(required)* | OpenAI API key for OpenAI models |
| `ANTHROPIC_API_KEY` | *(required)* | Anthropic API key for Claude models |
| `GEMINI_API_KEY` | *(required)* | Google Gemini API key |
| `STORE_MODEL_IN_DB` | `false` | Store models in database for UI management |
| `LITELLM_PORT` | `4000` | Host port for LiteLLM access |
| `NGC_API_KEY` | *(required)* | NVIDIA NGC API key for NIM images |
| `LOCAL_NIM_CACHE` | `$HOME/.cache/nim` | Cache directory for NIM models |
| `GPU_RESOURCE` | `all` | GPU allocation (use `all` for shared) |
| `OLLAMA_PORT` | `11434` | Port for Ollama |
| `NIM_LLAMA_PORT` | `8000` | Port for Llama NIM |
| `NIM_QWEN_PORT` | `8001` | Port for Qwen NIM |
| `NIM_SHM_SIZE` | `16GB` | Shared memory size for NIM containers |

### Service Ports

| Service | Port | Description |
|---------|------|-------------|
| LiteLLM | 4000 | Unified API proxy |
| Ollama | 11434 | Local LLM server |
| NIM Llama | 8000 | Llama 3.1 8B inference |
| NIM Qwen | 8001 | Qwen 3 32B inference |
| PostgreSQL | 5432 | Database (internal) |

### Model Configuration

The `litellm_config.yaml` file defines available models. Key configuration options:

#### Local NVIDIA NIM Models
```yaml
- model_name: nim-llama-3.1-8b
  litellm_params:
    model: nvidia_nim/meta/llama-3.1-8b-instruct
    api_base: http://host.docker.internal:8000/v1
```

#### Local Ollama Models
```yaml
- model_name: ollama-llama4-8b
  litellm_params:
    model: ollama/llama4:8b
    api_base: http://host.docker.internal:11434
```

#### API Provider Keys
Use `os.environ/VAR_NAME` syntax to load keys from environment:
```yaml
api_key: os.environ/NVIDIA_NIM_API_KEY
```

## GPU Configuration

This setup uses `--gpus "all"` to share the GPU across all inference services:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [gpu]
```

### Single GPU Mode
When you have a single GPU, all containers share it via Docker's resource management.

### Multiple GPU Mode
For systems with multiple GPUs, you can specify device IDs:
```yaml
device_ids: ["0", "1"]
```

## Maintenance

### Database Backups

Create a backup:
```bash
docker-compose exec db pg_dump -U llmproxy litellm > backup.sql
```

Restore from backup:
```bash
docker-compose exec -T db psql -U llmproxy -d litellm < backup.sql
```

### Clearing Cache

LiteLLM stores spent API keys and metrics in a config directory:
```bash
# Stop services
./spark_init.sh stop

# Remove config data
docker volume rm litellm-config-data

# Restart
./spark_init.sh start
```

### NIM Model Cache

To clear NIM model cache:
```bash
# Stop services
./spark_init.sh stop

# Remove NIM cache
docker volume rm litellm-nim-cache

# Restart
./spark_init.sh start
```

### Ollama Models

To clear Ollama models:
```bash
# Stop services
./spark_init.sh stop

# Remove Ollama data
docker volume rm litellm-ollama-data

# Restart
./spark_init.sh start
```

## Troubleshooting

### Container Won't Start

Check logs:
```bash
docker-compose logs
```

Common issues:
- Port 4000 already in use → Change `LITELLM_PORT` in `.env`
- Port 11434 already in use → Change `OLLAMA_PORT` in `.env`
- Port 8000 already in use → Change `NIM_LLAMA_PORT` in `.env`
- Port 8001 already in use → Change `NIM_QWEN_PORT` in `.env`
- Database connection failed → Verify `DATABASE_URL` in `.env`
- Missing NGC_API_KEY → Set `NGC_API_KEY` in `.env`

### GPU Not Working

If containers can't access the GPU:

1. Verify NVIDIA Docker Toolkit is installed:
   ```bash
   docker info | grep -i nvidia
   ```

2. Check GPU availability:
   ```bash
   nvidia-smi
   ```

3. Restart Docker daemon:
   ```bash
   sudo systemctl restart docker
   ```

### Health Check Failing

Wait 60-90 seconds after startup for services to be ready. Check health:
```bash
./spark_init.sh status
```

### NGC Authentication Failed

If you see NGC authentication errors:

1. Verify NGC_API_KEY is set correctly in `.env`
2. Check that the key has access to the NIM images
3. Try logging in manually:
   ```bash
   echo "$NGC_API_KEY" | docker login nvcr.io --username '$oauthtoken' --password-stdin
   ```

### Port Already in Use

If a port is already in use, change it in `.env`:

```bash
OLLAMA_PORT=11435
NIM_LLAMA_PORT=8002
NIM_QWEN_PORT=8003
LITELLM_PORT=4001
```

Then restart:
```bash
./spark_init.sh restart
```

### Service Health Check Timeout

Some services take longer to initialize:

- Ollama: ~60 seconds
- NIM models: ~120 seconds
- LiteLLM: ~60 seconds

Wait for all services to show "healthy" before testing.

## Support

- [LiteLLM Documentation](https://docs.litellm.ai/)
- [LiteLLM GitHub](https://github.com/BerriAI/litellm)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [NVIDIA NIM Documentation](https://docs.nvidia.com/nim/)

## License

This configuration is provided as-is for use with the NVIDIA DGX Spark Utilities project.