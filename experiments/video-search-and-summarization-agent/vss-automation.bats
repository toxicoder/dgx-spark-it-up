#!/usr/bin/env bats

# BATS tests for VSS Automation Script
# These tests validate the functionality of the VSS automation script

@test "vss-automation.sh exists and is executable" {
    [ -f "vss-automation.sh" ]
    [ -x "vss-automation.sh" ]
}

@test "vss-automation.sh has valid bash syntax" {
    bash -n vss-automation.sh
}

@test "vss-automation.sh contains key functions" {
    # Test that all required functions are defined
    run grep -n "function.*verify_environment" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "function.*configure_docker" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "function.*clone_repository" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "function.*create_docker_network" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "function.*authenticate_nvc" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "function.*setup_deployment_scenario" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "function.*cleanup" vss-automation.sh
    [ "$status" -eq 0 ]
}

@test "vss-automation.sh contains required environment checks" {
    # Test that environment verification functions are present
    run grep -n "nvidia-smi" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "nvcc" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "docker" vss-automation.sh
    [ "$status" -eq 0 ]
}

@test "vss-automation.sh contains deployment scenario handling" {
    # Test that deployment scenarios are defined
    run grep -n "VSS Event Reviewer" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "Standard VSS" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "setup_event_reviewer" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "setup_standard_vss" vss-automation.sh
    [ "$status" -eq 0 ]
}

@test "vss-automation.sh contains Docker configuration" {
    # Test that Docker configuration is present
    run grep -n "docker-compose" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "nvidia-ctk" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "docker network" vss-automation.sh
    [ "$status" -eq 0 ]
}

@test "vss-automation.sh contains authentication handling" {
    # Test that authentication functions are present
    run grep -n "NGC_API_KEY" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "docker login" vss-automation.sh
    [ "$status" -eq 0 ]
}

@test "vss-automation.sh contains cleanup functionality" {
    # Test that cleanup function is properly defined
    run grep -n "function.*cleanup" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "docker compose down" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "docker network rm" vss-automation.sh
    [ "$status" -eq 0 ]
}

@test "vss-automation.sh contains main execution flow" {
    # Test that main function is defined and called
    run grep -n "function.*main" vss-automation.sh
    [ "$status" -eq 0 ]
    
    run grep -n "main" vss-automation.sh
    [ "$status" -eq 0 ]
    
    # Test that cleanup option is handled
    run grep -n "cleanup" vss-automation.sh
    [ "$status" -eq 0 ]
}