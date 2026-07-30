#!/bin/bash
# new-project.sh — Backward-compatible wrapper for ios-sdd init.
#
# Old usage:
#   bash scripts/new-project.sh <ruta-al-proyecto-xcode> <NombreDeLaApp>
#
# Preferred usage after running scripts/install.sh:
#   cd <ruta-al-proyecto-xcode>
#   ios-sdd init

set -euo pipefail

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-.}"
APP_NAME="${2:-}"

if [ ! -x "$TEMPLATE_DIR/scripts/ios-sdd" ]; then
  chmod +x "$TEMPLATE_DIR/scripts/ios-sdd"
fi

ARGS=(init "$TARGET_DIR" --yes)
if [ -n "$APP_NAME" ]; then
  ARGS+=(--app-name "$APP_NAME")
fi

IOS_SDD_TEMPLATE_DIR="$TEMPLATE_DIR" "$TEMPLATE_DIR/scripts/ios-sdd" "${ARGS[@]}"
