# AutoClad/.github

Org-level defaults and shared CI for AutoClad repositories: the pieces
GitHub itself reads from this special repo name. Engineering conventions,
the auth specs and the shared Claude Code rules live in the workspace repo,
[AutoClad/autoclad](https://github.com/AutoClad/autoclad); read its README
first if you are new to the codebase.

## What is in here

| File | Purpose |
| --- | --- |
| `.github/workflows/ruby-extension-ci.yml` | Reusable CI for SketchUp extension repos: RuboCop (with rubocop-sketchup), Minitest, build the `.rbz` as an artifact |
| `.github/workflows/python-ci.yml` | Reusable CI for Python repos managed with uv: Ruff lint + format check, pytest |
| `PULL_REQUEST_TEMPLATE.md` | Default PR checklist every repo inherits |
| `scripts/install-git-hooks.sh` | Installs a pre-push hook that refuses direct pushes to `main` |

## Using the reusable workflows

Add `.github/workflows/ci.yml` to the repo, calling the matching workflow:

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

Use `python-ci.yml` for Python. Inputs (Ruby/Python version, whether to
build an artifact) are documented at the top of each workflow.
`autoclad-backend` has its own workflow (Node, Firebase emulators) rather
than a reusable one here.

## The pre-push hook

The workspace repo's `scripts/bootstrap.sh` installs it in every clone. To
install it by hand in one repo:

```bash
cd <repo>
bash <(curl -fsSL https://raw.githubusercontent.com/AutoClad/.github/main/scripts/install-git-hooks.sh)
```

This repo is the one exception to the no-direct-push rule: it has no CI and
no product code, so direct pushes here are fine.

## Repos

- [`autoclad`](https://github.com/AutoClad/autoclad) — workspace: specs, conventions, shared `CLAUDE.md`, bootstrap script.
- [`autoclad-sketchup`](https://github.com/AutoClad/autoclad-sketchup) — the product: a SketchUp extension for ACM cladding design.
- [`autoclad-backend`](https://github.com/AutoClad/autoclad-backend) — Firebase backend: sign-in, allowlisting, admin page, release manifests.
- [`sketchup-mcp`](https://github.com/AutoClad/sketchup-mcp) — dev tool: the bridge that lets Claude Code drive a running SketchUp. Fork of mhyrr/sketchup-mcp.
