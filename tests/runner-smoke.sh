#!/usr/bin/env bash
# runs action.sh against a real runner's env and checks the output.
# action.sh can never fail a job by design, so this is what catches a broken script in CI.
set -euo pipefail

if [ "${GITHUB_ACTIONS:-}" != "true" ]; then
  echo "not on a github runner, skipping"
  exit 0
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="$(bash "$root/action.sh")"
printf '%s\n' "$out"

failed=0
expect() {
  local desc="$1"
  shift
  if ! printf '%s\n' "$out" | grep "$@" >/dev/null; then
    echo "::error::runner smoke: missing $desc"
    failed=1
  fi
}

for title in "github context" "matrix context" "job context" "runner context" \
  "caller inputs" "caller needs" "caller vars" "extras"; do
  expect "section '$title'" -F "│ $title │"
done
expect "github.repository" -Fx "github.repository       : $GITHUB_REPOSITORY"
expect "github.sha" -Fx "github.sha              : $GITHUB_SHA"
expect "job context status" -E '^status +: '
expect "runner context os" -E "^os +: $RUNNER_OS\$"

exit "$failed"
