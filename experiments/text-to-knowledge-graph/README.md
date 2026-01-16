# Text-to-Knowledge-Graph Automation

This directory contains an automated script to set up and run the text-to-knowledge-graph system from NVIDIA's dgx-spark-playbooks.

## Features

- Fully automated setup of Ollama, ArangoDB, and Next.js frontend
- BATS tests for verifying the automation process
- Easy deployment and cleanup

## Prerequisites

- Docker and Docker Compose installed
- NVIDIA GPU with drivers (for optimal performance)
- Git installed

## Usage

```bash
# Run the automation script
./txt2kg-automation.sh

# Run BATS tests
./run_tests.sh
```

## What this automation does

1. Clones the txt2kg repository if not already present
2. Navigates to the assets directory
3. Starts all required services using the start.sh script
4. Pulls a default Ollama model (llama3.1:8b)
5. Waits for services to be ready
6. Provides instructions for accessing the web interface
