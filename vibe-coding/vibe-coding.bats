#!/usr/bin/env bats

# BATS tests for vibe-coding automation script

setup() {
    # Save original working directory
    cd /workspaces/dgx-spark-it-up/vibe-coding
}

@test "vibe-coding script exists" {
    [ -f "vibe-coding-automation.sh" ]
}

@test "vibe-coding script is executable" {
    [ -x "vibe-coding-automation.sh" ]
}

@test "vibe-coding script has proper shebang" {
    head -n 1 "vibe-coding-automation.sh" | grep -q "#!/bin/bash"
}

@test "check_architecture function exists" {
    grep -q "check_architecture" "vibe-coding-automation.sh"
}

@test "install_ollama function exists" {
    grep -q "install_ollama" "vibe-coding-automation.sh"
}

@test "pull_model function exists" {
    grep -q "pull_model" "vibe-coding-automation.sh"
}

@test "enable_remote_access function exists" {
    grep -q "enable_remote_access" "vibe-coding-automation.sh"
}

@test "install_vscode function exists" {
    grep -q "install_vscode" "vibe-coding-automation.sh"
}

@test "install_continue_extension function exists" {
    grep -q "install_continue_extension" "vibe-coding-automation.sh"
}

@test "setup_local_inference function exists" {
    grep -q "setup_local_inference" "vibe-coding-automation.sh"
}

@test "configure_remote_connection function exists" {
    grep -q "configure_remote_connection" "vibe-coding-automation.sh"
}

@test "main function exists" {
    grep -q "main" "vibe-coding-automation.sh"
}

@test "script contains Ollama installation command" {
    grep -q "curl -fsSL https://ollama.com/install.sh" "vibe-coding-automation.sh"
}

@test "script contains model pull command" {
    grep -q "ollama pull gpt-oss:120b" "vibe-coding-automation.sh"
}

@test "script contains VSCode download URL" {
    # We'll check for a pattern that indicates VSCode download
    grep -q "code-server" "vibe-coding-automation.sh"
}

@test "script contains remote access configuration" {
    grep -q "OLLAMA_HOST=0.0.0.0:11434" "vibe-coding-automation.sh"
}

@test "script contains remote access origins configuration" {
    grep -q "OLLAMA_ORIGINS=\\*" "vibe-coding-automation.sh"
}

@test "script has proper error handling" {
    grep -q "set -e" "vibe-coding-automation.sh"
}

@test "script has color definitions" {
    grep -q "RED=" "vibe-coding-automation.sh"
    grep -q "GREEN=" "vibe-coding-automation.sh"
    grep -q "YELLOW=" "vibe-coding-automation.sh"
}

# Test that the script can be parsed without syntax errors
@test "script parses without syntax errors" {
    bash -n "vibe-coding-automation.sh"
}

# Test that basic functions can be sourced
@test "script can be sourced without errors" {
    # This tests that the script can be sourced without syntax errors
    run bash -c "source ./vibe-coding-automation.sh && echo 'Sourced successfully'"
    [ "$status" -eq 0 ]
}

# Test that functions are properly defined (basic check)
@test "script has required functions defined" {
    run bash -c "source ./vibe-coding-automation.sh && declare -F | grep -E '(check_architecture|install_ollama|pull_model|enable_remote_access|install_vscode|install_continue_extension|setup_local_inference|configure_remote_connection|main)' | wc -l"
    [ "$status" -eq 0 ]
    [ "$output" -ge 9 ]  # Should find at least 9 functions
}