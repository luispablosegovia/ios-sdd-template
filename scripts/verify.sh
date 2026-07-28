#!/bin/bash
# verify.sh — Local/CI trust gate for AI-generated iOS changes.
# Runs deterministic checks before a task is accepted, committed, or merged.

set -euo pipefail

BOLD=$(tput bold 2>/dev/null || true); RESET=$(tput sgr0 2>/dev/null || true)
GREEN="\033[0;32m"; YELLOW="\033[0;33m"; RED="\033[0;31m"; NC="\033[0m"
FAILED=0
WARNED=0

ok() { echo -e "${GREEN}✔${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; WARNED=1; }
fail() { echo -e "${RED}✘${NC} $1"; FAILED=1; }
section() { echo ""; echo "${BOLD}== $1 ==${RESET}"; }
run_required() {
  local label="$1"; shift
  echo "→ $label"
  if "$@"; then ok "$label"; else fail "$label"; fi
}

section "Repository"
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  ROOT=$(git rev-parse --show-toplevel)
  cd "$ROOT"
  ok "git repo: $ROOT"
else
  fail "not inside a git repository"
  exit 1
fi

git status --short || true

section "Diff guardrails"
DIFF_FILES=$(git diff --name-only; git diff --cached --name-only; git ls-files --others --exclude-standard)
DIFF_FILES=$(printf '%s\n' "$DIFF_FILES" | sed '/^$/d' | sort -u || true)
printf '%s\n' "$DIFF_FILES" | sed 's/^/  - /' || true

if printf '%s\n' "$DIFF_FILES" | grep -Eq '(^|/)project\.pbxproj$|\.xcodeproj/'; then
  fail "Xcode project file changed. Use Xcode/buildable folders; do not edit project.pbxproj directly."
else
  ok "no Xcode project file changes"
fi

MAX_DIFF_LINES=${AI_DIFF_MAX_LINES:-1200}
TRACKED_DIFF_LINES=$(git diff --numstat HEAD 2>/dev/null | awk '{add+=$1; del+=$2} END {print add+del+0}')
UNTRACKED_LINES=$(git ls-files --others --exclude-standard | while IFS= read -r f; do [ -f "$f" ] && wc -l < "$f" || true; done | awk '{sum+=$1} END {print sum+0}')
DIFF_LINES=$((TRACKED_DIFF_LINES + UNTRACKED_LINES))
echo "Diff lines changed: $DIFF_LINES (tracked: $TRACKED_DIFF_LINES, untracked: $UNTRACKED_LINES, limit: $MAX_DIFF_LINES)"
if [ "$DIFF_LINES" -gt "$MAX_DIFF_LINES" ] && [ "${ALLOW_LARGE_DIFF:-0}" != "1" ]; then
  fail "diff is too large for routine AI review; split the task or set ALLOW_LARGE_DIFF=1 with human approval"
else
  ok "diff size within routine review limit"
fi

run_required "git diff whitespace check" git diff --check

section "Secret scan"
SECRET_PATTERN="^\\+.*(api[_-]?key|secret|password|passwd|token|client[_-]?secret)[[:space:]]*[:=][[:space:]]*.{8,}"
if git diff --unified=0 HEAD 2>/dev/null | grep -Ei "$SECRET_PATTERN" >/tmp/verify-secret-scan.txt 2>/dev/null; then
  fail "possible hardcoded secret in added lines"
  sed -n '1,20p' /tmp/verify-secret-scan.txt
else
  ok "no obvious hardcoded secrets in added lines"
fi

section "Dependency policy"
PACKAGE_TOUCHES=$(printf '%s\n' "$DIFF_FILES" | grep -E '(^|/)Package\.swift$|(^|/)Package\.resolved$|\.xcodeproj/xcshareddata/swiftpm/' || true)
ADR_TOUCHES=$(printf '%s\n' "$DIFF_FILES" | grep -E '^docs/decisions/[0-9]{4}-.+\.md$|^docs/decisions/.+package.+\.md$' || true)
if [ -n "$PACKAGE_TOUCHES" ] && [ -z "$ADR_TOUCHES" ]; then
  fail "package/dependency files changed without a new ADR in docs/decisions/"
  printf '%s\n' "$PACKAGE_TOUCHES" | sed 's/^/  dependency file: /'
else
  ok "dependency changes have ADR coverage or no dependency files changed"
fi

section "Format and lint"
if command -v swiftformat >/dev/null 2>&1; then
  run_required "swiftformat --lint" swiftformat . --lint
else
  warn "swiftformat not installed"
fi

if command -v swiftlint >/dev/null 2>&1; then
  run_required "swiftlint lint --strict" swiftlint lint --strict
else
  warn "swiftlint not installed"
fi

section "Build and tests"
SCHEME=${SCHEME:-__APP_NAME__}
DESTINATION=${DESTINATION:-}
XCODEPROJ=$(find . -maxdepth 1 -name '*.xcodeproj' -print -quit)

if [ -z "$XCODEPROJ" ]; then
  warn "no .xcodeproj found; skipping xcodebuild (expected in template repo before instantiation)"
elif [ "$SCHEME" = "__APP_NAME__" ]; then
  warn "SCHEME is still __APP_NAME__; skipping xcodebuild until new-project.sh replaces it"
elif ! command -v xcodebuild >/dev/null 2>&1; then
  fail "xcodebuild not installed"
else
  if [ -z "$DESTINATION" ]; then
    if command -v xcrun >/dev/null 2>&1; then
      SIMULATOR_NAME=$(xcrun simctl list devices available | grep -oE 'iPhone [^(]+' | head -1 | xargs || true)
      if [ -n "$SIMULATOR_NAME" ]; then
        DESTINATION="platform=iOS Simulator,name=$SIMULATOR_NAME"
      fi
    fi
  fi
  if [ -z "$DESTINATION" ]; then
    fail "could not determine simulator destination; set DESTINATION='platform=iOS Simulator,name=...'"
  else
    echo "Using scheme: $SCHEME"
    echo "Using destination: $DESTINATION"
    if command -v xcbeautify >/dev/null 2>&1; then
      set +e
      set -o pipefail
      xcodebuild -scheme "$SCHEME" -destination "$DESTINATION" test 2>&1 | xcbeautify
      STATUS=$?
      set +o pipefail
      set -e
      if [ "$STATUS" -eq 0 ]; then ok "xcodebuild test"; else fail "xcodebuild test"; fi
    else
      run_required "xcodebuild test" xcodebuild -scheme "$SCHEME" -destination "$DESTINATION" test
    fi
  fi
fi

section "Verification result"
if [ "$FAILED" -ne 0 ]; then
  echo -e "${RED}VERIFICATION FAILED${NC}"
  exit 1
fi
if [ "$WARNED" -ne 0 ]; then
  echo -e "${YELLOW}VERIFICATION PASSED WITH WARNINGS${NC}"
else
  echo -e "${GREEN}VERIFICATION PASSED${NC}"
fi
