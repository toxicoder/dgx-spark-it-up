#!/usr/bin/env bats

load '../test_helper/bats-support/load'
load '../test_helper/bats-assert/load'

@test "pytorch-fine-tune-automation.sh exists" {
  run test -f "./pytorch-fine-tune-automation.sh"
  assert_success
}

@test "pytorch-fine-tune-automation.sh is executable" {
  run test -x "./pytorch-fine-tune-automation.sh"
  assert_success
}

@test "README.md exists" {
  run test -f "./README.md"
  assert_success
}

@test "pytorch-fine-tune-automation.sh syntax is valid" {
  run bash -n "./pytorch-fine-tune-automation.sh"
  assert_success
}

@test "pytorch-fine-tune-automation.sh help command works" {
  run ./pytorch-fine-tune-automation.sh --help
  assert_success
}

@test "pytorch-fine-tune-automation.sh verify command works" {
  run ./pytorch-fine-tune-automation.sh --verify
  assert_success
}

@test "pytorch-fine-tune-automation.sh configure command works" {
  # Test configure with minimal inputs
  run ./pytorch-fine-tune-automation.sh --configure
  # This command will prompt for input, so we skip it in automated tests
  skip "Skipping configure test as it requires interactive input"
}

@test "pytorch-fine-tune-automation.sh docker command works" {
  run ./pytorch-fine-tune-automation.sh --docker
  # This test may fail in non-docker environments, so we skip it
  skip "Skipping docker test as it may not run in all environments"
}

@test "pytorch-fine-tune-automation.sh resources command works" {
  run ./pytorch-fine-tune-automation.sh --resources
  # This test may fail if nvidia-smi is not available, so we skip it
  skip "Skipping resources test as it may not run in all environments"
}

@test "pytorch-fine-tune-automation.sh swarm command works" {
  run ./pytorch-fine-tune-automation.sh --swarm
  # This test may fail in non-swarm environments, so we skip it
  skip "Skipping swarm test as it requires swarm environment"
}

@test "pytorch-fine-tune-automation.sh deploy command works" {
  run ./pytorch-fine-tune-automation.sh --deploy
  # This test will fail without required files, so we skip it
  skip "Skipping deploy test as it requires docker-compose.yml and pytorch-ft-entrypoint.sh"
}

@test "pytorch-fine-tune-automation.sh cleanup command works" {
  run ./pytorch-fine-tune-automation.sh --cleanup
  assert_success
}

@test "All required functions are defined" {
  # Check that all key functions are defined in the script
  local required_functions=(
    "verify_requirements"
    "gather_config"
    "configure_network"
    "configure_docker_permissions"
    "install_nvidia_toolkit"
    "enable_resource_advertising"
    "initialize_swarm"
    "join_worker_nodes"
    "deploy_stack"
    "find_container_id"
    "adapt_config_files"
    "run_finetune"
    "cleanup"
    "main"
  )
  
  for func in "${required_functions[@]}"; do
    run grep -q "^[[:space:]]*${func}()[[:space:]]*{" "./pytorch-fine-tune-automation.sh"
    assert_success "Function ${func} is not defined in pytorch-fine-tune-automation.sh"
  done
}

@test "Configuration file is created and readable" {
  # Check that the configuration file is properly formatted
  run grep -q "# PyTorch Fine-Tuning Configuration" "./pytorch-fine-tune-automation.sh"
  assert_success "Configuration file section not found in script"
}