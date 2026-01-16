#!/usr/bin/env bash

# Test helper functions for stacked-dgx-sparks automation script

# Function to create a temporary config file for testing
create_test_config() {
    local config_file="$HOME/.dgx-spark-stacked-test-config"
    cat > "$config_file" << EOF
# DGX Spark Stacked Test Configuration
DGX_USERNAME="testuser"
DGX_HOSTNAME="testhost"
SECONDARY_NODE="192.168.1.100"
EOF
    echo "$config_file"
}

# Function to cleanup test config
cleanup_test_config() {
    local config_file="$HOME/.dgx-spark-stacked-test-config"
    if [[ -f "$config_file" ]]; then
        rm -f "$config_file"
    fi
}

# Function to setup a mock SSH environment for testing
setup_mock_ssh() {
    # Create a mock ssh command that just echoes the command
    mkdir -p /tmp/mock-bin
    cat > /tmp/mock-bin/ssh << 'EOF'
#!/bin/bash
echo "Mock SSH command: $@"
exit 0
EOF
    chmod +x /tmp/mock-bin/ssh
    export PATH="/tmp/mock-bin:$PATH"
}

# Function to cleanup mock SSH environment
cleanup_mock_ssh() {
    if [[ -d "/tmp/mock-bin" ]]; then
        rm -rf /tmp/mock-bin
    fi
    # Reset PATH to original
    export PATH="$(echo $PATH | sed 's|/tmp/mock-bin:||')"
}