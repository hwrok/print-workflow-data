#!/usr/bin/env bats

setup() {
  load 'test_helper/common-setup'
  _common_setup
}

set_all_env_vars() {
  export GITHUB_ACTOR="testuser"
  export TRIGGERING_ACTOR="testuser"
  export GITHUB_WORKFLOW="CI"
  export GITHUB_WORKFLOW_REF="owner/repo/.github/workflows/ci.yml@refs/heads/main"
  export GITHUB_RUN_ID="123456789"
  export GITHUB_RUN_NUMBER="42"
  export GITHUB_RUN_ATTEMPT="1"
  export GITHUB_EVENT_NAME="push"
  export EVENT_ACTION=""
  export GITHUB_BASE_REF=""
  export GITHUB_HEAD_REF=""
  export DEFAULT_BRANCH="main"
  export GITHUB_REF="refs/heads/main"
  export GITHUB_REF_NAME="main"
  export GITHUB_SHA="abc1234def5678"
  export MATRIX_CONTEXT='{"os":"ubuntu-latest","node":"20"}'
  export JOB_CONTEXT='{"status":"success","check_run_id":99999}'
  export RUNNER_CONTEXT='{"os":"Linux","arch":"X64","name":"runner-1","environment":"github-hosted"}'
  export CALLER_INPUTS='{"deploy":true,"env":"staging"}'
  export CALLER_NEEDS='{"some_dep":{"result":"success"}}'
  export CALLER_VARS='{"SOME_VAR":"the-value"}'
  export EXTRAS='{"custom":"data"}'
}

@test "exits 0 with all env vars set" {
  set_all_env_vars
  run "${PROJECT_ROOT}/action.sh"
  assert_success
}

@test "exits 0 with empty/missing env vars" {
  unset GITHUB_ACTOR GITHUB_WORKFLOW GITHUB_SHA 2>/dev/null || true
  export MATRIX_CONTEXT=""
  export JOB_CONTEXT=""
  export RUNNER_CONTEXT=""
  export CALLER_INPUTS=""
  export CALLER_NEEDS=""
  export CALLER_VARS=""
  export EXTRAS=""
  run "${PROJECT_ROOT}/action.sh"
  assert_success
}

@test "exits 0 with garbage input" {
  export MATRIX_CONTEXT="not json at all {{{"
  export JOB_CONTEXT="<xml>nope</xml>"
  export RUNNER_CONTEXT="12345"
  export CALLER_INPUTS="🔥"
  export CALLER_NEEDS=""
  export CALLER_VARS=""
  export EXTRAS=""
  run "${PROJECT_ROOT}/action.sh"
  assert_success
}

@test "snapshot: full output matches expected" {
  set_all_env_vars
  run "${PROJECT_ROOT}/action.sh"
  assert_success

  # normalize: strip ansi codes + trailing whitespace per line
  local clean
  clean="$(strip_ansi "$output" | sed 's/[[:space:]]*$//')"
  local expected
  expected="$(sed 's/[[:space:]]*$//' "${BATS_TEST_DIRNAME}/snapshots/full-run.expected.txt")"
  assert_equal "$clean" "$expected"
}
