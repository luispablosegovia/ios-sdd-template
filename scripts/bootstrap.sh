#!/bin/bash
# bootstrap.sh — Setup one-time de la Mac para desarrollo iOS con Claude Code + Spec Kit
# Uso: bash scripts/bootstrap.sh
# Es idempotente: lo podés correr las veces que quieras.

set -uo pipefail

BOLD=$(tput bold 2>/dev/null || echo ""); RESET=$(tput sgr0 2>/dev/null || echo "")
GREEN="\033[0;32m"; YELLOW="\033[0;33m"; RED="\033[0;31m"; NC="\033[0m"

ok()   { echo -e "${GREEN}✔${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
fail() { echo -e "${RED}✘${NC} $1"; }

echo "${BOLD}🛠  Bootstrap — entorno iOS + Claude Code + Spec Kit${RESET}"
echo ""

# ── 1. Xcode ────────────────────────────────────────────────────────────────
if xcodebuild -version >/dev/null 2>&1; then
  ok "Xcode: $(xcodebuild -version | head -1)"
  XCODE_MAJOR=$(xcodebuild -version | head -1 | sed 's/Xcode //' | cut -d. -f1)
  XCODE_MINOR=$(xcodebuild -version | head -1 | sed 's/Xcode //' | cut -d. -f2)
  if [ "$XCODE_MAJOR" -lt 26 ] || { [ "$XCODE_MAJOR" -eq 26 ] && [ "$XCODE_MINOR" -lt 3 ]; }; then
    warn "Necesitás Xcode 26.3+ para el MCP nativo de Apple. Actualizá desde el App Store."
  fi
else
  fail "Xcode no está instalado o no configurado."
  echo "   1) Instalalo desde el App Store  2) Abrilo una vez  3) Corré:"
  echo "      sudo xcode-select -s /Applications/Xcode.app && sudo xcodebuild -license accept"
  exit 1
fi

# ── 2. Homebrew ─────────────────────────────────────────────────────────────
if command -v brew >/dev/null 2>&1; then
  ok "Homebrew instalado"
else
  echo "→ Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon: agregar al PATH de esta sesión
  eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
fi

# ── 3. Herramientas CLI ─────────────────────────────────────────────────────
TOOLS=(swiftformat swiftlint xcbeautify jq gh node uv)
for t in "${TOOLS[@]}"; do
  if command -v "$t" >/dev/null 2>&1; then
    ok "$t"
  else
    echo "→ Instalando $t..."
    brew install "$t" && ok "$t instalado" || fail "No pude instalar $t"
  fi
done

# ── 4. Claude Code ──────────────────────────────────────────────────────────
if command -v claude >/dev/null 2>&1; then
  ok "Claude Code: $(claude --version 2>/dev/null | head -1)"
else
  echo "→ Instalando Claude Code..."
  npm install -g @anthropic-ai/claude-code && ok "Claude Code instalado"
  warn "Corré 'claude' una vez para loguearte con tu suscripción."
fi

# ── 5. Spec Kit ─────────────────────────────────────────────────────────────
if command -v specify >/dev/null 2>&1; then
  ok "Spec Kit: instalado (actualizá con: uv tool upgrade specify-cli)"
else
  echo "→ Instalando Spec Kit..."
  uv tool install specify-cli --from git+https://github.com/github/spec-kit.git \
    && ok "Spec Kit instalado" || fail "No pude instalar Spec Kit"
fi

# ── 6. MCPs de iOS ──────────────────────────────────────────────────────────
if command -v claude >/dev/null 2>&1; then
  if claude mcp list 2>/dev/null | grep -qi xcodebuild; then
    ok "XcodeBuildMCP ya configurado"
  else
    echo "→ Configurando XcodeBuildMCP (auto-instalador)..."
    npx -y xcodebuildmcp@latest init || {
      warn "El auto-instalador falló; probando modo manual..."
      claude mcp add XcodeBuildMCP -s user \
        -e XCODEBUILDMCP_SENTRY_DISABLED=true \
        -- npx -y xcodebuildmcp@latest mcp
    }
  fi
  if claude mcp list 2>/dev/null | grep -qw xcode; then
    ok "MCP nativo de Apple ya configurado"
  else
    echo "→ Configurando MCP nativo de Apple (xcrun mcpbridge)..."
    claude mcp add --transport stdio xcode -s user -- xcrun mcpbridge \
      && ok "MCP de Apple configurado" \
      || warn "No pude configurar xcrun mcpbridge (¿Xcode 26.3+?)"
  fi
fi

echo ""
echo "${BOLD}✅ Checklist final:${RESET}"
for c in "xcodebuild -version" "claude --version" "specify --help" "swiftformat --version" "swiftlint version"; do
  if $c >/dev/null 2>&1; then ok "$c"; else fail "$c"; fi
done
echo ""
echo "Siguiente paso → README.md, sección 'Cómo arrancar un proyecto nuevo' 🚀"
