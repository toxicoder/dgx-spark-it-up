# LiteLLM Proxy Server with Docker Compose

This directory contains the configuration for running [LiteLLM](https://litellm.ai) - a lightweight proxy that standardizes API calls across different LLM providers - using Docker Compose with PostgreSQL backend storage.

## Features

- **LiteLLM Proxy**: Standardize API calls across OpenAI, Anthropic, Gemini, and more
- **PostgreSQL Database**: Persistent storage for models, users, and spending metrics
- **NVIDIA NIM Integration**: Access local NVIDIA NIM models via `host.docker.internal`
- **Ollama Integration**: Access local Ollama models via `host.docker.internal`
- **Hybrid Cloud/Local**: Mix local models with cloud API providers
- **Preconfigured Setup**: Ready-to-use configuration files

## Prerequisites

- Docker (v24 or later recommended)
- Docker Compose (v2.20 or later recommended)
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

# Recommended: Generate a strong database password
# Use: openssl rand -base64 32
POSTGRES_PASSWORD=your_secure_password_here
```

### Step 3: Configure Models (Optional)

The `litellm_config.yaml` file is preconfigured with:

- **NVIDIA NIM Models**: Llama 3.1 8B, Qwen 3 32B (ports 8000, 8001)
- **Ollama Models**: Llama 4 8B, DeepSeek Coder 16B
- **NVIDIA API Catalog**: Llama 3.1 Nemotron 70B (via API key)

Edit `litellm_config.yaml` to add or modify models as needed.

### Step 4: Start the Services

```bash
docker-compose up -d
```

### Step 5: Verify Installation

Check that both containers are running:

```bash
docker-compose ps
```

Expected output:
```
NAME               IMAGE                        STATUS
litellm-proxy      ghcr.io/berriai/litellm:...  Up (healthy)
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
Use `os.environ/KEY_NAME` syntax to load keys from environment:
```yaml
api_key: os.environ/NVIDIA_NIM_API_KEY
```

### Security Recommendations

1. **Use Strong Master Key**: Generate with `openssl rand -base64 32 | head -c 32`
2. **Store API Keys Securely**: Use `os.environ/VAR_NAME` in config for sensitive keys
3. **Enable HTTPS**: Use a reverse proxy (NGINX, Traefik) with SSL certificates
4. **Limit Network Exposure**: Don't expose PostgreSQL port (5432) to the public
5. **Regular Backups**: Implement database backup procedures (see Maintenance)
6. **Update Regularly**: Keep Docker images updated for security patches

### Common Use Cases

#### Using Only Local Models
Comment out unused API keys in `.env`:
```env
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
GEMINI_API_KEY=
```

#### Using API Providers Only
Remove or comment out the local NIM/Ollama configurations in `litellm_config.yaml`

#### Adding New Models
Edit `litellm_config.yaml` and restart the service:
```yaml
- model_name: custom-model
  litellm_params:
    model: openai/model-name
    api_base: https://api.example.com/v1
    api_key: your-api-key
```

## Usage

### Starting Services

```bash
# Start in background
docker-compose up -d

# Start and view logs
docker-compose up
```

### Stopping Services

```bash
# Stop containers (keeps data)
docker-compose down

# Stop and remove everything including volumes
docker-compose down -v
```

### Viewing Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f litellm
docker-compose logs -f db
```

### Running Commands

```bash
# Execute command in container
docker-compose exec litellm litellm --help

# Access PostgreSQL database
docker-compose exec db psql -U llmproxy -d litellm
```

### Checking LiteLLM Health

```bash
# Health endpoint
curl http://localhost:4000/health

# Available models
curl http://localhost:4000/models \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY"
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

### Updating LiteLLM

```bash
# Pull latest images
docker-compose pull

# Update and restart
docker-compose up -d --build
```

### Database Maintenance

Clean up old data:
```bash
docker-compose exec db vacuumdb -U llmproxy -d litellm -v
```

### Clearing Cache

LiteLLM stores spent API keys and metrics in a config directory:
```bash
# Stop services
docker-compose down

# Remove config data
docker volume rm litellm-config-data

# Restart
docker-compose up -d
```

## Troubleshooting

### Container Won't Start

Check logs:
```bash
docker-compose logs
```

Common issues:
- Port 4000 already in use → Change `LITELLM_PORT` in `.env`
- Database connection failed → Verify `DATABASE_URL` in `.env`
- Missing API keys → Ensure all required API keys are set

### LiteLLM Not Accessible

If LiteLLM isn't accessible:
1. Verify `LITELLM_PORT` matches your host port
2. Check firewall settings allow traffic on port 4000
3. Ensure reverse proxy is correctly configured (if used)

### Model Not Available

If a model is not responding:
1. Check if the service (NIM/Ollama) is running on the host
2. Verify the port in `litellm_config.yaml` matches the actual port
3. Test the service directly: `curl http://localhost:8000/v1/models`

### Database Connection Failed

Reset database (deletes all data):
```bash
docker-compose down -v
docker-compose up -d
```

### Health Check Failing

Wait 60-90 seconds after startup for services to be ready. Check health:
```bash
docker-compose ps
```

### API Key Errors

If getting authentication errors:
1. Verify API key is set in `.env` file
2. Check `litellm_config.yaml` uses `os.environ/VAR_NAME` syntax
3. Restart LiteLLM after updating `.env`: `docker-compose restart litellm`

## Support

- [LiteLLM Documentation](https://docs.litellm.ai/)
- [LiteLLM GitHub](https://github.com/BerriAI/litellm)
- [Docker Compose Docs](https://docs.docker.com/compose/)

## License

This configuration is provided as-is for use with the NVIDIA DGX Spark Utilities project.