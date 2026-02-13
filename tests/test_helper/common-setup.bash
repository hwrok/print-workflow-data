_common_setup() {
  PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"

  load "${PROJECT_ROOT}/node_modules/bats-support/load.bash"
  load "${PROJECT_ROOT}/node_modules/bats-assert/load.bash"

  source "${PROJECT_ROOT}/action.sh"
}

strip_ansi() {
  perl -pe 's/\e\[[0-9;]*m//g' <<< "$1"
}
