#!/bin/bash

# Helper functions for VS Code BATS tests

# Create a mock environment for testing
setup() {
    # Create a temporary directory for testing
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    
    # Mock the system commands
    export PATH="/usr/local/bin:/usr/bin:/bin"
    
    # Create mock commands that simulate the real system commands
    cat > mock_wget << 'EOF'
#!/bin/bash
# Simulate successful download of VS Code installer
echo "Saving to vscode-arm64.deb"
touch vscode-arm64.deb
echo "100% [===================>] 1234567  1.23MB/s in 0.01s"
EOF
    chmod +x mock_wget
    export PATH="$TEST_DIR:$PATH"
    
    cat > mock_dpkg << 'EOF'
#!/bin/bash
# Simulate successful installation
echo "Selecting previously unselected package code."
echo "(Reading database ... 123456 files and directories currently installed.)"
echo "Preparing to unpack .../vscode-arm64.deb ..."
echo "Unpacking code (1.87.2.0) ..."
echo "Setting up code (1.87.2.0) ..."
EOF
    chmod +x mock_dpkg
    export PATH="$TEST_DIR:$PATH"
    
    cat > mock_apt-get << 'EOF'
#!/bin/bash
# Simulate fixing dependencies
echo "Reading package lists..."
echo "Building dependency tree..."
echo "Reading state information..."
echo "The following additional packages will be installed:"
echo "  libsecret-1-0"
echo "0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded."
echo "Need to get 123kB of archives."
echo "After this operation, 456kB of additional disk space will be used."
echo "Get:1 http://archive.ubuntu.com/ubuntu focal/main amd64 libsecret-1-0 amd64 0.20.4-0ubuntu1 [123kB]"
echo "Fetched 123kB in 0s (0B/s)"
echo "Selecting previously unselected package libsecret-1-0."
echo "Preparing to unpack .../libsecret-1-0_0.20.4-0ubuntu1_amd64.deb ..."
echo "Unpacking libsecret-1-0 (0.20.4-0ubuntu1) ..."
echo "Setting up libsecret-1-0 (0.20.4-0ubuntu1) ..."
EOF
    chmod +x mock_apt-get
    export PATH="$TEST_DIR:$PATH"
    
    cat > mock_code << 'EOF'
#!/bin/bash
# Simulate VS Code version check
echo "1.87.2"
EOF
    chmod +x mock_code
    export PATH="$TEST_DIR:$PATH"
    
    cat > mock_df << 'EOF'
#!/bin/bash
# Simulate df -h output with sufficient disk space
echo "Filesystem      Size  Used Avail Use% Mounted on"
echo "/dev/root        50G   20G   28G  42% /"
EOF
    chmod +x mock_df
    export PATH="$TEST_DIR:$PATH"
    
    cat > mock_ps << 'EOF'
#!/bin/bash
# Simulate ps aux output with desktop environment
echo "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
echo "user      1234  0.1  0.2  12345  6789 ?        Ssl  10:00   0:01 /usr/bin/gnome-shell"
EOF
    chmod +x mock_ps
    export PATH="$TEST_DIR:$PATH"
    
    # Set DISPLAY to simulate GUI support
    export DISPLAY=":0"
    
    # Set a mock architecture to simulate aarch64
    export MOCK_ARCH="aarch64"
    
    # Set up mock uname
    cat > mock_uname << 'EOF'
#!/bin/bash
echo "aarch64"
EOF
    chmod +x mock_uname
    export PATH="$TEST_DIR:$PATH"
}

teardown() {
    # Clean up temporary directory
    cd /
    rm -rf "$TEST_DIR"
}