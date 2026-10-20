#!/usr/bin/env bash
# Installs a pre-push hook in the current repo that refuses direct pushes to
# main. We rely on a convention (branch -> PR -> green CI -> merge) rather
# than GitHub branch protection; this catches the reflexive `git push` on the
# wrong branch. Run once per clone:
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/AutoClad/.github/main/scripts/install-git-hooks.sh)
#
# or copy this file in and run it from the repo root.
set -euo pipefail

hook_dir="$(git rev-parse --git-path hooks)"
mkdir -p "$hook_dir"
cat > "$hook_dir/pre-push" <<'HOOK'
#!/usr/bin/env bash
# Refuse direct pushes to main. Open a PR instead.
while read -r local_ref local_sha remote_ref remote_sha; do
  if [[ "$remote_ref" == "refs/heads/main" ]]; then
    echo "pre-push: direct pushes to main are not allowed. Push a branch and open a PR." >&2
    exit 1
  fi
done
exit 0
HOOK
chmod +x "$hook_dir/pre-push"
echo "Installed pre-push hook in $hook_dir"
