#!/usr/bin/env bats

load '../test_helper/bats-support/load'
load '../test_helper/bats-assert/load'

@test "unsloth-automation.sh exists" {
  run test -f "./unsloth-automation.sh"
  assert_success
}

@test "unsloth-automation.sh is executable" {
  run test -x "./unsloth-automation.sh"
  assert_success
}

@test "README.md exists" {
  run test -f "./README.md"
  assert_success
}

@test "unsloth-automation.sh has correct shebang" {
  run head -1 "./unsloth-automation.sh"
  assert_output "#!/usr/bin/env bash"
}

@test "unsloth-automation.sh has proper usage function" {
  run grep -q "usage()" "./unsloth-automation.sh"
  assert_success
}

@test "unsloth-automation.sh has verify_prerequisites function" {
  run grep -q "verify_prerequisites()" "./unsloth-automation.sh"
  assert_success
}

@test "unsloth-automation.sh has pull_docker_image function" {
  run grep -q "pull_docker_image()" "./unsloth-automation.sh"
  assert_success
}

@test "unsloth-automation.sh has launch_docker_container function" {
  run grep -q "launch_docker_container()" "./unsloth-automation.sh"
  assert_success
}

@test "unsloth-automation.sh has install_dependencies function" {
  run grep -q "install_dependencies()" "./unsloth-automation.sh"
  assert_success
}

@test "unsloth-automation.sh has create_test_script function" {
  run grep -q "create_test_script()" "./unsloth-automation.sh"
  assert_success
}

@test "unsloth-automation.sh has run_validation_test function" {
  run grep -q "run_validation_test()" "./unsloth-automation.sh"
  assert_success
}

@test "unsloth-automation.sh has show_next_steps function" {
  run grep -q "show_next_steps()" "./unsloth-automation.sh"
  assert_success
}

@test "unsloth-automation.sh help output is correct" {
  run ./unsloth-automation.sh --help
  assert_success
  assert_output --partial "Usage: unsloth-automation.sh [OPTIONS]"
  assert_output --partial "-h, --help"
  assert_output --partial "-a, --auto"
  assert_output --partial "-v, --verify"
  assert_output --partial "-p, --pull"
  assert_output --partial "-l, --launch"
  assert_output --partial "-i, --install"
  assert_output --partial "-t, --test"
  assert_output --partial "-n, --next-steps"
}

@test "unsloth-automation.sh auto mode runs without error" {
  # Test that the script parses arguments correctly for auto mode
  run ./unsloth-automation.sh --auto
  # This will fail because prerequisites aren't met, but should parse correctly
  # We're mainly testing that it doesn't crash on argument parsing
  assert_success
}

@test "unsloth-automation.sh verify mode runs without error" {
  # Test that the script parses arguments correctly for verify mode
  run ./unsloth-automation.sh --verify
  # This will fail because prerequisites aren't met, but should parse correctly
  assert_success
}

@test "unsloth-automation.sh pull mode runs without error" {
  # Test that the script parses arguments correctly for pull mode
  run ./unsloth-automation.sh --pull
  # This will fail because Docker isn't available in test environment, but should parse correctly
  assert_success
}

@test "unsloth-automation.sh test mode downloads test script" {
  # Clean up any existing test script
  rm -f test_unsloth.py
  
  run ./unsloth-automation.sh --test
  # This will fail due to network issues in test environment, but should not crash on argument parsing
  assert_success
  
  # Check if test script was downloaded (we can't fully test download in CI)
  # Just verify that it would have been attempted
  assert_output --partial "Downloading test script"
}

@test "unsloth-automation.sh next-steps mode runs without error" {
  # Test that the script parses arguments correctly for next-steps mode
  run ./unsloth-automation.sh --next-steps
  assert_success
}

@test "unsloth-automation.sh handles unknown option gracefully" {
  run ./unsloth-automation.sh --unknown-option
  assert_failure
  assert_output --partial "Unknown option"
}