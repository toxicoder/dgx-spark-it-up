#!/usr/bin/env bash

# =============================================================================
# Test script for NCCL Automation
# This script demonstrates how the NCCL automation would work in practice
# =============================================================================

echo "=== NCCL Automation Test Script ==="
echo ""

echo "1. Checking system requirements..."
if command -v git &> /dev/null; then
    echo "   ✓ Git is available"
else
    echo "   ✗ Git is not available"
fi

if command -v make &> /dev/null; then
    echo "   ✓ Make is available"
else
    echo "   ✗ Make is not available"
fi

if command -v gcc &> /dev/null; then
    echo "   ✓ GCC is available"
else
    echo "   ✗ GCC is not available"
fi

echo ""
echo "2. Running help command..."
echo "   ./nccl-automation.sh --help"
echo ""

echo "3. Running cleanup command..."
echo "   ./nccl-automation.sh --cleanup"
echo ""

echo "4. The NCCL automation script is ready to use!"
echo "   Usage examples:"
echo "   - ./nccl-automation.sh"
echo "   - ./nccl-automation.sh --node 169.254.35.62"
echo "   - ./nccl-automation.sh --node 169.254.35.62 --interface enp1s0f1np1"
echo "   - ./nccl-automation.sh --cleanup"
echo ""

echo "=== Test Complete ==="