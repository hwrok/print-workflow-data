# Print Workflow Data

Composite action that prints GitHub Actions context data for debugging. Outputs formatted, color-coded sections for github, matrix, job, runner contexts, plus optional caller-provided data.

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
┌────────────────┐
│ github context │
└────────────────┘
github.repository       : org/repo
github.actor            : some_user
github.triggering_actor : some_user
github.job              : build
github.workflow         : Build and Test
github.workflow_ref     : org/repo/.github/workflows/build.yml@refs/heads/main
github.run_id           : 123456789
github.run_number       : 42
github.run_attempt      : 1
github.event_name       : push
github.event.action     :
github.event.pr_number  :
github.base_ref         :
github.head_ref         :
is_default_branch       : true
is_default_target       : false
github.ref              : refs/heads/main
github.ref_name         : main
github.sha              : abc1234def5678
┌────────────────┐
│ matrix context │
└────────────────┘
n/a
┌─────────────┐
│ job context │
└─────────────┘
check_run_id : 63441063310
status       : success
┌────────────────┐
│ runner context │
└────────────────┘
arch        : X64
environment : github-hosted
name        : runner-1
os          : Linux
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
