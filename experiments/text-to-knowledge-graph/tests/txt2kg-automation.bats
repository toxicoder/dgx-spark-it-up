#!/usr/bin/env bats

# BATS tests for txt2kg-automation.sh

@test "txt2kg-automation.sh exists" {
    run test -f "experiments/text-to-knowledge-graph/txt2kg-automation.sh"
    [ "$status" -eq 0 ]
}

@test "txt2kg-automation.sh is executable" {
    run test -x "experiments/text-to-knowledge-graph/txt2kg-automation.sh"
    [ "$status" -eq 0 ]
}

@test "txt2kg-automation.sh has proper shebang" {
    run grep -E "^#!" "experiments/text-to-knowledge-graph/txt2kg-automation.sh"
    [ "$status" -eq 0 ]
    [ "$line" = "#!/bin/bash" ]
}

@test "txt2kg-automation.sh checks for git" {
    # This test verifies that the script checks for git dependency
    run grep -q "command -v git" "experiments/text-to-knowledge-graph/txt2kg-automation.sh"
    [ "$status" -eq 0 ]
}

@test "txt2kg-automation.sh checks for docker" {
    # This test verifies that the script checks for docker dependency
    run grep -q "command -v docker" "experiments/text-to-knowledge-graph/txt2kg-automation.sh"
    [ "$status" -eq 0 ]
}

@test "txt2kg-automation.sh checks for docker compose" {
    # This test verifies that the script checks for docker compose dependency
    run grep -q "command -v docker compose" "experiments/text-to-knowledge-graph/txt2kg-automation.sh"
    [ "$status" -eq 0 ]
}

@test "txt2kg-automation.sh checks for docker-compose" {
    # This test verifies that the script checks for docker-compose dependency
    run grep -q "command -v docker-compose" "experiments/text-to-knowledge-graph/txt2kg-automation.sh"
    [ "$status" -eq 0 ]
}

@test "txt2kg-automation.sh contains repository clone logic" {
    # This test verifies that the script has logic to clone the repository
    run grep -q "git clone" "experiments/text-to-knowledge-graph/txt2kg-automation.sh"
    [ "$status" -eq 0 ]
}

@test "txt2kg-automation.sh contains start.sh execution" {
    # This test verifies that the script executes start.sh
    run grep -q "./start.sh" "experiments/text-to-knowledge-graph/txt2kg-automation.sh"
    [ "$status" -eq 0 ]
}

@test "txt2kg-automation.sh contains model pull logic" {
    # This test verifies that the script has logic to pull the Ollama model
    run grep -q "ollama pull" "experiments/text-to-knowledge-graph/txt2kg-automation.sh"
    [ "$status" -eq 0 ]
}

@test "txt2kg-automation.sh contains web interface check" {
    # This test verifies that the script checks for the web interface
    run grep -q "curl -f http://localhost:3001" "experiments/text-to-knowledge-graph/txt2kg-automation.sh"
    [ "$status" -eq 0 ]
}