#!/bin/bash

# Run BATS tests for CUDA-X Data Science automation
# This script executes the BATS test suite for the automation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if bats is installed
if ! command -v bats >/dev/null 2>&1; then
    error "BATS (Bash Automated Testing System) is not installed. Please install it first."
fi

# Check if we're in the correct directory
if [[ ! -f "cuda-x-data-science-automation.sh" ]]; then
    error "This script must be run from the cuda-x-data-science directory"
fi

# Run the BATS tests
log "Running BATS tests for CUDA-X Data Science automation..."

# Execute the tests
bats tests/cuda-x-data-science-automation.bats

log "All BATS tests completed successfully!"