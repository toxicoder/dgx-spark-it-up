#!/usr/bin/env bats

# Test the setup-nemotron3-nano-llamacpp.sh script using BATS framework
# This test file verifies the functionality of the Nemotron-3-Nano-30B-A3B GGUF model setup script

# Load the script to be tested
load '../setup-nemotron3-nano-llamacpp.sh'

# Test that the script exists and is executable
@test "script exists and is executable" {
    [ -x ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh ]
}

# Test that the script can be sourced without errors
@test "script can be sourced without errors" {
    run bash -c "source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh"
    [ "$status" -eq 0 ]
}

# Test print_header function
@test "print_header function outputs correct header" {
    run bash -c "source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh && print_header"
    # Check that output contains the expected header text
    echo "$output" | grep -q "Nemotron-3-Nano-30B-A3B Setup Script"
}

# Test print_status function
@test "print_status function outputs correct status" {
    run bash -c "source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh && print_status 'Test status message'"
    # Should output with ✅ emoji
    echo "$output" | grep -q "✅ Test status message"
}

# Test print_error function
@test "print_error function outputs correct error" {
    run bash -c "source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh && print_error 'Test error message'"
    # Should output with ❌ emoji to stderr
    echo "$output" >&2
    # Check that error message contains expected text
    echo "$output" | grep -q "❌ Test error message"
}

# Test check_prerequisites function with all prerequisites available
@test "check_prerequisites function passes when all prerequisites are available" {
    # Mock commands to simulate successful checks
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        command() {
            case \"\$1\" in
                git|cmake|nvcc)
                    return 0
                    ;;
                *)
                    return 1
                    ;;
            esac
        } &&
        check_prerequisites
    "
    # Should not fail (exit code 0)
    [ "$status" -eq 0 ]
}

# Test check_prerequisites function when git is missing
@test "check_prerequisites function fails when git is missing" {
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        command() {
            case \"\$1\" in
                git)
                    return 1
                    ;;
                cmake|nvcc)
                    return 0
                    ;;
                *)
                    return 1
                    ;;
            esac
        } &&
        check_prerequisites
    "
    # Should fail (exit code 1)
    [ "$status" -eq 1 ]
}

# Test check_prerequisites function when cmake is missing
@test "check_prerequisites function fails when cmake is missing" {
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        command() {
            case \"\$1\" in
                cmake)
                    return 1
                    ;;
                git|nvcc)
                    return 0
                    ;;
                *)
                    return 1
                    ;;
            esac
        } &&
        check_prerequisites
    "
    # Should fail (exit code 1)
    [ "$status" -eq 1 ]
}

# Test check_prerequisites function when nvcc is missing
@test "check_prerequisites function fails when nvcc is missing" {
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        command() {
            case \"\$1\" in
                nvcc)
                    return 1
                    ;;
                git|cmake)
                    return 0
                    ;;
                *)
                    return 1
                    ;;
            esac
        } &&
        check_prerequisites
    "
    # Should fail (exit code 1)
    [ "$status" -eq 1 ]
}

# Test setup_virtual_environment function with successful setup
@test "setup_virtual_environment function works correctly" {
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        python3() {
            return 0
        } &&
        pip() {
            return 0
        } &&
        hf() {
            return 0
        } &&
        setup_virtual_environment
    "
    # Should not fail (exit code 0)
    [ "$status" -eq 0 ]
}

# Test clone_llama_cpp function with successful cloning
@test "clone_llama_cpp function works correctly" {
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        git() {
            return 0
        } &&
        cd() {
            return 0
        } &&
        clone_llama_cpp
    "
    # Should not fail (exit code 0)
    [ "$status" -eq 0 ]
}

# Test build_llama_cpp function with successful build
@test "build_llama_cpp function works correctly" {
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        mkdir() {
            return 0
        } &&
        cd() {
            return 0
        } &&
        cmake() {
            return 0
        } &&
        make() {
            return 0
        } &&
        build_llama_cpp
    "
    # Should not fail (exit code 0)
    [ "$status" -eq 0 ]
}

# Test download_model function with successful download
@test "download_model function works correctly" {
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        mkdir() {
            return 0
        } &&
        hf() {
            case \"\$1\" in
                download)
                    return 0
                    ;;
                *)
                    return 1
                    ;;
            esac
        } &&
        download_model
    "
    # Should not fail (exit code 0)
    [ "$status" -eq 0 ]
}

# Test start_server function with successful server start
@test "start_server function works correctly" {
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        cd() {
            return 0
        } &&
        pgrep() {
            echo '12345'
            return 0
        } &&
        nohup() {
            return 0
        } &&
        start_server
    "
    # Should not fail (exit code 0)
    [ "$status" -eq 0 ]
}

# Test main function with mocked environment
@test "main function executes without errors" {
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        # Mock all external commands
        command() {
            case \"\$1\" in
                git|cmake|nvcc)
                    return 0
                    ;;
                *)
                    return 1
                    ;;
            esac
        } &&
        python3() {
            return 0
        } &&
        pip() {
            return 0
        } &&
        git() {
            return 0
        } &&
        cd() {
            return 0
        } &&
        mkdir() {
            return 0
        } &&
        cmake() {
            return 0
        } &&
        make() {
            return 0
        } &&
        hf() {
            case \"\$1\" in
                download)
                    return 0
                    ;;
                *)
                    return 1
                    ;;
            esac
        } &&
        pgrep() {
            echo '12345'
            return 0
        } &&
        nohup() {
            return 0
        } &&
        main
    "
    # Should not fail (exit code 0)
    [ "$status" -eq 0 ]
}

# Test that test_mode function works correctly
@test "test_mode function returns correct value" {
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        TEST_MODE=true test_mode
    "
    # Should return 0 (success)
    [ "$status" -eq 0 ]
}

@test "test_mode function returns correct value when not in test mode" {
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        TEST_MODE=false test_mode
    "
    # Should return 1 (failure)
    [ "$status" -eq 1 ]
}

# Test that test_mode function returns correct value when not set
@test "test_mode function returns correct value when not set" {
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        unset TEST_MODE && test_mode
    "
    # Should return 1 (failure)
    [ "$status" -eq 1 ]
}

# Test that global variables are set correctly
@test "global variables are set correctly" {
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        echo \"MODELS_DIR=\$MODELS_DIR\"
    "
    # Check that MODELS_DIR contains expected path
    echo "$output" | grep -q "MODELS_DIR=.*models/nemotron3-gguf"
}

@test "global variables are set correctly for VENV_DIR" {
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        echo \"VENV_DIR=\$VENV_DIR\"
    "
    # Check that VENV_DIR contains expected path
    echo "$output" | grep -q "VENV_DIR=./nemotron-venv"
}

@test "global variables are set correctly for LLAMA_CPP_DIR" {
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        echo \"LLAMA_CPP_DIR=\$LLAMA_CPP_DIR\"
    "
    # Check that LLAMA_CPP_DIR contains expected path
    echo "$output" | grep -q "LLAMA_CPP_DIR=./llama.cpp"
}

@test "global variables are set correctly for SERVER_LOG" {
    run bash -c "
        source ./nemotron3-nano-llamacpp/setup-nemotron3-nano-llamacpp.sh &&
        echo \"SERVER_LOG=\$SERVER_LOG\"
    "
    # Check that SERVER_LOG contains expected value
    echo "$output" | grep -q "SERVER_LOG=server.log"
}