#!/usr/bin/env bash

# formats a value for display
# json objects -> aligned key:value table
# other json -> pretty-printed
# non-json / n/a -> raw
format_value() {
  local value="$1"
  if [ "$value" = "n/a" ] || [ -z "$value" ]; then
    echo "n/a"
    return
  fi
  if ! command -v jq >/dev/null 2>&1; then
    printf '%s\n' "$value"
    return
  fi
  # {} is what toJSON(inputs) on push / toJSON(needs) with no needs gives you
  if printf '%s' "$value" | jq -e 'type == "object" and length == 0' >/dev/null 2>&1; then
    echo "{}"
    return
  fi
  if printf '%s' "$value" | jq -e 'type == "object"' >/dev/null 2>&1; then
    printf '%s' "$value" | jq -r '
      (keys | map(length) | max) as $w |
      to_entries[] |
      "\(.key + (" " * ($w - (.key | length)))) : \(.value | if type == "string" then . elif type == "null" then "" else tojson end)"
    '
    return
  fi
  if printf '%s' "$value" | jq -e '.' >/dev/null 2>&1; then
    printf '%s' "$value" | jq '.'
    return
  fi
  printf '%s\n' "$value"
}

# prints a labeled section with a colored box header
print_section() {
  local title="$1"
  local body="$2"
  local color=92 # bright green
  local bar_len=$(( ${#title} + 2 ))
  local bar
  bar="$(printf '─%.0s' $(seq 1 $bar_len))"
  printf '\e[1;%sm┌%s┐\e[0m\n' "$color" "$bar"
  printf '\e[1;%sm│ %s │\e[0m\n' "$color" "$title"
  printf '\e[1;%sm└%s┘\e[0m\n' "$color" "$bar"
  printf '%s\n' "$body"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # DEFAULT_BRANCH is empty when the event payload has no repository object
  is_default_branch="unknown"
  is_default_target="unknown"
  if [ -n "$DEFAULT_BRANCH" ]; then
    is_default_branch="false"
    is_default_target="false"
    if [ "$GITHUB_REF_NAME" = "$DEFAULT_BRANCH" ]; then
      is_default_branch="true"
    fi
    if [ "$GITHUB_BASE_REF" = "$DEFAULT_BRANCH" ]; then
      is_default_target="true"
    fi
  fi

  run_url=""
  job_url=""
  if [ -n "$GITHUB_SERVER_URL" ] && [ -n "$GITHUB_REPOSITORY" ] && [ -n "$GITHUB_RUN_ID" ]; then
    run_url="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
    # check_run_id doesn't exist on GHES
    if [ -n "$JOB_CHECK_RUN_ID" ]; then
      job_url="$run_url/job/$JOB_CHECK_RUN_ID"
    fi
  fi

  derived_body=$(cat <<EOF
is_default_branch : $is_default_branch
is_default_target : $is_default_target
run_url           : $run_url
job_url           : $job_url
EOF
  )

  github_context_body=$(cat <<EOF
github.actor               : $GITHUB_ACTOR
github.actor_id            : $GITHUB_ACTOR_ID
github.api_url             : $GITHUB_API_URL
github.base_ref            : $GITHUB_BASE_REF
github.event.action        : $EVENT_ACTION
github.event.pr_number     : $PR_NUMBER
github.event_name          : $GITHUB_EVENT_NAME
github.event_path          : $GITHUB_EVENT_PATH
github.graphql_url         : $GITHUB_GRAPHQL_URL
github.head_ref            : $GITHUB_HEAD_REF
github.job                 : $GITHUB_JOB
github.ref                 : $GITHUB_REF
github.ref_name            : $GITHUB_REF_NAME
github.ref_protected       : $GITHUB_REF_PROTECTED
github.ref_type            : $GITHUB_REF_TYPE
github.repository          : $GITHUB_REPOSITORY
github.repository_id       : $GITHUB_REPOSITORY_ID
github.repository_owner    : $GITHUB_REPOSITORY_OWNER
github.repository_owner_id : $GITHUB_REPOSITORY_OWNER_ID
github.retention_days      : $GITHUB_RETENTION_DAYS
github.run_attempt         : $GITHUB_RUN_ATTEMPT
github.run_id              : $GITHUB_RUN_ID
github.run_number          : $GITHUB_RUN_NUMBER
github.secret_source       : $SECRET_SOURCE
github.server_url          : $GITHUB_SERVER_URL
github.sha                 : $GITHUB_SHA
github.triggering_actor    : $TRIGGERING_ACTOR
github.workflow            : $GITHUB_WORKFLOW
github.workflow_ref        : $GITHUB_WORKFLOW_REF
github.workflow_sha        : $GITHUB_WORKFLOW_SHA
github.workspace           : $GITHUB_WORKSPACE
EOF
  )

  print_section "derived" "$derived_body"
  print_section "github context" "$github_context_body"
  print_section "matrix context" "$(format_value "$MATRIX_CONTEXT")"
  print_section "strategy context" "$(format_value "$STRATEGY_CONTEXT")"
  print_section "job context" "$(format_value "$JOB_CONTEXT")"
  print_section "runner context" "$(format_value "$RUNNER_CONTEXT")"
  print_section "caller inputs" "$(format_value "$CALLER_INPUTS")"
  print_section "caller needs" "$(format_value "$CALLER_NEEDS")"
  print_section "caller vars" "$(format_value "$CALLER_VARS")"
  print_section "extras" "$(format_value "$EXTRAS")"

  exit 0
fi
