#!/usr/bin/env bats

load '../test_helper/bats-support/load'
load '../test_helper/bats-assert/load'

@test "nemo-fine-tune-automation.sh exists" {
  run test -f "./nemo-fine-tune-automation.sh"
  assert_success
}

@test "nemo-fine-tune-automation.sh is executable" {
  run test -x "./nemo-fine-tune-automation.sh"
  assert_success
}

@test "README.md exists" {
  run test -f "./README.md"
  assert_success
}

@test "CUDA toolkit is available" {
  skip "Skipping because this test requires system-specific tools"
  # This would be difficult to test in automation without a GPU
  run command -v nvcc
  assert_success
}

@test "Python 3.10+ is available" {
  skip "Skipping because this test requires system-specific tools"
  run command -v python3
  assert_success
  # Check version
  PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
  [ "$PYTHON_VERSION" = "3.10" ] || [ "$(printf '%s\n' "3.10" "$PYTHON_VERSION" | sort -V | head -n1)" = "3.10" ]
}

@test "Docker is available" {
  skip "Skipping because this test requires Docker to be installed"
  run command -v docker
  assert_success
}

@test "Docker daemon is accessible" {
  skip "Skipping because this test requires Docker daemon access"
  run docker ps
  # This would be a good test but requires Docker running
  assert_success
}