# Print Workflow Data

Prints most of the data from the `github` object, as well as matrix context, job context, runner context, and optionally passed inputs, needs, and vars from the caller.

See [github documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/contexts) for information about each context and what certain values may mean.

## example usage:

```yaml
- uses: hwrok/print-workflow-data
  with:
    caller-inputs: ${{ toJSON(inputs) }} # optional
    caller-needs: ${{ toJSON(needs) }} # optional
    caller-vars: ${{ toJSON(vars) }} # optional
```
