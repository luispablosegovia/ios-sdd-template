#!/bin/bash
# verify.sh — Local/CI trust gate for AI-generated iOS changes.
# Runs deterministic checks before a task is accepted, committed, or merged.

set -euo pipefail

BOLD=$(tput bold 2>/dev/null || true); RESET=$(tput sgr0 2>/dev/null || true)
GREEN="\033[0;32m"; YELLOW="\033[0;33m"; RED="\033[0;31m"; NC="\033[0m"
FAILED=0
WARNED=0
STRICT_VERIFY=${STRICT_VERIFY:-0}

ok() { echo -e "${GREEN}✔${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; WARNED=1; }
fail() { echo -e "${RED}✘${NC} $1"; FAILED=1; }
warn_or_fail() { if [ "$STRICT_VERIFY" = "1" ]; then fail "$1"; else warn "$1"; fi; }
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
BASE_REF=${BASE_REF:-}
UNTRACKED_FILES=$(git ls-files --others --exclude-standard)
UNTRACKED_LINES=$(printf '%s\n' "$UNTRACKED_FILES" | sed '/^$/d' | while IFS= read -r f; do [ -f "$f" ] && wc -l < "$f" || true; done | awk '{sum+=$1} END {print sum+0}')

if [ -n "$BASE_REF" ]; then
  if git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
    MERGE_BASE=$(git merge-base HEAD "$BASE_REF")
    DIFF_RANGE="$MERGE_BASE...HEAD"
    echo "Using PR/base diff range: $DIFF_RANGE (BASE_REF=$BASE_REF)"
  else
    fail "BASE_REF '$BASE_REF' is not available locally; fetch it before running verify"
    DIFF_RANGE="HEAD"
  fi
else
  DIFF_RANGE="HEAD"
  echo "Using local working-tree diff against HEAD"
fi

if [ -n "$BASE_REF" ]; then
  DIFF_FILES=$(git diff --name-only "$DIFF_RANGE")
  TRACKED_DIFF_LINES=$(git diff --numstat "$DIFF_RANGE" 2>/dev/null | awk '{add+=$1; del+=$2} END {print add+del+0}')
else
  DIFF_FILES=$(git diff --name-only HEAD; git diff --cached --name-only; printf '%s\n' "$UNTRACKED_FILES")
  TRACKED_DIFF_LINES=$(git diff --numstat HEAD 2>/dev/null | awk '{add+=$1; del+=$2} END {print add+del+0}')
fi
DIFF_FILES=$(printf '%s\n' "$DIFF_FILES" | sed '/^$/d' | sort -u || true)
printf '%s\n' "$DIFF_FILES" | sed 's/^/  - /' || true

if printf '%s\n' "$DIFF_FILES" | grep -Eq '(^|/)project\.pbxproj$|\.xcodeproj/'; then
  fail "Xcode project file changed. Use Xcode/buildable folders; do not edit project.pbxproj directly."
else
  ok "no Xcode project file changes"
fi

MAX_DIFF_LINES=${AI_DIFF_MAX_LINES:-1200}
if [ -n "$BASE_REF" ]; then
  DIFF_LINES=$TRACKED_DIFF_LINES
  echo "Diff lines changed: $DIFF_LINES (tracked PR diff, limit: $MAX_DIFF_LINES)"
else
  DIFF_LINES=$((TRACKED_DIFF_LINES + UNTRACKED_LINES))
  echo "Diff lines changed: $DIFF_LINES (tracked: $TRACKED_DIFF_LINES, untracked: $UNTRACKED_LINES, limit: $MAX_DIFF_LINES)"
fi
if [ "$DIFF_LINES" -gt "$MAX_DIFF_LINES" ] && [ "${ALLOW_LARGE_DIFF:-0}" != "1" ]; then
  fail "diff is too large for routine AI review; split the task or set ALLOW_LARGE_DIFF=1 with human approval"
else
  ok "diff size within routine review limit"
fi

if [ -n "$BASE_REF" ]; then
  run_required "git diff whitespace check" git diff --check "$DIFF_RANGE"
else
  run_required "git diff whitespace check" git diff --check HEAD
fi

section "Secret scan"
SECRET_PATTERN="^\\+.*(api[_-]?key|secret|password|passwd|token|client[_-]?secret)[[:space:]]*[:=][[:space:]]*.{8,}"
SECRET_SCAN_FILE=$(mktemp "${TMPDIR:-/tmp}/verify-secret-scan.XXXXXX")
trap 'rm -f "$SECRET_SCAN_FILE"' EXIT
if [ -n "$BASE_REF" ]; then
  git diff --unified=0 "$DIFF_RANGE" > "$SECRET_SCAN_FILE.diff"
else
  git diff --unified=0 HEAD > "$SECRET_SCAN_FILE.diff"
fi
trap 'rm -f "$SECRET_SCAN_FILE" "$SECRET_SCAN_FILE.diff"' EXIT
if grep -Ei "$SECRET_PATTERN" "$SECRET_SCAN_FILE.diff" > "$SECRET_SCAN_FILE" 2>/dev/null; then
  fail "possible hardcoded secret in added lines"
  sed -n '1,20p' "$SECRET_SCAN_FILE"
else
  ok "no obvious hardcoded secrets in added lines"
fi

section "Dependency policy"
PACKAGE_TOUCHES=$(printf '%s\n' "$DIFF_FILES" | grep -E '(^|/)Package\.swift$|(^|/)Package\.resolved$|\.xcodeproj/xcshareddata/swiftpm/' || true)
ADR_TOUCHES=$(printf '%s\n' "$DIFF_FILES" | grep -E '^docs/decisions/[0-9]{4}-.+\.md$' || true)
if [ -n "$PACKAGE_TOUCHES" ] && [ -z "$ADR_TOUCHES" ]; then
  fail "package/dependency files changed without a numbered ADR in docs/decisions/"
  printf '%s\n' "$PACKAGE_TOUCHES" | sed 's/^/  dependency file: /'
else
  ok "dependency changes have numbered ADR coverage or no dependency files changed"
fi

section "Format and lint"
if command -v swiftformat >/dev/null 2>&1; then
  run_required "swiftformat --lint" swiftformat . --lint
else
  warn_or_fail "swiftformat not installed"
fi

if command -v swiftlint >/dev/null 2>&1; then
  run_required "swiftlint lint --strict" swiftlint lint --strict
else
  warn_or_fail "swiftlint not installed"
fi

section "Build and tests"
SCHEME=${SCHEME:-__APP_NAME__}
DESTINATION=${DESTINATION:-}
XCODEPROJ=$(find . -maxdepth 1 -name '*.xcodeproj' -print -quit)
TEMPLATE_REPO=0
if [ -z "$XCODEPROJ" ] && [ "$SCHEME" = "__APP_NAME__" ]; then
  TEMPLATE_REPO=1
fi

if [ -z "$XCODEPROJ" ]; then
  if [ "$TEMPLATE_REPO" = "1" ]; then
    warn "no .xcodeproj found; skipping xcodebuild (expected in template repo before instantiation)"
  else
    warn_or_fail "no .xcodeproj found for instantiated app"
  fi
elif [ "$SCHEME" = "__APP_NAME__" ]; then
  warn_or_fail "SCHEME is still __APP_NAME__; run new-project.sh or set SCHEME explicitly"
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
