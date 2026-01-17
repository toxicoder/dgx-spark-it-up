#!/bin/bash

# Test runner for ComfyUI automation script

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Error function
error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Warning function
warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check if BATS is installed
check_bats() {
    if ! command -v bats &> /dev/null; then
        error "BATS is not installed. Please install BATS to run tests."
        error "You can install BATS by running: sudo apt install bats"
        return 1
    fi
    
    log "BATS is available"
    return 0
}

# Function to run BATS tests
run_bats_tests() {
    log "Running BATS tests for ComfyUI automation script"
    
    # Change to the comfy-ui directory
    cd /workspaces/dgx-spark-it-up/comfy-ui
    
    # Run the BATS tests with verbose output
    if bats -v comfy-ui.bats; then
        log "All BATS tests passed!"
        return 0
    else
        error "Some BATS tests failed!"
        return 1
    fi
}

# Function to run syntax checks
run_syntax_checks() {
    log "Running syntax checks for ComfyUI automation script"
    
    # Test that the automation script can be sourced without errors
    if bash -n comfy-ui-automation.sh; then
        log "Automation script syntax check passed!"
    else
        error "Automation script has syntax errors!"
        return 1
    fi
    
    # Test that the test helper script can be sourced without errors
    if bash -n test_helper.bash; then
        log "Test helper script syntax check passed!"
    else
        error "Test helper script has syntax errors!"
        return 1
    fi
    
    return 0
}

# Function to run integration tests
run_integration_tests() {
    log "Running integration tests for ComfyUI automation script"
    
    # Test that all required commands are available
    log "Checking required commands..."
    
    local required_commands=("python3" "pip3" "git" "curl" "wget")
    local missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [ ${#missing_commands[@]} -eq 0 ]; then
        log "All required commands are available"
    else
        warning "Missing commands: ${missing_commands[*]}"
        return 1
    fi
    
    return 0
}

# Main function
main() {
    log "Starting ComfyUI automation tests"
    
    # Check if BATS is installed
    check_bats || exit 1
    
    # Run syntax checks
    run_syntax_checks || exit 1
    
    # Run BATS tests
    run_bats_tests || exit 1
    
    # Run integration tests
    run_integration_tests || exit 1
    
    log "All tests completed successfully!"
    return 0
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi