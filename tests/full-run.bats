#!/usr/bin/env bats

setup() {
  load 'test_helper/common-setup'
  _common_setup
}

set_all_env_vars() {
  export GITHUB_REPOSITORY="owner/repo"
  export GITHUB_REPOSITORY_ID="1061921084"
  export GITHUB_REPOSITORY_OWNER="owner"
  export GITHUB_REPOSITORY_OWNER_ID="221171328"
  export GITHUB_ACTOR_ID="13083536"
  export GITHUB_WORKFLOW_SHA="abc1234def5678"
  export GITHUB_API_URL="https://api.github.com"
  export GITHUB_GRAPHQL_URL="https://api.github.com/graphql"
  export GITHUB_WORKSPACE="/home/runner/work/repo/repo"
  export GITHUB_EVENT_PATH="/home/runner/work/_temp/_github_workflow/event.json"
  export GITHUB_RETENTION_DAYS="90"
  export GITHUB_ACTOR="testuser"
  export TRIGGERING_ACTOR="testuser"
  export GITHUB_JOB="build"
  export GITHUB_WORKFLOW="CI"
  export GITHUB_WORKFLOW_REF="owner/repo/.github/workflows/ci.yml@refs/heads/main"
  export GITHUB_RUN_ID="123456789"
  export GITHUB_RUN_NUMBER="42"
  export GITHUB_RUN_ATTEMPT="1"
  export GITHUB_EVENT_NAME="push"
  export EVENT_ACTION=""
  export PR_NUMBER=""
  export SECRET_SOURCE="Actions"
  export JOB_CHECK_RUN_ID="99999"
  export GITHUB_SERVER_URL="https://github.com"
  export GITHUB_BASE_REF=""
  export GITHUB_HEAD_REF=""
  export DEFAULT_BRANCH="main"
  export GITHUB_REF="refs/heads/main"
  export GITHUB_REF_NAME="main"
  export GITHUB_REF_TYPE="branch"
  export GITHUB_REF_PROTECTED="true"
  export GITHUB_SHA="abc1234def5678"
  export MATRIX_CONTEXT='{"os":"ubuntu-latest","node":"20"}'
  export STRATEGY_CONTEXT='{"fail-fast":false,"job-index":0,"job-total":3,"max-parallel":3}'
  export JOB_CONTEXT='{"status":"success","check_run_id":99999}'
  export RUNNER_CONTEXT='{"os":"Linux","arch":"X64","name":"runner-1","environment":"github-hosted"}'
  export CALLER_INPUTS='{"deploy":true,"env":"staging","msg":"ship it 🚀 100% #yolo -n"}'
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
  export STRATEGY_CONTEXT=""
  export JOB_CONTEXT=""
  export RUNNER_CONTEXT=""
  export CALLER_INPUTS=""
  export CALLER_NEEDS=""
  export CALLER_VARS=""
  export EXTRAS=""
  run "${PROJECT_ROOT}/action.sh"
  assert_success
  assert_line "n/a"
  refute_output --partial "null"
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
  assert_line "not json at all {{{"
  assert_line "<xml>nope</xml>"
  assert_line "12345"
  assert_line "🔥"
}

@test "pr into default branch flags is_default_target" {
  set_all_env_vars
  export GITHUB_EVENT_NAME="pull_request"
  export GITHUB_BASE_REF="main"
  export GITHUB_HEAD_REF="fix/thing"
  export GITHUB_REF_NAME="7/merge"
  run "${PROJECT_ROOT}/action.sh"
  assert_success
  assert_line "is_default_branch : false"
  assert_line "is_default_target : true"
}

@test "missing default branch reports unknown instead of guessing" {
  set_all_env_vars
  export DEFAULT_BRANCH=""
  run "${PROJECT_ROOT}/action.sh"
  assert_success
  assert_line "is_default_branch : unknown"
  assert_line "is_default_target : unknown"
}

@test "no check_run_id (GHES) leaves job_url empty but keeps run_url" {
  set_all_env_vars
  export JOB_CHECK_RUN_ID=""
  run "${PROJECT_ROOT}/action.sh"
  assert_success
  assert_line "run_url           : https://github.com/owner/repo/actions/runs/123456789"
  assert_line --regexp '^job_url +: ?$'
}

@test "empty object sections render {}" {
  set_all_env_vars
  export CALLER_INPUTS='{}'
  export CALLER_NEEDS='{}'
  run "${PROJECT_ROOT}/action.sh"
  assert_success
  local clean
  clean="$(strip_ansi "$output")"
  [[ "$clean" == *$'caller inputs │\n└───────────────┘\n{}'* ]]
  [[ "$clean" == *$'caller needs │\n└──────────────┘\n{}'* ]]
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
