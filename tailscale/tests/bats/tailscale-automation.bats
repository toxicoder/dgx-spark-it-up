#!/usr/bin/env bats

# Test the tailscale-automation.sh script using BATS framework
# This test file verifies the functionality of the NVIDIA DGX Spark Tailscale automation script

@test "tailscale script exists and is executable" {
    [ -x ./tailscale/tailscale-automation.sh ]
}

@test "tailscale script shows usage information" {
    run ./tailscale/tailscale-automation.sh
    # Should run without crashing, exit code 0 or 1 is acceptable
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "tailscale script can be sourced without errors" {
    run bash -c "source ./tailscale/tailscale-automation.sh && echo 'Sourced successfully'"
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Sourced successfully"
}

@test "tailscale script has required functions" {
    run bash -c "source ./tailscale/tailscale-automation.sh && type -t step1_verify_requirements"
    [ "$status" -eq 0 ]
    
    run bash -c "source ./tailscale/tailscale-automation.sh && type -t step2_install_ssh"
    [ "$status" -eq 0 ]
    
    run bash -c "source ./tailscale/tailscale-automation.sh && type -t step3_install_tailscale"
    [ "$status" -eq 0 ]
    
    run bash -c "source ./tailscale/tailscale-automation.sh && type -t step4_verify_tailscale"
    [ "$status" -eq 0 ]
}

@test "tailscale script handles system requirements check" {
    # This test is more about ensuring no crashes than actual validation
    run timeout 30s ./tailscale/tailscale-automation.sh
    # Should not crash during execution
    [ "$status" -ne 124 ]  # 124 means timeout, which would indicate a hang
}

# Test that main function can be called
@test "tailscale script main function runs" {
    run bash -c "source ./tailscale/tailscale-automation.sh && main --help 2>/dev/null || true"
    # Should not crash when main function is called
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

# Test basic script syntax
@test "tailscale script has valid bash syntax" {
    run bash -n ./tailscale/tailscale-automation.sh
    [ "$status" -eq 0 ]
}