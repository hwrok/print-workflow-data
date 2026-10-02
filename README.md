# Print Workflow Data

Composite action that prints GitHub Actions context data for debugging. Outputs formatted, color-coded sections for derived values (default-branch flags, run/job URLs), the github, matrix, strategy, job, and runner contexts, plus optional caller-provided data.

Designed to run at the top of a workflow. Swallows errors to not fail workflows.

## Usage

```yaml
- uses: hwrok/print-workflow-data@v1
```

### With optional inputs

```yaml
- uses: hwrok/print-workflow-data@v1
  with:
    caller-inputs: ${{ toJSON(inputs) }}
    caller-needs: ${{ toJSON(needs) }}
    caller-vars: ${{ toJSON(vars) }}
    extras: ${{ toJSON(matrix) }}
```

## Inputs

| Input           | Description                                      | Required |
| --------------- | ------------------------------------------------ | -------- |
| `caller-inputs` | Workflow inputs — `${{ toJSON(inputs) }}`        | No       |
| `caller-needs`  | Job dependency results — `${{ toJSON(needs) }}`  | No       |
| `caller-vars`   | Repository/org variables — `${{ toJSON(vars) }}` | No       |
| `extras`        | Any additional data, ideally as `toJSON(...)`    | No       |

## Output

JSON objects are automatically formatted as aligned key-value tables (requires `jq` on the runner, falls back to raw JSON otherwise).

```
┌─────────┐
│ derived │
└─────────┘
is_default_branch : true
is_default_target : false
run_url           : https://github.com/org/repo/actions/runs/123456789
job_url           : https://github.com/org/repo/actions/runs/123456789/job/63441063310
┌────────────────┐
│ github context │
└────────────────┘
github.actor               : some_user
github.actor_id            : 111111
github.api_url             : https://api.github.com
github.base_ref            :
github.event.action        :
github.event.pr_number     :
github.event_name          : push
github.event_path          : /home/runner/work/_temp/_github_workflow/event.json
github.graphql_url         : https://api.github.com/graphql
github.head_ref            :
github.job                 : build
github.ref                 : refs/heads/main
github.ref_name            : main
github.ref_protected       : true
github.ref_type            : branch
github.repository          : org/repo
github.repository_id       : 123456
github.repository_owner    : org
github.repository_owner_id : 654321
github.retention_days      : 90
github.run_attempt         : 1
github.run_id              : 123456789
github.run_number          : 42
github.secret_source       : Actions
github.server_url          : https://github.com
github.sha                 : abc1234def5678
github.triggering_actor    : some_user
github.workflow            : Build and Test
github.workflow_ref        : org/repo/.github/workflows/build.yml@refs/heads/main
github.workflow_sha        : abc1234def5678
github.workspace           : /home/runner/work/repo/repo
┌────────────────┐
│ matrix context │
└────────────────┘
n/a
┌──────────────────┐
│ strategy context │
└──────────────────┘
n/a
┌─────────────┐
│ job context │
└─────────────┘
check_run_id        : 63441063310
workflow_ref        : org/repo/.github/workflows/build.yml@refs/heads/main
workflow_sha        : abc1234def5678
workflow_repository : org/repo
workflow_file_path  : .github/workflows/build.yml
status              : success
┌────────────────┐
│ runner context │
└────────────────┘
os          : Linux
arch        : X64
name        : runner-1
environment : github-hosted
┌───────────────┐
│ caller inputs │
└───────────────┘
n/a
┌──────────────┐
│ caller needs │
└──────────────┘
n/a
┌─────────────┐
│ caller vars │
└─────────────┘
n/a
┌────────┐
│ extras │
└────────┘
n/a
```

Section headers are color-coded green in the actual workflow logs. Sections with no data display `n/a`.

## Notes

- `caller-vars` exposes repository/org-level variables. Generally safe unless secrets have been stored as variables instead of secrets.
- `extras` accepts any string, but `toJSON(...)` format gets the nicest output.
- The action uses `continue-on-error: true` and `exit 0` — it will never fail a calling workflow.

## License

MIT
