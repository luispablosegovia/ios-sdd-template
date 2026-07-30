#!/bin/bash
# install.sh — Install ios-sdd CLI from this template repo into ~/.local/bin.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ ! -f "$TEMPLATE_DIR/scripts/ios-sdd" ]; then
  echo "✘ scripts/ios-sdd not found in $TEMPLATE_DIR"
  exit 1
fi

chmod +x "$TEMPLATE_DIR/scripts/ios-sdd"
IOS_SDD_TEMPLATE_DIR="$TEMPLATE_DIR" "$TEMPLATE_DIR/scripts/ios-sdd" install

echo ""
echo "Verify with:"
echo "  ios-sdd doctor /path/to/your/XcodeProject"
