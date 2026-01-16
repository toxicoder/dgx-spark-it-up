#!/usr/bin/env bats

# Test that the BATS helper files are properly set up

@test "test helper bats-support directory exists" {
    [ -d ./dgx-spark-ssh-tools/test_helper/bats-support ]
}

@test "test helper bats-assert directory exists" {
    [ -d ./dgx-spark-ssh-tools/test_helper/bats-assert ]
}

@test "test helper bats-support load file exists" {
    [ -f ./dgx-spark-ssh-tools/test_helper/bats-support/load.bash ]
}

@test "test helper bats-assert load file exists" {
    [ -f ./dgx-spark-ssh-tools/test_helper/bats-assert/load.bash ]
}

@test "test helper files are not empty" {
    [ -s ./dgx-spark-ssh-tools/test_helper/bats-support/load.bash ]
    [ -s ./dgx-spark-ssh-tools/test_helper/bats-assert/load.bash ]
}