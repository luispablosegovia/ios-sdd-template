#!/bin/bash
# install-git-hooks.sh — install project-local safety hooks.

set -euo pipefail
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [ -z "$ROOT" ]; then
  echo "Run this inside the project git repo."
  exit 1
fi

mkdir -p "$ROOT/.git/hooks"
cp "$ROOT/scripts/hooks/pre-commit" "$ROOT/.git/hooks/pre-commit"
chmod +x "$ROOT/.git/hooks/pre-commit"
echo "✔ Installed pre-commit hook"
