#!/bin/bash

# Test script to verify port configuration works correctly
# This script tests the configuration and checks for port conflicts

set -e  # Exit on any error

echo "=== Port Configuration Test ==="

# Source the configuration
if [[ -f "$HOME/config/export_ports.sh" ]]; then
    source "$HOME/config/export_ports.sh"
elif [[ -f "/workspaces/dgx-spark-it-up/config/export_ports.sh" ]]; then
    source "/workspaces/dgx-spark-it-up/config/export_ports.sh"
else
    echo "Error: export_ports.sh not found"
    exit 1
fi

echo "Configuration loaded successfully!"
echo "----------------------------------------"

# Display current configuration
echo "Current Configuration:"
echo "Ollama Port: $ollama"
echo "ArangoDB Port: $arangodb"
echo "Qdrant HTTP Port: $qdrant_http"
echo "Qdrant gRPC Port: $qdrant_grpc"
echo "App Host Port: $app_host"
echo "Sentence Transformers Port: $sentence_transformers"
echo "Open WebUI Port: $open_webui"
echo "Milvus Port: $milvus"
echo "vLLM Port: $vllm"
echo ""

# Check if ports are in valid range (10000-20000)
echo "Validating port ranges..."
valid_ports=0
total_ports=9

for port in "$ollama" "$arangodb" "$qdrant_http" "$qdrant_grpc" "$app_host" "$sentence_transformers" "$open_webui" "$milvus" "$vllm"; do
    if [[ -n "$port" && "$port" != "0" ]]; then
        if [[ "$port" -ge 10000 && "$port" -le 20000 ]]; then
            echo "✓ Port $port is in valid range (10000-20000)"
            ((valid_ports++))
        else
            echo "✗ Port $port is NOT in valid range (10000-20000)"
        fi
    fi
done

echo ""
echo "Port range validation: $valid_ports/$total_ports ports valid"
echo ""

# Check for port conflicts (only if lsof is available)
if command -v lsof &> /dev/null; then
    echo "Checking for port conflicts..."
    conflicts=0
    for port in "$ollama" "$arangodb" "$qdrant_http" "$qdrant_grpc" "$app_host" "$sentence_transformers" "$open_webui" "$milvus" "$vllm"; do
        if [[ -n "$port" && "$port" != "0" ]]; then
            if lsof -i :"$port" >/dev/null 2>&1; then
                echo "⚠ Port $port is already in use"
                ((conflicts++))
            fi
        fi
    done
    
    if [[ $conflicts -eq 0 ]]; then
        echo "✓ No port conflicts detected"
    else
        echo "⚠ $conflicts port conflicts found"
    fi
else
    echo "lsof not available, skipping port conflict check"
fi

echo ""
echo "=== Test Complete ==="