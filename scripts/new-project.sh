#!/bin/bash
# new-project.sh — Instancia este template dentro de un proyecto Xcode recién creado.
#
# Uso:
#   1. Creá el proyecto en Xcode (iOS App · SwiftUI · Swift Testing) en ~/Developer/MiApp
#   2. bash /ruta/al/template/scripts/new-project.sh ~/Developer/MiApp MiApp
#
# Copia CLAUDE.md, .claude/, .specify/, docs/, configs y CI al proyecto,
# reemplaza __APP_NAME__ por el nombre real, inicializa git y Spec Kit.

set -euo pipefail

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-}"
APP_NAME="${2:-}"

if [ -z "$TARGET_DIR" ] || [ -z "$APP_NAME" ]; then
  echo "Uso: new-project.sh <ruta-al-proyecto-xcode> <NombreDeLaApp>"
  echo "Ej.:  new-project.sh ~/Developer/MiApp MiApp"
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

if ! ls "$TARGET_DIR"/*.xcodeproj >/dev/null 2>&1; then
  echo "⚠  No veo un .xcodeproj en $TARGET_DIR."
  read -rp "¿Seguir igual? [y/N] " ans
  [ "${ans:-n}" = "y" ] || exit 1
fi

echo "→ Copiando template a $TARGET_DIR ..."
# Meta-layer (no pisa archivos existentes del proyecto, salvo los del template)
cp -R "$TEMPLATE_DIR/.claude"  "$TARGET_DIR/"
cp -R "$TEMPLATE_DIR/.specify" "$TARGET_DIR/"
cp -R "$TEMPLATE_DIR/specs"    "$TARGET_DIR/"
cp -R "$TEMPLATE_DIR/docs"     "$TARGET_DIR/"
cp -R "$TEMPLATE_DIR/scripts"  "$TARGET_DIR/"
mkdir -p "$TARGET_DIR/.github/workflows"
cp "$TEMPLATE_DIR/.github/workflows/ci.yml" "$TARGET_DIR/.github/workflows/"
cp "$TEMPLATE_DIR/CLAUDE.md"     "$TARGET_DIR/"
cp "$TEMPLATE_DIR/.swiftformat"  "$TARGET_DIR/"
cp "$TEMPLATE_DIR/.swiftlint.yml" "$TARGET_DIR/"
# .gitignore: solo si el proyecto no tiene uno
[ -f "$TARGET_DIR/.gitignore" ] || cp "$TEMPLATE_DIR/.gitignore" "$TARGET_DIR/"

echo "→ Reemplazando __APP_NAME__ por '$APP_NAME' ..."
for f in "$TARGET_DIR/CLAUDE.md" "$TARGET_DIR/.specify/memory/constitution.md" "$TARGET_DIR/.github/workflows/ci.yml" "$TARGET_DIR/scripts/verify.sh"; do
  [ -f "$f" ] && sed -i '' "s/__APP_NAME__/$APP_NAME/g" "$f"
done

# Layout de código fuente dentro del target (buildable folders)
SRC_DIR="$TARGET_DIR/$APP_NAME"
if [ -d "$SRC_DIR" ]; then
  echo "→ Creando layout Features/Core/Resources en $SRC_DIR ..."
  rsync -a --ignore-existing "$TEMPLATE_DIR/SourceTemplate/" "$SRC_DIR/"
else
  echo "⚠  No encontré la carpeta del target ($SRC_DIR)."
  echo "   Copiá SourceTemplate/ a mano adentro de la carpeta de tu target."
fi

# Test de ejemplo al target de tests, si existe
TESTS_DIR="$TARGET_DIR/${APP_NAME}Tests"
if [ -d "$TESTS_DIR" ]; then
  cp -n "$TEMPLATE_DIR/Tests/ExampleFeatureTests.swift" "$TESTS_DIR/" 2>/dev/null || true
  echo "→ Test de ejemplo (Swift Testing) copiado a ${APP_NAME}Tests/"
fi

# Git
if [ ! -d "$TARGET_DIR/.git" ]; then
  echo "→ Inicializando git ..."
  git -C "$TARGET_DIR" init -q && git -C "$TARGET_DIR" add -A \
    && git -C "$TARGET_DIR" commit -qm "chore: bootstrap project from ios-sdd-template"
fi

# Spec Kit
if command -v specify >/dev/null 2>&1; then
  echo "→ Inicializando Spec Kit (integración Claude Code) ..."
  (cd "$TARGET_DIR" && specify init . --force --integration claude) \
    || echo "⚠  'specify init' falló — corrélo a mano: specify init . --force --integration claude"
else
  echo "⚠  Spec Kit no instalado. Corré scripts/bootstrap.sh primero."
fi

# Git hooks de seguridad local
if [ -d "$TARGET_DIR/.git" ]; then
  echo "→ Instalando git hooks locales ..."
  (cd "$TARGET_DIR" && bash scripts/install-git-hooks.sh) \
    || echo "⚠  No pude instalar hooks — corré: bash scripts/install-git-hooks.sh"
fi

cat << EOF

✅ Listo. Próximos pasos:
   cd $TARGET_DIR
   claude --model opusplan
   # y adentro:  /speckit.constitution  →  /speckit.specify <tu feature>

Acordate: completá el "Overview" en CLAUDE.md y la fecha en constitution.md.
EOF
