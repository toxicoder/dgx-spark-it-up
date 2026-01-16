#!/bin/bash

# =============================================================================
# NVIDIA DGX Spark TRT-LLM Automation - Test Runner
# This script runs the BATS test suite for the TRT-LLM automation script
# =============================================================================

# Set script to exit on any error
set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Display usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --verbose  Enable verbose output"
    echo "  -c, --clean    Clean test artifacts before running"
    echo ""
}

# Main function
main() {
    local verbose=false
    local clean=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -c|--clean)
                clean=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    print_status "Running TRT-LLM Automation Script Tests"
    print_status "======================================"
    
    # Change to the script's directory
    cd "$(dirname "$0")"
    
    # Clean test artifacts if requested
    if [[ "$clean" == true ]]; then
        print_status "Cleaning test artifacts..."
        # Remove any existing test result files
        rm -f test-results-*.txt 2>/dev/null || true
    fi
    
    # Run the BATS tests for TRT-LLM automation script
    print_status "Running BATS tests for dgx-spark-trtllm-automation.sh..."
    
    if [[ "$verbose" == true ]]; then
        if [ -f "./bats-core/bin/bats" ]; then
            ./bats-core/bin/bats -t dgx-spark-trtllm-automation.bats
        elif command -v bats &> /dev/null; then
            bats -t dgx-spark-trtllm-automation.bats
        else
            print_error "BATS not found in local installation or PATH"
            exit 1
        fi
    else
        if [ -f "./bats-core/bin/bats" ]; then
            ./bats-core/bin/bats dgx-spark-trtllm-automation.bats
        elif command -v bats &> /dev/null; then
            bats dgx-spark-trtllm-automation.bats
        else
            print_error "BATS not found in local installation or PATH"
            exit 1
        fi
    fi
    
    # Check if tests passed
    if [[ $? -eq 0 ]]; then
        print_status "All tests passed successfully!"
        exit 0
    else
        print_error "Some tests failed!"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"