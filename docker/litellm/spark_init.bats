#!/usr/bin/env bats

# =============================================================================
# spark_init.bats - BATS tests for spark_init.sh
# =============================================================================
#
# Test Categories:
#   1. Prerequisites validation
#   2. Environment variable validation
#   3. Utility functions
#   4. Command line interface
#   5. Service management
#   6. Integration tests
# =============================================================================

# Set test directory
TEST_DIR="${BATS_TEST_DIRNAME:-.}"

# =============================================================================
# SETUP AND TEARDOWN (BATS built-in functions)
# =============================================================================

setup_file() {
    # Set test directory as script directory
    export SCRIPT_DIR="$TEST_DIR"
    
    # Create a temporary directory for testing
    export TEST_TEMP_DIR="$(mktemp -d)"
}

teardown_file() {
    # Remove temporary directory
    rm -rf "$TEST_TEMP_DIR"
    
    # Remove test .env file if it exists
    rm -f "$TEST_DIR/.env"
}

# =============================================================================
# SCRIPT STRUCTURE TESTS
# =============================================================================

@test "script_structure: Has shebang" {
    run head -1 "$TEST_DIR/spark_init.sh"
    [ "$status" -eq 0 ]
    [[ "$output" == "#!/usr/bin/env bash" ]]
}

@test "script_structure: Has header documentation" {
    run head -20 "$TEST_DIR/spark_init.sh"
    [ "$status" -eq 0 ]
    [[ "$output" == *"spark_init.sh - Initialize NVIDIA NIM"* ]]
}

@test "script_structure: Uses strict mode" {
    run grep "set -euo pipefail" "$TEST_DIR/spark_init.sh"
    [ "$status" -eq 0 ]
}

@test "script_structure: Has main function" {
    run grep "^[a-zA-Z_][a-zA-Z0-9_]*() {" "$TEST_DIR/spark_init.sh"
    [[ -n "$output" ]]
    [[ "$output" == *"main()"* ]]
}

# =============================================================================
# COMMAND LINE INTERFACE TESTS
# =============================================================================

@test "cli: help command shows usage" {
    # Capture output of help command using run function
    run bash "$TEST_DIR/spark_init.sh" help 2>&1
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"Commands:"* ]]
}

@test "cli: invalid command shows error" {
    run bash "$TEST_DIR/spark_init.sh" invalid-command 2>&1
    
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown command"* ]]
}

# =============================================================================
# CONFIGURATION TESTS
# =============================================================================

@test "config: OLLAMA_PORT defaults to 11434" {
    run grep "DEFAULT_OLLAMA_PORT=11434" "$TEST_DIR/spark_init.sh"
    [ "$status" -eq 0 ]
}

@test "config: NIM_LLAMA_PORT defaults to 8000" {
    run grep "DEFAULT_NIM_LLAMA_PORT=8000" "$TEST_DIR/spark_init.sh"
    [ "$status" -eq 0 ]
}

@test "config: NIM_QWEN_PORT defaults to 8001" {
    run grep "DEFAULT_NIM_QWEN_PORT=8001" "$TEST_DIR/spark_init.sh"
    [ "$status" -eq 0 ]
}

# =============================================================================
# DOCKER COMPOSE INTEGRATION TESTS
# =============================================================================

@test "docker_compose: Uses docker compose pull" {
    run grep "docker compose pull" "$TEST_DIR/spark_init.sh"
    [ "$status" -eq 0 ]
}

@test "docker_compose: Uses docker compose up" {
    run grep "docker compose up" "$TEST_DIR/spark_init.sh"
    [ "$status" -eq 0 ]
}

@test "docker_compose: Uses docker compose down" {
    run grep "docker compose down" "$TEST_DIR/spark_init.sh"
    [ "$status" -eq 0 ]
}

# =============================================================================
# NVIDIA CONTAINER REGISTRY AUTHENTICATION TESTS
# =============================================================================

@test "ngc_auth: Uses docker login" {
    run grep "docker login nvcr.io" "$TEST_DIR/spark_init.sh"
    [ "$status" -eq 0 ]
}

@test "ngc_auth: Uses oauthtoken username" {
    run grep '\$oauthtoken' "$TEST_DIR/spark_init.sh"
    [ "$status" -eq 0 ]
}

# =============================================================================
# HEALTH CHECK TESTS
# =============================================================================

@test "health_check: LiteLLM health endpoint" {
    run grep "localhost.*LITELLM_PORT.*health" "$TEST_DIR/spark_init.sh" || true
    [[ -n "$output" ]]
}

@test "health_check: Ollama health endpoint" {
    run grep "localhost.*11434.*api/health" "$TEST_DIR/spark_init.sh" || true
    [[ -n "$output" ]]
}

@test "health_check: NIM models endpoint" {
    run grep "localhost.*800.*v1/models" "$TEST_DIR/spark_init.sh" || true
    [[ -n "$output" ]]
}

# =============================================================================
# UTILITIES TESTS
# =============================================================================

@test "utilities: command_exists function" {
    run grep "command_exists() {" "$TEST_DIR/spark_init.sh" || true
    [[ -n "$output" ]]
}

@test "utilities: log function" {
    run grep "log() {" "$TEST_DIR/spark_init.sh" || true
    [[ -n "$output" ]]
}

@test "utilities: error function" {
    run grep "error() {" "$TEST_DIR/spark_init.sh" || true
    [[ -n "$output" ]]
}

@test "utilities: warning function" {
    run grep "warning() {" "$TEST_DIR/spark_init.sh" || true
    [[ -n "$output" ]]
}

# =============================================================================
# SERVICE MANAGEMENT TESTS
# =============================================================================

@test "services: start_services function" {
    run grep "start_services() {" "$TEST_DIR/spark_init.sh" || true
    [[ -n "$output" ]]
}

@test "services: stop_services function" {
    run grep "stop_services() {" "$TEST_DIR/spark_init.sh" || true
    [[ -n "$output" ]]
}

@test "services: show_status function" {
    run grep "show_status() {" "$TEST_DIR/spark_init.sh" || true
    [[ -n "$output" ]]
}

# =============================================================================
# ENVIRONMENT VALIDATION TESTS
# =============================================================================

@test "env: validate_env function" {
    run grep "validate_env() {" "$TEST_DIR/spark_init.sh" || true
    [[ -n "$output" ]]
}

@test "env: NGC_API_KEY check" {
    run grep "NGC_API_KEY" "$TEST_DIR/spark_init.sh"
    [[ -n "$output" ]]
}

# =============================================================================
# NVIDIA GPU TESTS
# =============================================================================

@test "gpu: GPU resource configuration" {
    run grep "GPU_RESOURCE" "$TEST_DIR/spark_init.sh"
    [ "$status" -eq 0 ]
}

@test "gpu: nvidia-smi check" {
    run grep "nvidia-smi" "$TEST_DIR/spark_init.sh"
    [ "$status" -eq 0 ]
}

# =============================================================================
# END OF TESTS
# =============================================================================