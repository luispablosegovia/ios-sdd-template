#!/bin/bash
# smoke-new-project.sh — verifies that the template can be instantiated over a minimal Xcode-like project shell.
# This intentionally does not replace a real xcodebuild app build; instantiated apps still run scripts/verify.sh with their real scheme.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMPDIR_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/ios-sdd-smoke.XXXXXX")
trap 'rm -rf "$TMPDIR_ROOT"' EXIT
APP_NAME=SmokeApp
APP_DIR="$TMPDIR_ROOT/$APP_NAME"

mkdir -p "$APP_DIR/$APP_NAME" "$APP_DIR/${APP_NAME}Tests" "$APP_DIR/${APP_NAME}.xcodeproj"
git -C "$APP_DIR" init -q
git -C "$APP_DIR" config user.email "smoke@example.invalid"
git -C "$APP_DIR" config user.name "Smoke Test"

bash "$ROOT/scripts/new-project.sh" "$APP_DIR" "$APP_NAME"

required=(
  "CLAUDE.md"
  ".claude/settings.json"
  ".claude/commands/implement-next.md"
  ".specify/memory/constitution.md"
  "docs/ai-code-trust-pipeline.md"
  "scripts/verify.sh"
  ".github/workflows/ci.yml"
  "$APP_NAME/Features/README.md"
  "${APP_NAME}Tests/ExampleFeatureTests.swift"
  ".git/hooks/pre-commit"
)
for f in "${required[@]}"; do
  [ -e "$APP_DIR/$f" ] || { echo "missing expected instantiated file: $f" >&2; exit 1; }
done

if grep -R "__APP_NAME__" "$APP_DIR/CLAUDE.md" "$APP_DIR/.specify/memory/constitution.md" "$APP_DIR/scripts/verify.sh" "$APP_DIR/.github/workflows/ci.yml"; then
  echo "placeholder replacement failed" >&2
  exit 1
fi

echo "✔ new-project.sh smoke test passed"
