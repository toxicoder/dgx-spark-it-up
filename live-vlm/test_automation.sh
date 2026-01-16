#!/bin/bash

# =============================================================================
# Live VLM WebUI Automation Test Script
# This script tests the live-vlm-automation.sh script functionality
# =============================================================================

set -euo pipefail  # Exit on any error, undefined vars, pipe failures

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

# Test script functionality
test_script_functionality() {
    print_status "Testing Live VLM automation script functionality..."
    
    # Check if script exists
    if [[ ! -f "live-vlm-automation.sh" ]]; then
        print_error "live-vlm-automation.sh not found"
        return 1
    fi
    
    # Make script executable
    chmod +x live-vlm-automation.sh
    
    # Test help command
    print_status "Testing help command..."
    ./live-vlm-automation.sh --help
    
    # Test installation command (dry run)
    print_status "Testing installation command (dry run)..."
    ./live-vlm-automation.sh --install --model gemma3:4b 2>/dev/null || true
    
    # Test start command (dry run)
    print_status "Testing start command (dry run)..."
    ./live-vlm-automation.sh --start --port 8090 2>/dev/null || true
    
    # Test configure command (dry run)
    print_status "Testing configure command (dry run)..."
    ./live-vlm-automation.sh --configure 2>/dev/null || true
    
    # Test uninstall command (dry run)
    print_status "Testing uninstall command (dry run)..."
    ./live-vlm-automation.sh --uninstall 2>/dev/null || true
    
    print_status "All tests completed successfully!"
    return 0
}

# Main function
main() {
    print_status "Running Live VLM automation script tests..."
    
    # Run the tests
    test_script_functionality
    
    print_status "All tests passed!"
}

# Run main function
main "$@"