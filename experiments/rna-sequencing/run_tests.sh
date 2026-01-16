#!/bin/bash

# Run BATS tests for RNA Sequencing Automation
# This script is used to run the BATS tests for the RNA sequencing automation script

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

# Check if bats is available
if ! command -v bats >/dev/null 2>&1; then
    log "BATS not found in system PATH. Trying bats-core..."
    # Try to use bats from bats-core
    if [ -x "bats-core/bin/bats" ]; then
        BATS_CMD="./bats-core/bin/bats"
    else
        error "BATS not found. Please install BATS or ensure bats-core is properly set up."
    fi
else
    BATS_CMD="bats"
fi

# Run the tests
log "Running BATS tests for RNA Sequencing Automation..."
log "Using test runner: $BATS_CMD"

# Change to the script directory to ensure proper relative paths
cd "$(dirname "$0")"

# Run the tests
if [ -d "tests" ] && [ -f "tests/rna-sequencing-automation.bats" ]; then
    $BATS_CMD tests/
    log "All tests completed successfully!"
else
    error "Test directory or test file not found"
fi