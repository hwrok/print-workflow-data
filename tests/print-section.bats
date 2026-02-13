#!/usr/bin/env bats

setup() {
  load 'test_helper/common-setup'
  _common_setup
}

@test "output contains title text" {
  run print_section "test title" "body text"
  assert_success
  local clean
  clean="$(strip_ansi "$output")"
  [[ "$clean" == *"test title"* ]]
}

@test "output contains box drawing characters" {
  run print_section "header" "content"
  assert_success
  local clean
  clean="$(strip_ansi "$output")"
  [[ "$clean" == *"┌"* ]]
  [[ "$clean" == *"┐"* ]]
  [[ "$clean" == *"│"* ]]
  [[ "$clean" == *"└"* ]]
  [[ "$clean" == *"┘"* ]]
  [[ "$clean" == *"─"* ]]
}

@test "output contains body text" {
  run print_section "header" "some body content"
  assert_success
  assert_output --partial "some body content"
}
