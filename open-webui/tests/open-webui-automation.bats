#!/usr/bin/env bats

# Test that the automation script exists and is executable
@test "open-webui automation script exists and is executable" {
    run test -x open-webui/open-webui-automation.sh
    assert_success
}

# Test that the script has proper shebang
@test "open-webui automation script has proper shebang" {
    run head -n 1 open-webui/open-webui-automation.sh
    assert_output "#!/bin/bash"
}

# Test that the script contains required functions
@test "open-webui automation script contains check_docker function" {
    run grep -q "check_docker" open-webui/open-webui-automation.sh
    assert_success
}

@test "open-webui automation script contains pull_container function" {
    run grep -q "pull_container" open-webui/open-webui-automation.sh
    assert_success
}

@test "open-webui automation script contains start_container function" {
    run grep -q "start_container" open-webui/open-webui-automation.sh
    assert_success
}

@test "open-webui automation script contains download_model function" {
    run grep -q "download_model" open-webui/open-webui-automation.sh
    assert_success
}

@test "open-webui automation script contains verify_setup function" {
    run grep -q "verify_setup" open-webui/open-webui-automation.sh
    assert_success
}

@test "open-webui automation script contains cleanup function" {
    run grep -q "cleanup" open-webui/open-webui-automation.sh
    assert_success
}

# Test that the script contains required Docker commands
@test "open-webui automation script contains docker pull command" {
    run grep -q "docker pull ghcr.io/open-webui/open-webui:ollama" open-webui/open-webui-automation.sh
    assert_success
}

@test "open-webui automation script contains docker run command" {
    run grep -q "docker run -d -p 8080:8080 --gpus=all" open-webui/open-webui-automation.sh
    assert_success
}

@test "open-webui automation script contains docker exec command for model" {
    run grep -q "docker exec open-webui ollama pull gpt-oss:20b" open-webui/open-webui-automation.sh
    assert_success
}

# Test that the script has proper command line argument handling
@test "open-webui automation script handles --cleanup argument" {
    run grep -q "--cleanup" open-webui/open-webui-automation.sh
    assert_success
}

@test "open-webui automation script handles --verify argument" {
    run grep -q "--verify" open-webui/open-webui-automation.sh
    assert_success
}

@test "open-webui automation script handles --install argument" {
    run grep -q "--install" open-webui/open-webui-automation.sh
    assert_success
}

# Test that the script has proper error handling
@test "open-webui automation script contains error handling" {
    run grep -q "error()" open-webui/open-webui-automation.sh
    assert_success
}

@test "open-webui automation script contains set -e" {
    run grep -q "set -e" open-webui/open-webui-automation.sh
    assert_success
}

# Test that the script has proper volume definitions
@test "open-webui automation script contains volume definitions" {
    run grep -q "open-webui:/app/backend/data" open-webui/open-webui-automation.sh
    assert_success
}

@test "open-webui automation script contains ollama volume definition" {
    run grep -q "open-webui-ollama:/root/.ollama" open-webui/open-webui-automation.sh
    assert_success
}

# Test that the script contains the correct container name
@test "open-webui automation script uses correct container name" {
    run grep -q "--name open-webui" open-webui/open-webui-automation.sh
    assert_success
}

# Test that the script mentions the correct model
@test "open-webui automation script mentions gpt-oss:20b model" {
    run grep -q "gpt-oss:20b" open-webui/open-webui-automation.sh
    assert_success
}

# Test that the script mentions localhost:8080
@test "open-webui automation script mentions localhost:8080" {
    run grep -q "localhost:8080" open-webui/open-webui-automation.sh
    assert_success
}

# Test that the script mentions Docker permissions check
@test "open-webui automation script mentions Docker permissions check" {
    run grep -q "usermod -aG docker" open-webui/open-webui-automation.sh
    assert_success
}

# Test that the script mentions the correct cleanup commands
@test "open-webui automation script contains cleanup commands" {
    run grep -q "docker stop open-webui" open-webui/open-webui-automation.sh
    assert_success
}

@test "open-webui automation script contains image removal command" {
    run grep -q "docker rmi ghcr.io/open-webui/open-webui:ollama" open-webui/open-webui-automation.sh
    assert_success
}

@test "open-webui automation script contains volume removal commands" {
    run grep -q "docker volume rm open-webui" open-webui/open-webui-automation.sh
    assert_success
}

# Test that the script includes all required steps from the guide
@test "open-webui automation script includes all guide steps" {
    # Check for key elements from the guide
    run grep -q "check_docker" open-webui/open-webui-automation.sh
    assert_success
    
    run grep -q "docker pull" open-webui/open-webui-automation.sh
    assert_success
    
    run grep -q "docker run" open-webui/open-webui-automation.sh
    assert_success
    
    run grep -q "ollama pull gpt-oss:20b" open-webui/open-webui-automation.sh
    assert_success
    
    run grep -q "localhost:8080" open-webui/open-webui-automation.sh
    assert_success
    
    run grep -q "cleanup" open-webui/open-webui-automation.sh
    assert_success
}

# Test script structure and formatting
@test "open-webui automation script has proper structure" {
    # Check that functions are properly defined
    run grep -c "function.*()" open-webui/open-webui-automation.sh
    assert [ "$status" -ge 5 ]  # Should have at least 5 functions
    
    # Check that main function exists
    run grep -q "main()" open-webui/open-webui-automation.sh
    assert_success
}