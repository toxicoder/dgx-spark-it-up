# NVIDIA DGX Spark Multi-Agent Chatbot Automation

This tool automates the setup and deployment of the multi-agent chatbot system following the official guide at https://build.nvidia.com/spark/multi-agent-chatbot.

## Features

- Automate Docker permissions setup
- Clone the required repository
- Download necessary model files
- Start Docker containers for the chatbot system
- Test container status
- Cleanup containers and volumes
- Open UI in browser
- SSH tunnel setup guidance

## Installation

To use this tool, simply make the script executable:

```bash
chmod +x multi-agent-chatbot-automation.sh
```

## Usage

### Basic Commands

```bash
# Show help
./multi-agent-chatbot-automation.sh --help

# Setup the multi-agent chatbot environment
./multi-agent-chatbot-automation.sh --setup

# Run the multi-agent chatbot containers
./multi-agent-chatbot-automation.sh --run

# Test if containers are running
./multi-agent-chatbot-automation.sh --test

# Cleanup and rollback containers
./multi-agent-chatbot-automation.sh --cleanup

# Open the UI in browser
./multi-agent-chatbot-automation.sh --ui
```

## Requirements

- Docker installed and running
- Git installed
- Bash shell
- Internet connectivity (for downloading models)

## Workflow

The automation script follows these steps:

1. **Setup** (`--setup`):
   - Verify Docker installation
   - Configure Docker permissions
   - Clone the repository
   - Run model download script
   - Download required models (gpt-oss-120B, Deepseek-Coder, Qwen3-Embedding)

2. **Run** (`--run`):
   - Start Docker containers
   - Wait for containers to become healthy
   - Build and deploy all services

3. **Test** (`--test`):
   - Check if all containers are running

4. **Cleanup** (`--cleanup`):
   - Stop and remove containers
   - Remove PostgreSQL data volume

5. **UI** (`--ui`):
   - Open the frontend UI in your default browser at http://localhost:3000

## Configuration

The script will automatically:
- Check Docker installation and permissions
- Clone the repository from NVIDIA/dgx-spark-playbooks
- Download models from HuggingFace
- Start all required containers with Docker Compose

## Troubleshooting

### Common Issues

1. **Docker permissions** - Ensure your user is in the docker group or run with sudo
2. **Model download timeout** - May take 30 minutes to 2 hours depending on network speed
3. **Container startup timeout** - May take 10-20 minutes to build and start all containers
4. **Port conflicts** - Ensure ports 3000 and 8000 are available

### Solutions

- For Docker permission issues, run `sudo usermod -aG docker $USER && newgrp docker`
- For slow downloads, ensure good internet connectivity
- For container issues, check `docker ps` for error details
- For port conflicts, check `lsof -i :3000` or `lsof -i :8000`

## Security

This tool follows security best practices:

- Uses standard Docker security practices
- Runs containers with appropriate isolation
- Downloads models from official sources
- Cleans up resources properly

## Contributing

We welcome contributions to improve this tool. To contribute:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

[MIT](/LICENSE)

## References

- [NVIDIA DGX Spark Multi-Agent Chatbot Guide](https://build.nvidia.com/spark/multi-agent-chatbot)
- [NVIDIA DGX Spark Playbooks Repository](https://github.com/NVIDIA/dgx-spark-playbooks)