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
  run format_value '{"status":"success","check_run_id":123,"note":"100% 👨‍👩‍👧‍👦 🏴󠁧󠁢󠁳󠁣󠁴󠁿 #!@"}'
  assert_success
  assert_line "status       : success"
  assert_line "check_run_id : 123"
  assert_line "note         : 100% 👨‍👩‍👧‍👦 🏴󠁧󠁢󠁳󠁣󠁴󠁿 #!@"
}

@test "empty json object renders as {}" {
  run format_value '{}'
  assert_success
  assert_output "{}"
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

  # echo would eat these as flags
  run format_value "-n"
  assert_output -- "-n"
  run format_value "-e"
  assert_output -- "-e"
}

@test "jq unavailable falls back to raw output" {
  # jq lives in /usr/bin on macOS + ubuntu, so an empty PATH is the only reliable hide.
  # restore it before asserting - bats' own cleanup needs rm
  local orig_path="$PATH"

  PATH="$BATS_TEST_TMPDIR"
  run format_value '{"key":"value"}'
  PATH="$orig_path"
  assert_success
  assert_output '{"key":"value"}'

  PATH="$BATS_TEST_TMPDIR"
  run format_value "-n"
  PATH="$orig_path"
  assert_output -- "-n"
}
