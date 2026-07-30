# 🛠️ SETUP.md — Preparar tu Mac (se hace UNA sola vez)

Guía para tu MacBook Pro M5 (24 GB / 1 TB). Tiempo estimado: 40–60 min
(la mayoría es descarga de Xcode). Al final tenés todo listo para crear
proyectos con `ios-sdd init` después de crear una app en Xcode.

> Atajo: los pasos 2 a 6 los automatiza `scripts/bootstrap.sh`.
> Igual leé esta guía una vez para entender qué instala cada cosa.

---

## Paso 0 — Requisitos

- macOS actualizado a la última versión (Ajustes → General → Actualización de software).
- Apple ID. Para publicar en el App Store vas a necesitar la cuenta paga del
  Apple Developer Program (USD 99/año), pero para desarrollar y probar en simulador no.
- Suscripción a Claude (Pro o Max). Con Max tenés más margen para sesiones largas
  con Opus; con Pro alcanza para arrancar.

## Paso 1 — Xcode (la descarga larga)

1. App Store → buscá **Xcode** → Instalar (son varios GB, paciencia).
2. Abrilo una vez: aceptá la licencia y dejá que instale los componentes.
3. Cuando pregunte por plataformas, asegurate de tener el **iOS SDK** y al menos
   un **simulador de iPhone** descargado (Xcode → Settings → Components).
4. En la terminal:

```bash
xcode-select --install          # command line tools (si no las tenés)
sudo xcodebuild -license accept
xcodebuild -version             # verificá que sea Xcode 26.3 o superior
```

> Necesitás **Xcode 26.3+** para el MCP nativo de Apple (`xcrun mcpbridge`)
> y para la integración de agentes dentro de Xcode. Cuanto más nuevo, mejor.

## Paso 2 — Homebrew (el gestor de paquetes de macOS)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Seguí las instrucciones que imprime al final para agregarlo al PATH
brew --version
```

## Paso 3 — Herramientas de línea de comandos

```bash
brew bundle --file Brewfile
# equivalente manual: brew install swiftformat swiftlint xcbeautify jq gh node uv gitleaks
```

Qué es cada una:
- **swiftformat / swiftlint** → formato y estilo automático (los hooks del template los usan).
- **xcbeautify** → hace legible la salida de `xcodebuild` (clave para que los agentes
  no se ahoguen en logs).
- **jq** → parsear JSON en los hooks.
- **gitleaks** → escaneo local de secretos en hooks y `scripts/verify.sh`.
- **gh** → GitHub CLI (para que Claude pueda crear PRs). Después: `gh auth login`.
- **node** → necesario para `npx` (así se instalan los MCPs).
- **uv** → gestor de Python moderno, es como se instala Spec Kit.

## Paso 4 — Claude Code

```bash
npm install -g @anthropic-ai/claude-code
claude --version
claude          # primera vez: te abre el browser para loguearte con tu suscripción
```

Docs oficiales: https://code.claude.com/docs — si algo de esta guía cambió,
la fuente de verdad es esa.

## Paso 5 — Spec Kit (GitHub)

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
specify --help
specify integration list    # tiene que aparecer "claude" en la lista
```

## Paso 6 — MCPs para iOS (los superpoderes)

Los MCPs le dan a Claude Code acceso estructurado a builds, tests, simuladores
y debugging, en vez de andar adivinando comandos.

**Opción automática (recomendada):**

```bash
npx -y xcodebuildmcp@latest init
# Detecta Claude Code y te instala el MCP + skills en un paso
```

**Opción manual (si la automática falla):**

```bash
# XcodeBuildMCP — builds, tests, simuladores, screenshots, logs
claude mcp add XcodeBuildMCP -s user \
  -e XCODEBUILDMCP_SENTRY_DISABLED=true \
  -- npx -y xcodebuildmcp@latest mcp

# MCP nativo de Apple (Xcode 26.3+) — diagnósticos, previews, Swift REPL
claude mcp add --transport stdio xcode -s user -- xcrun mcpbridge
```

Verificá con `claude mcp list` que los dos figuren conectados.

## Paso 7 — Skills de Swift de la comunidad (opcional pero muy recomendado)

Paul Hudson (Hacking with Swift) mantiene skills para SwiftUI, SwiftData,
Swift Concurrency y Swift Testing que elevan mucho la calidad del código generado.
Buscá el repo **"Swift Agent Skills"** en hackingwithswift.com y seguí las
instrucciones de instalación (elegí instalación global + symlink cuando pregunte).

## Paso 8 — Instalar el comando `ios-sdd`

```bash
bash scripts/install.sh
which ios-sdd
ios-sdd help
```

Si `which ios-sdd` no encuentra el comando, agregá `~/.local/bin` a tu PATH:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Paso 9 — Git configurado

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
git config --global init.defaultBranch main
gh auth login
```

---

## ✅ Checklist final

```bash
xcodebuild -version   # Xcode 26.3+
claude --version      # Claude Code instalado
specify --help        # Spec Kit instalado
claude mcp list       # XcodeBuildMCP y xcode conectados
swiftformat --version && swiftlint version && xcbeautify --version
```

Si todo eso responde, tu Mac está lista. Andá al `README.md` sección
**"Cómo arrancar un proyecto nuevo"** y creá tu primera app. 🚀
