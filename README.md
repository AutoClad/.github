# AutoClad/.github

Org-wide defaults for AutoClad repositories.

- `.github/workflows/ruby-extension-ci.yml` — reusable CI for SketchUp extension repos (RuboCop, Minitest, .rbz build).
- `.github/workflows/python-ci.yml` — reusable CI for Python repos managed with uv (Ruff, pytest).
- `PULL_REQUEST_TEMPLATE.md` — default PR checklist for every repo.

## Use in a repo

Add `.github/workflows/ci.yml`:

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
jobs:
  ci:
    uses: AutoClad/.github/.github/workflows/ruby-extension-ci.yml@main
```

Swap in `python-ci.yml` for a Python repo. Inputs are documented at the top of each workflow.
