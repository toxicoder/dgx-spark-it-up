#!/usr/bin/env bats

@test "LLaMA Factory automation script exists and is executable" {
    run test -f "llama-factory-automation.sh"
    [ "$status" -eq 0 ]
    
    run test -x "llama-factory-automation.sh"
    [ "$status" -eq 0 ]
}

@test "LLaMA Factory README exists" {
    run test -f "README.md"
    [ "$status" -eq 0 ]
}

@test "LLaMA Factory automation script has valid bash syntax" {
    run bash -n "llama-factory-automation.sh"
    [ "$status" -eq 0 ]
}

@test "LLaMA Factory test script exists and is executable" {
    run test -f "test_automation.sh"
    [ "$status" -eq 0 ]
    
    run test -x "test_automation.sh"
    [ "$status" -eq 0 ]
}

@test "LLaMA Factory directory structure is correct" {
    run test -d "."
    [ "$status" -eq 0 ]
    
    # Check that we have the expected files
    run test -f "llama-factory-automation.sh"
    [ "$status" -eq 0 ]
    
    run test -f "README.md"
    [ "$status" -eq 0 ]
    
    run test -f "test_automation.sh"
    [ "$status" -eq 0 ]
}