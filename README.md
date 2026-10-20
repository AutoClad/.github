# AutoClad/.github

Org-wide engineering conventions and shared CI for AutoClad repositories.
If you are new to the codebase, read this first.

## What is in here

| File | Purpose |
| --- | --- |
| `.github/workflows/ruby-extension-ci.yml` | Reusable CI for SketchUp extension repos: RuboCop (with rubocop-sketchup), Minitest, build the `.rbz` as an artifact |
| `.github/workflows/python-ci.yml` | Reusable CI for Python repos managed with uv: Ruff lint + format check, pytest |
| `PULL_REQUEST_TEMPLATE.md` | Default PR checklist every repo inherits |
| `scripts/install-git-hooks.sh` | Installs a pre-push hook that refuses direct pushes to `main` |

## How a change gets in

1. Branch from `main`: `git checkout -b <topic>`.
2. Make the change. For core logic, add or update a test in the same PR.
3. Run the repo's lint and tests locally (each repo's `CLAUDE.md` lists the commands).
4. Run `/code-review` in a **fresh** Claude Code session on the branch, not the session that wrote the code. Fix what is worth fixing.
5. Push the branch and open a PR: `git push -u origin <topic>` then `gh pr create`.
6. Wait for the CI checks to go green.
7. Structural change (new core module, export format, anything the designer sees)? Ask the other coder for a review before merging.
8. Merge: `gh pr merge --squash --delete-branch`, then `git checkout main && git pull`.

**Never push to `main` directly.** We are on GitHub's free plan, which does not enforce branch protection on private repos, so this is a convention, not a setting. Install the guard once per clone so a reflexive `git push` on the wrong branch is refused:

```bash
cd <repo>
bash <(curl -fsSL https://raw.githubusercontent.com/AutoClad/.github/main/scripts/install-git-hooks.sh)
```

This repo (`.github`) is the one exception: it has no CI and no product code, so direct pushes here are fine.

## Code review

Two layers, no human approval gate:

- **AI review, every PR.** `/code-review` in Claude Code before opening the PR. Each repo has a `REVIEW.md` telling the reviewer what matters in that codebase. Upgrade path, when a third coder joins or reviews get skipped: the `anthropics/claude-code-action` workflow, which runs the review on GitHub's side for every PR. One workflow file here plus one credential as an org secret.
- **Human review, on request.** Green CI is enough to merge routine changes. Request a review from the other coder for anything structural.

## Testing

Only pure code runs on CI. SketchUp cannot run headless or on Linux, so:

| Tier | What | Where | Trigger |
| --- | --- | --- | --- |
| Unit | `core/` (Ruby), protocol + tools (Python) | GitHub Actions and locally | every push and PR |
| Integration | SketchUp adapter code against the real API | a machine with SketchUp open, via TestUp | a person, or Claude Code through the sketchup-mcp bridge |
| Smoke | the packaged `.rbz` installs fresh and loads | a person, before tagging a release | release |

Keep the SketchUp-touching layer thin so most logic lands in the unit tier.

## Releases

Push a tag `v<major>.<minor>.<patch>` on a commit that passed the smoke test. A release workflow (not yet written; see the plan) rebuilds, attaches the `.rbz` to a GitHub Release, and later signs it for Extension Warehouse. The version string lives in one place per repo; tests check it stays in sync.

## Setting up a new repo

1. Add `.github/workflows/ci.yml` calling the matching reusable workflow:

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

   Use `python-ci.yml` for Python. Inputs (Ruby/Python version, whether to build an artifact) are documented at the top of each workflow.
2. Add `CLAUDE.md` (layout, rules, commands, the branching convention) and `REVIEW.md` (what `/code-review` should flag in this codebase). Copy from `autoclad-sketchup` and adapt.
3. Install the pre-push hook.
4. Open a first PR and confirm the checks go green.

## Issue tracking

GitHub Issues in the repo the work belongs to; one org-level Project board spans all repos. PRs reference their issue (`Closes #NN`) so merging closes it.

## Repos

- [`autoclad-sketchup`](https://github.com/AutoClad/autoclad-sketchup) — the product: a SketchUp extension for ACM cladding design.
- [`sketchup-mcp`](https://github.com/AutoClad/sketchup-mcp) — dev tool: the bridge that lets Claude Code drive a running SketchUp. Fork of mhyrr/sketchup-mcp.
