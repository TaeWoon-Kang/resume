#!/usr/bin/env bash

set -euo pipefail

# Keep automated Git operations in the terminal without opening an editor.
export GIT_EDITOR=true
export GIT_SEQUENCE_EDITOR=true
export GIT_PAGER=cat

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

BRANCH="$(git symbolic-ref --quiet --short HEAD)" || {
  echo "Cannot upload from a detached HEAD. Switch to a branch first." >&2
  exit 1
}

for operation in rebase-merge rebase-apply MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD; do
  if [[ -e "$(git rev-parse --git-path "$operation")" ]]; then
    echo "Finish or abort the current Git operation before uploading." >&2
    exit 1
  fi
done

if [[ -n "$(git ls-files --unmerged)" ]]; then
  echo "Resolve merge conflicts before uploading." >&2
  exit 1
fi

git remote get-url origin >/dev/null

echo "Changes to upload (including additions and deletions):"
git status --short
git add --all

if ! git diff --cached --quiet; then
  git diff --cached --check
  COMMIT_MESSAGE="$(date '+%Y-%m-%d %H:%M:%S %Z (%z)')"
  git commit -m "$COMMIT_MESSAGE"
else
  echo "No new changes to commit. Checking for unpushed commits."
fi

git fetch origin
if git show-ref --verify --quiet "refs/remotes/origin/$BRANCH"; then
  if ! git rebase "origin/$BRANCH"; then
    echo "Rebase stopped. Your commit is saved locally; nothing was pushed." >&2
    echo "Resolve conflicts, then run git add <files> and git rebase --continue." >&2
    echo "Run this script again after completing the rebase." >&2
    exit 1
  fi
fi

git push --set-upstream origin "$BRANCH"
echo "Uploaded branch: $BRANCH"
