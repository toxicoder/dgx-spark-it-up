#!/bin/bash

# SPDX-FileCopyrightText: Copyright (c) 1993-2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e  # Exit on any error

echo "=== Text-to-Knowledge-Graph Automation ==="

# Define paths
TXT2KG_REPO="https://github.com/NVIDIA/dgx-spark-playbooks"
TXT2KG_DIR="$HOME/dgx-spark-playbooks"
ASSETS_DIR="$TXT2KG_DIR/nvidia/txt2kg/assets"

# Check if required tools are installed
echo "Checking prerequisites..."
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    exit 1
fi

if ! command -v docker compose &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed"
    exit 1
fi

# Step 1: Clone the repository if not already present
echo "Step 1: Checking for txt2kg repository..."
if [ ! -d "$TXT2KG_DIR" ]; then
    echo "Cloning txt2kg repository..."
    git clone "$TXT2KG_REPO" "$TXT2KG_DIR"
    echo "Repository cloned successfully"
else
    echo "Repository already exists at $TXT2KG_DIR"
fi

# Step 2: Navigate to assets directory
echo "Step 2: Navigating to assets directory..."
cd "$ASSETS_DIR"

# Step 3: Start the txt2kg services
echo "Step 3: Starting txt2kg services..."
./start.sh

# Step 4: Wait for services to be ready (with timeout)
echo "Step 4: Waiting for services to be ready..."
timeout=120  # 2 minutes timeout
elapsed=0

# Check if web interface is available
while [ $elapsed -lt $timeout ]; do
    if curl -f http://localhost:3001 >/dev/null 2>&1; then
        echo "Web interface is ready!"
        break
    fi
    echo "Waiting for web interface to be ready... ($((timeout - elapsed))s remaining)"
    sleep 5
    elapsed=$((elapsed + 5))
done

if [ $elapsed -ge $timeout ]; then
    echo "Warning: Timeout waiting for web interface. Services may still be starting."
fi

# Step 5: Pull an Ollama model (optional but recommended)
echo "Step 5: Pulling default Ollama model..."
echo "Note: If this fails due to model already being pulled, it's not an issue."
docker exec ollama-compose ollama pull llama3.1:8b || echo "Model may already be pulled or failed to download"

# Step 6: Display access information
echo ""
echo "=== Setup Complete ==="
echo "txt2kg is now running!"
echo ""
echo "Access the web interface at: http://localhost:3001"
echo "ArangoDB Web Interface: http://localhost:8529"
echo "Ollama API: http://localhost:11434"
echo ""
echo "Next steps:"
echo "1. Open http://localhost:3001 in your browser"
echo "2. Upload documents and start building your knowledge graph!"
echo "3. To stop services, run: ./stop.sh"
echo ""
echo "Note: The default model llama3.1:8b is now available for knowledge extraction."