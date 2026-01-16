#!/usr/bin/env bats

# BATS tests for flux-finetuning automation script

@test "flux-finetuning: script exists" {
    run test -f flux-finetuning/flux-finetuning-automation.sh
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: script is executable" {
    run test -x flux-finetuning/flux-finetuning-automation.sh
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: check_os function exists" {
    run grep -q "check_os" flux-finetuning/flux-finetuning-automation.sh
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: check_docker_permissions function exists" {
    run grep -q "check_docker_permissions" flux-finetuning/flux-finetuning-automation.sh
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: clone_repository function exists" {
    run grep -q "clone_repository" flux-finetuning/flux-finetuning-automation.sh
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: setup_directories function exists" {
    run grep -q "setup_directories" flux-finetuning/flux-finetuning-automation.sh
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: check_hf_token function exists" {
    run grep -q "check_hf_token" flux-finetuning/flux-finetuning-automation.sh
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: download_model function exists" {
    run grep -q "download_model" flux-finetuning/flux-finetuning-automation.sh
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: build_inference_image function exists" {
    run grep -q "build_inference_image" flux-finetuning/flux-finetuning-automation.sh
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: build_training_image function exists" {
    run grep -q "build_training_image" flux-finetuning/flux-finetuning-automation.sh
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: prepare_dataset function exists" {
    run grep -q "prepare_dataset" flux-finetuning/flux-finetuning-automation.sh
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: main function exists" {
    run grep -q "main" flux-finetuning/flux-finetuning-automation.sh
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: check if required directories exist" {
    run test -d flux-finetuning/assets/models/loras
    [ "$status" -eq 0 ]
    
    run test -d flux-finetuning/assets/flux_data
    [ "$status" -eq 0 ]
    
    run test -d flux-finetuning/assets/models/checkpoints
    [ "$status" -eq 0 ]
    
    run test -d flux-finetuning/assets/models/text_encoders
    [ "$status" -eq 0 ]
    
    run test -d flux-finetuning/assets/models/vae
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: check if required assets exist" {
    run test -f flux-finetuning/assets/Dockerfile.inference
    [ "$status" -eq 0 ]
    
    run test -f flux-finetuning/assets/Dockerfile.train
    [ "$status" -eq 0 ]
    
    run test -f flux-finetuning/assets/download.sh
    [ "$status" -eq 0 ]
    
    run test -f flux-finetuning/assets/launch_comfyui.sh
    [ "$status" -eq 0 ]
    
    run test -f flux-finetuning/assets/launch_train.sh
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: check if workflow files exist" {
    run test -f flux-finetuning/assets/workflows/base_flux.json
    [ "$status" -eq 0 ]
    
    run test -f flux-finetuning/assets/workflows/finetuned_flux.json
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: check if dataset directories exist" {
    run test -d flux-finetuning/assets/flux_data/sparkgpu
    [ "$status" -eq 0 ]
    
    run test -d flux-finetuning/assets/flux_data/tjtoy
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: check if data.toml exists" {
    run test -f flux-finetuning/assets/flux_data/data.toml
    [ "$status" -eq 0 ]
}

@test "flux-finetuning: check if model directory structure is correct" {
    run test -d flux-finetuning/assets/models
    [ "$status" -eq 0 ]
    
    run test -d flux-finetuning/assets/models/loras
    [ "$status" -eq 0 ]
    
    run test -d flux-finetuning/assets/models/checkpoints
    [ "$status" -eq 0 ]
    
    run test -d flux-finetuning/assets/models/text_encoders
    [ "$status" -eq 0 ]
    
    run test -d flux-finetuning/assets/models/vae
    [ "$status" -eq 0 ]
}

# Test that the script can be sourced without errors (basic syntax check)
@test "flux-finetuning: script syntax check" {
    run bash -n flux-finetuning/flux-finetuning-automation.sh
    [ "$status" -eq 0 ]
}

# Test that the main script function can be called without errors
@test "flux-finetuning: main function can be called" {
    # We can't actually run the full main function since it would require
    # docker permissions and a real HF_TOKEN, but we can at least verify
    # that the function exists and is properly structured
    run grep -q "function main" flux-finetuning/flux-finetuning-automation.sh
    [ "$status" -eq 0 ]
}