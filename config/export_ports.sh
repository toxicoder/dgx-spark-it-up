#!/bin/bash

# Port Configuration Export Script
# This script reads the port configuration and exports environment variables

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default config file path
CONFIG_FILE="$SCRIPT_DIR/port_config.txtpb"

# Function to load configuration from txtpb file
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "Error: Configuration file not found: $CONFIG_FILE" >&2
        exit 1
    fi
    
    # Source the configuration file
    # Using eval to set variables from key:value pairs
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        
        # Parse key:value pairs
        if [[ "$line" =~ ^([^:]+):[[:space:]]*(.*)$ ]]; then
            key="${BASH_REMATCH[1]# }"
            value="${BASH_REMATCH[2]# }"
            # Export as environment variable (remove quotes if present)
            export "$key"="${value%\"}"
            export "$key"="${value%\"}"
        fi
    done < "$CONFIG_FILE"
}

# Function to validate ports are not in use
validate_ports() {
    echo "Validating ports..."
    
    # Check if ports are already in use
    for port in "$ollama" "$arangodb" "$qdrant_http" "$qdrant_grpc" "$app_host" "$sentence_transformers" "$open_webui" "$milvus" "$vllm"; do
        if [[ -n "$port" && "$port" != "0" ]]; then
            if lsof -i :"$port" >/dev/null 2>&1; then
                echo "Warning: Port $port is already in use!" >&2
                read -rp "Do you want to continue anyway? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    echo "Exiting due to port conflict"
                    exit 1
                fi
            fi
        fi
    done
}

# Function to display current configuration
show_config() {
    echo "Current Port Configuration:"
    echo "=========================="
    echo "Ollama: $ollama"
    echo "ArangoDB: $arangodb"
    echo "Qdrant HTTP: $qdrant_http"
    echo "Qdrant gRPC: $qdrant_grpc"
    echo "App Host: $app_host"
    echo "Sentence Transformers: $sentence_transformers"
    echo "Open WebUI: $open_webui"
    echo "Milvus: $milvus"
    echo "vLLM: $vllm"
    echo ""
    echo "API Keys:"
    echo "NVIDIA API Key: ${nvidia_api_key:+<set>}"
    echo "HF Token: ${hf_token:+<set>}"
}

# Main execution
main() {
    echo "Loading port configuration from $CONFIG_FILE..."
    
    # Load configuration
    load_config
    
    # Validate ports
    validate_ports
    
    # Show configuration
    show_config
    
    echo "Environment variables exported successfully!"
    echo "To use these variables in your current shell, run:"
    echo "source $SCRIPT_DIR/export_ports.sh"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi