#!/usr/bin/env bash

# =============================================================================
# spark_init.sh - Initialize NVIDIA NIM and Ollama inference stack for DGX Spark
# =============================================================================
#
# This script orchestrates the startup of the complete inference stack including:
# - Ollama (local LLM server)
# - NVIDIA NIM Llama 3.1 8B (optimized for Blackwell)
# - NVIDIA NIM Qwen3 32B (FP4 quantized)
# - LiteLLM (unified API proxy)
#
# GPU Allocation:
#   - Uses --gpus "all" to share single GPU across all inference services
#   - Docker and NVIDIA Container Toolkit handle resource allocation
#
# Environment Variables:
#   NGC_API_KEY          - Your NVIDIA NGC API key (required for NIM images)
#   LOCAL_NIM_CACHE      - Cache directory for NIM models (default: $HOME/.cache/nim)
#   GPU_RESOURCE         - GPU allocation (default: "all")
#   OLLAMA_PORT          - Port for Ollama (default: 11434)
#   NIM_LLAMA_PORT       - Port for Llama NIM (default: 8000)
#   NIM_QWEN_PORT        - Port for Qwen NIM (default: 8001)
#   NIM_SHM_SIZE         - Shared memory size (default: 16GB)
#   LITELLM_PORT         - Port for LiteLLM (default: 4000)
#   DATABASE_URL         - PostgreSQL connection string
#   LITELLM_MASTER_KEY   - Master key for LiteLLM authentication
#   OPENAI_API_KEY       - OpenAI API key (for cloud models via LiteLLM)
#   ANTHROPIC_API_KEY    - Anthropic API key (for Claude via LiteLLM)
#   GEMINI_API_KEY       - Google Gemini API key (for Gemini via LiteLLM)
#
# Usage:
#   spark_init.sh [command]
#
# Commands:
#   start        Start all services (Ollama + NIM models + LiteLLM)
#   stop         Stop all services
#   restart      Restart all services
#   status       Show service status
#   logs         Show service logs (follow mode)
#   cleanup      Stop and remove all containers
#   gpu-info     Show GPU information
#   help         Show this help message
#
# Examples:
#   spark_init.sh start          # Start all services
#   spark_init.sh status         # Show status
#   spark_init.sh logs           # View logs
#   spark_init.sh stop           # Stop all services
#   spark_init.sh cleanup        # Full cleanup (containers + volumes)
# =============================================================================

# Enable strict mode for robust error handling
# -e: Exit on error
# -u: Treat unset variables as error
# -o pipefail: Pipeline fails if any command fails
set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

# Colors for output (default to empty if terminal doesn't support colors)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default port mappings
DEFAULT_OLLAMA_PORT=11434
DEFAULT_NIM_LLAMA_PORT=8000
DEFAULT_NIM_QWEN_PORT=8001
DEFAULT_LITELLM_PORT=4000

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================

# Print an info message with green color prefix.
log() {
    printf "${GREEN}[INFO]${NC} %s\n" "$1"
}

# Print an error message with red color prefix.
error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

# Print a warning message with yellow color prefix.
warning() {
    printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

# Print a debug message with blue color prefix.
debug() {
    printf "${BLUE}[DEBUG]${NC} %s\n" "$1"
}

# =============================================================================
# UTILITIES
# =============================================================================

# Check if a command exists.
command_exists() {
    command -v "$1" &>/dev/null
}

# Check if a port is available.
port_available() {
    local port=$1
    if command_exists lsof; then
        ! lsof -i :"$port" &>/dev/null
    elif command_exists ss; then
        ! ss -tlnp 2>/dev/null | grep -q ":$port "
    elif command_exists netstat; then
        ! netstat -tlnp 2>/dev/null | grep -q ":$port "
    else
        # No way to check, assume available
        return 0
    fi
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

# Verify system prerequisites are met.
check_prerequisites() {
    log "Checking system prerequisites..."

    # Check Docker
    if ! command_exists docker; then
        error "Docker is not installed or not in PATH"
        return 1
    fi
    log "Docker: OK"

    # Check docker-compose or docker compose
    if ! docker compose version &>/dev/null && ! docker-compose --version &>/dev/null; then
        error "Docker Compose is not installed or not in PATH"
        return 1
    fi
    log "Docker Compose: OK"

    # Check NVIDIA Docker Toolkit
    if ! docker info 2>&1 | grep -q "NVIDIA Container Toolkit"; then
        warning "NVIDIA Container Toolkit may not be properly configured"
        warning "GPU-accelerated containers may not work"
    fi
    log "NVIDIA Docker Toolkit: OK"

    # Check NGC_API_KEY is set
    if [[ -z "${NGC_API_KEY:-}" ]]; then
        error "NGC_API_KEY is not set"
        error "Please set NGC_API_KEY in .env file or as environment variable"
        return 1
    fi
    log "NGC_API_KEY: Configured"

    # Check required ports are available
    local ports=(
        "${OLLAMA_PORT:-$DEFAULT_OLLAMA_PORT}"
        "${NIM_LLAMA_PORT:-$DEFAULT_NIM_LLAMA_PORT}"
        "${NIM_QWEN_PORT:-$DEFAULT_NIM_QWEN_PORT}"
        "${LITELLM_PORT:-$DEFAULT_LITELLM_PORT}"
    )

    for port in "${ports[@]}"; do
        if ! port_available "$port"; then
            error "Port $port is already in use"
            warning "Stop existing services or change port in .env"
            return 1
        fi
    done
    log "Ports: Available"

    # Check for GPU
    if command_exists nvidia-smi; then
        local gpu_count=$(nvidia-smi -L 2>/dev/null | wc -l || echo "0")
        if [[ "$gpu_count" -gt 0 ]]; then
            log "GPU detected: $gpu_count device(s)"
            if [[ "$gpu_count" -eq 1 ]]; then
                log "GPU mode: Shared (single GPU)"
            else
                log "GPU mode: Multiple GPUs available"
            fi
        else
            warning "No GPU detected by nvidia-smi"
            warning "Containers may not have GPU access"
        fi
    else
        warning "nvidia-smi not found - GPU status unknown"
    fi

    log "Prerequisites check passed"
    return 0
}

# Validate and load environment variables.
validate_env() {
    log "Validating environment configuration..."

    local env_file="${SCRIPT_DIR}/.env"

    # Check if .env exists
    if [[ ! -f "$env_file" ]]; then
        warning ".env file not found"
        if [[ -f "${env_file}.example" ]]; then
            warning "Copying .env.example to .env..."
            cp "${env_file}.example" "$env_file"
            log "Created .env file. Please edit with your configuration."
            return 1
        fi
        error "No .env or .env.example file found"
        return 1
    fi

    # Source .env file
    set -a
    source "$env_file"
    set +a

    # Validate required variables
    local missing_vars=()

    [[ -z "${NGC_API_KEY:-}" ]] && missing_vars+=("NGC_API_KEY")

    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        error "Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            error "  - $var"
        done
        return 1
    fi

    # Default values if not set
    export OLLAMA_PORT="${OLLAMA_PORT:-$DEFAULT_OLLAMA_PORT}"
    export NIM_LLAMA_PORT="${NIM_LLAMA_PORT:-$DEFAULT_NIM_LLAMA_PORT}"
    export NIM_QWEN_PORT="${NIM_QWEN_PORT:-$DEFAULT_NIM_QWEN_PORT}"
    export LITELLM_PORT="${LITELLM_PORT:-$DEFAULT_LITELLM_PORT}"
    export NIM_SHM_SIZE="${NIM_SHM_SIZE:-16GB}"
    export LOCAL_NIM_CACHE="${LOCAL_NIM_CACHE:-$HOME/.cache/nim}"
    export GPU_RESOURCE="${GPU_RESOURCE:-all}"

    log "Environment validation passed"
    return 0
}

# =============================================================================
# SERVICE MANAGEMENT FUNCTIONS
# =============================================================================

# Start all services.
start_services() {
    log "Starting all services..."

    cd "$SCRIPT_DIR"

    # Ensure cache directory exists
    mkdir -p "$LOCAL_NIM_CACHE"

    # Login to NVIDIA Container Registry
    log "Authenticating with NVIDIA Container Registry..."
    if ! echo "$NGC_API_KEY" | docker login nvcr.io --username '$oauthtoken' --password-stdin; then
        error "Failed to authenticate with NVIDIA Container Registry"
        return 1
    fi
    log "Authentication successful"

    # Pull latest images
    log "Pulling latest container images..."
    if ! docker compose pull; then
        error "Failed to pull one or more container images"
        return 1
    fi
    log "Images pulled successfully"

    # Start services in background
    log "Starting services..."
    if ! docker compose up -d; then
        error "Failed to start services"
        return 1
    fi

    # Wait for services to be healthy
    log "Waiting for services to be healthy..."
    wait_for_services

    log "All services started successfully"
    log ""
    log "Services are now available:"
    log "  LiteLLM:     http://localhost:${LITELLM_PORT:-4000}"
    log "  Ollama:      http://localhost:${OLLAMA_PORT:-11434}"
    log "  NIM Llama:   http://localhost:${NIM_LLAMA_PORT:-8000}"
    log "  NIM Qwen:    http://localhost:${NIM_QWEN_PORT:-8001}"
    log ""
    log "Test the setup:"
    log "  curl http://localhost:${LITELLM_PORT:-4000}/health"
    log "  curl http://localhost:${OLLAMA_PORT:-11434}/api/health"
    return 0
}

# Stop all services.
stop_services() {
    log "Stopping all services..."
    cd "$SCRIPT_DIR"
    docker compose down
    log "Services stopped"
    return 0
}

# Restart all services.
restart_services() {
    log "Restarting all services..."
    cd "$SCRIPT_DIR"
    docker compose restart
    log "Services restarted"
    return 0
}

# Show service status.
show_status() {
    log "Service status:"
    cd "$SCRIPT_DIR"
    docker compose ps -a
    return 0
}

# Show service logs.
show_logs() {
    cd "$SCRIPT_DIR"
    docker compose logs -f "$@"
}

# Cleanup - stop and remove all containers and volumes.
cleanup() {
    log "Cleaning up all services and data..."
    cd "$SCRIPT_DIR"
    docker compose down -v
    log "Cleanup complete"
    return 0
}

# Show GPU information.
show_gpu_info() {
    log "GPU Information:"
    if command_exists nvidia-smi; then
        nvidia-smi -L
        echo ""
        nvidia-smi -q -d MEMORY,CORES,POWER
    else
        error "nvidia-smi not found"
        return 1
    fi
    return 0
}

# Wait for services to be healthy.
wait_for_services() {
    local max_wait=300  # 5 minutes max
    local wait_count=0

    log "Waiting for services to initialize (max ${max_wait}s)..."

    # Wait for LiteLLM
    while [[ $wait_count -lt $max_wait ]]; do
        if curl -sf "http://localhost:${LITELLM_PORT:-4000}/health" &>/dev/null; then
            log "LiteLLM: Healthy"
            break
        fi
        sleep 5
        ((wait_count += 5))
    done

    if [[ $wait_count -ge $max_wait ]]; then
        warning "LiteLLM health check timed out"
    fi

    # Wait for Ollama
    wait_count=0
    while [[ $wait_count -lt $max_wait ]]; do
        if curl -sf "http://localhost:${OLLAMA_PORT:-11434}/api/health" &>/dev/null; then
            log "Ollama: Healthy"
            break
        fi
        sleep 5
        ((wait_count += 5))
    done

    if [[ $wait_count -ge $max_wait ]]; then
        warning "Ollama health check timed out"
    fi

    # Wait for NIM Llama
    wait_count=0
    while [[ $wait_count -lt $max_wait ]]; do
        if curl -sf "http://localhost:${NIM_LLAMA_PORT:-8000}/v1/models" &>/dev/null; then
            log "NIM Llama: Healthy"
            break
        fi
        sleep 5
        ((wait_count += 5))
    done

    if [[ $wait_count -ge $max_wait ]]; then
        warning "NIM Llama health check timed out"
    fi

    # Wait for NIM Qwen
    wait_count=0
    while [[ $wait_count -lt $max_wait ]]; do
        if curl -sf "http://localhost:${NIM_QWEN_PORT:-8001}/v1/models" &>/dev/null; then
            log "NIM Qwen: Healthy"
            break
        fi
        sleep 5
        ((wait_count += 5))
    done

    if [[ $wait_count -ge $max_wait ]]; then
        warning "NIM Qwen health check timed out"
    fi

    # Final status check
    log ""
    log "Service status:"
    docker compose ps
}

# =============================================================================
# HELP AND USAGE
# =============================================================================

# Print usage information.
print_usage() {
    echo "Usage: spark_init.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start        Start all services (Ollama + NIM models + LiteLLM)"
    echo "  stop         Stop all services"
    echo "  restart      Restart all services"
    echo "  status       Show service status"
    echo "  logs         Show service logs (follow mode)"
    echo "  cleanup      Stop and remove all containers and volumes"
    echo "  gpu-info     Show GPU information"
    echo "  help         Show this help message"
    echo ""
    echo "Options:"
    echo "  -h, --help   Show this help message"
    echo ""
    echo "Examples:"
    echo "  spark_init.sh start          Start all services"
    echo "  spark_init.sh status         Show status"
    echo "  spark_init.sh logs           View logs"
    echo "  spark_init.sh stop           Stop all services"
    echo "  spark_init.sh cleanup        Full cleanup (containers + volumes)"
    echo ""
    echo "Environment Variables (in .env):"
    echo "  NGC_API_KEY          NVIDIA NGC API key"
    echo "  LOCAL_NIM_CACHE      Cache directory (default: \$HOME/.cache/nim)"
    echo "  GPU_RESOURCE         GPU allocation (default: all)"
    echo "  OLLAMA_PORT          Ollama port (default: 11434)"
    echo "  NIM_LLAMA_PORT       Llama NIM port (default: 8000)"
    echo "  NIM_QWEN_PORT        Qwen NIM port (default: 8001)"
    echo "  LITELLM_PORT         LiteLLM port (default: 4000)"
    echo "  NIM_SHM_SIZE         Shared memory size (default: 16GB)"
}

# =============================================================================
# MAIN ENTRY POINT
# =============================================================================

# Main function.
main() {
    local command="${1:-help}"

    case "$command" in
        start)
            validate_env || exit 1
            check_prerequisites || exit 1
            start_services
            ;;
        stop)
            cd "$SCRIPT_DIR"
            stop_services
            ;;
        restart)
            cd "$SCRIPT_DIR"
            restart_services
            ;;
        status)
            cd "$SCRIPT_DIR"
            show_status
            ;;
        logs)
            cd "$SCRIPT_DIR"
            show_logs "$@"
            ;;
        cleanup)
            cd "$SCRIPT_DIR"
            cleanup
            ;;
        gpu-info)
            show_gpu_info
            ;;
        help|--help|-h)
            print_usage
            ;;
        *)
            error "Unknown command: $command"
            print_usage
            exit 1
            ;;
    esac
}

# Run main function if script is executed directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi