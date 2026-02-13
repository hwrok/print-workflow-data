#!/usr/bin/env bats

setup() {
  load 'test_helper/common-setup'
  _common_setup
}

@test "n/a input returns n/a" {
  run format_value "n/a"
  assert_success
  assert_output "n/a"
}

@test "empty input returns n/a" {
  run format_value ""
  assert_success
  assert_output "n/a"
}

@test "flat json object renders as aligned key:value table" {
  run format_value '{"status":"success","check_run_id":123}'
  assert_success
  assert_line --partial "check_run_id : 123"
  assert_line --partial "status       : success"
}

@test "nested json object renders nested values as inline json" {
  run format_value '{"name":"test","config":{"debug":true}}'
  assert_success
  assert_line --partial 'config : {"debug":true}'
  assert_line --partial "name   : test"
}

@test "null json values render as empty string" {
  run format_value '{"key":null}'
  assert_success
  assert_line --partial "key : "
}

@test "json array pretty-prints" {
  run format_value '["a","b","c"]'
  assert_success
  assert_line --partial '"a"'
  assert_line --partial '"b"'
  assert_line --partial '"c"'
}

@test "non-json string passes through raw" {
  run format_value "just a plain string"
  assert_success
  assert_output "just a plain string"
}

@test "jq unavailable falls back to raw output" {
  # hide jq from PATH
  PATH="/usr/bin:/bin"
  run format_value '{"key":"value"}'
  assert_success
  assert_output '{"key":"value"}'
}
