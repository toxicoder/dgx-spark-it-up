# Port Configuration

This directory contains the centralized port configuration for the DGX Spark project.

## Files

- `ports.proto` - Protocol buffer schema defining the configuration structure
- `port_config.txtpb` - Actual configuration values in text format
- `export_ports.sh` - Bash script to export environment variables from config

## Usage

### Source the configuration
```bash
source config/export_ports.sh
```

### Using in Docker Compose
The configuration is designed to work with Docker Compose variable substitution:
```yaml
services:
  app:
    ports:
      - "${app_host}:3000"
    environment:
      - OLLAMA_BASE_URL=http://ollama:${ollama}/v1
      - ARANGODB_URL=http://arangodb:${arangodb}
```

## Configuration Structure

The configuration includes:
- Port mappings for all services (Ollama, ArangoDB, Qdrant, etc.)
- API keys (NVIDIA_API_KEY, HF_TOKEN)
- Default values are set based on existing configurations

## API Key Security

API keys are stored in the configuration file but should be set via environment variables for security:
```bash
# Set API keys in your environment
export NVIDIA_API_KEY="your-nvidia-api-key-here"
export HF_TOKEN="your-huggingface-token-here"

# Then source the configuration
source config/export_ports.sh
```

For Docker Compose, you can pass the environment variables:
```yaml
services:
  app:
    environment:
      - NVIDIA_API_KEY=${NVIDIA_API_KEY}
      - HF_TOKEN=${HF_TOKEN}
```

## Customization

To customize ports, modify `port_config.txtpb`:

```bash
# Edit the file directly
nano config/port_config.txtpb
```

Or set environment variables before sourcing:

```bash
export ollama=12345
source config/export_ports.sh