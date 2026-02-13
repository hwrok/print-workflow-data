#!/usr/bin/env bash
set +eo pipefail

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
    echo "$value"
    return
  fi
  if echo "$value" | jq -e 'type == "object"' >/dev/null 2>&1; then
    echo "$value" | jq -r '
      (keys | map(length) | max) as $w |
      to_entries[] |
      "\(.key + (" " * ($w - (.key | length)))) : \(.value | if type == "string" then . elif type == "null" then "" else tojson end)"
    '
    return
  fi
  if echo "$value" | jq -e '.' >/dev/null 2>&1; then
    echo "$value" | jq '.'
    return
  fi
  echo "$value"
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
  is_default_branch="false"
  is_default_target="false"
  [ "$GITHUB_REF_NAME" = "$DEFAULT_BRANCH" ] && is_default_branch="true"
  [ "$GITHUB_BASE_REF" = "$DEFAULT_BRANCH" ] && is_default_target="true"

  github_context_body=$(cat <<EOF
github.actor            : $GITHUB_ACTOR
github.triggering_actor : $TRIGGERING_ACTOR
github.workflow         : $GITHUB_WORKFLOW
github.workflow_ref     : $GITHUB_WORKFLOW_REF
github.run_id           : $GITHUB_RUN_ID
github.run_number       : $GITHUB_RUN_NUMBER
github.run_attempt      : $GITHUB_RUN_ATTEMPT
github.event_name       : $GITHUB_EVENT_NAME
github.event.action     : $EVENT_ACTION
github.base_ref         : $GITHUB_BASE_REF
github.head_ref         : $GITHUB_HEAD_REF
is_default_branch       : $is_default_branch
is_default_target       : $is_default_target
github.ref              : $GITHUB_REF
github.ref_name         : $GITHUB_REF_NAME
github.sha              : $GITHUB_SHA
EOF
  )

  print_section "github context" "$github_context_body"
  print_section "matrix context" "$(format_value "$MATRIX_CONTEXT")"
  print_section "job context" "$(format_value "$JOB_CONTEXT")"
  print_section "runner context" "$(format_value "$RUNNER_CONTEXT")"
  print_section "caller inputs" "$(format_value "$CALLER_INPUTS")"
  print_section "caller needs" "$(format_value "$CALLER_NEEDS")"
  print_section "caller vars" "$(format_value "$CALLER_VARS")"
  print_section "extras" "$(format_value "$EXTRAS")"

  exit 0
fi
