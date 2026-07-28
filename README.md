# 📱 iOS SDD Template — Spec Driven Development con Claude Code

Template para arrancar cualquier app de iOS con **spec driven development**, usando lo último
del ecosistema Apple (Swift 6, SwiftUI, SwiftData, Swift Testing) y un pipeline de modelos:

| Fase | Modelo | Quién |
|------|--------|-------|
| Especificar / Clarificar / Planificar | **Opus** (el más potente) | Subagente `planner` o `/model opus` |
| Implementar tarea por tarea | **Sonnet** (rápido y preciso) | Subagente `implementer` o `/model sonnet` |
| Verificación objetiva | **Sonnet** | Subagente `verifier` |
| Review de cada tarea / pre-merge | **Opus** con contexto limpio | Subagente `reviewer` |

> 💡 **Atajo:** Claude Code tiene el alias de modelo `opusplan`: usa Opus mientras estás en
> *plan mode* y cambia solo a Sonnet cuando pasa a ejecutar. Es exactamente este workflow
> con un solo comando: `claude --model opusplan` (o `/model opusplan` dentro de la sesión).
> Verificalo con `/model` — los alias disponibles pueden cambiar con las versiones.

**¿Por qué Opus para el review y no otro modelo?** El review es la fase donde más pesa el
criterio (concurrencia de Swift 6, edge cases, seguridad) y donde menos volumen de tokens se
consume (un review por tarea). Además, el subagente `reviewer` corre en un **contexto limpio**:
no arrastra los sesgos de la sesión que implementó el código, que es lo más parecido a "otro
par de ojos" sin pagar una segunda suscripción. Cuando el proyecto crezca, podés sumar
**Codex como segunda opinión externa** para merges grandes (ver "Upgrade path" abajo).

---

## Estructura del template

```
tu-proyecto/                      ← raíz del repo (al lado del .xcodeproj)
├── CLAUDE.md                     ← ⭐ contexto del proyecto para Claude Code
├── .claude/
│   ├── settings.json             ← permisos + hooks (format/lint automático, guardas)
│   ├── agents/
│   │   ├── planner.md            ← Opus · especifica y planifica, NO escribe código
│   │   ├── implementer.md        ← Sonnet · implementa UNA tarea por vez con TDD
│   │   ├── verifier.md           ← Sonnet · corre gates objetivos, no edita código
│   │   └── reviewer.md           ← Opus · review read-only con contexto limpio
│   └── commands/
│       ├── review.md             ← /review → dispara el reviewer sobre el diff
│       ├── verify.md             ← /verify → corre scripts/verify.sh con evidencia
│       ├── trust-report.md       ← /trust-report → resumen de riesgo/evidencia
│       └── test.md               ← /test → corre la suite completa
├── .specify/
│   └── memory/
│       └── constitution.md       ← ⭐ principios no negociables (Spec Kit la respeta)
├── specs/                        ← acá viven los specs por feature (los crea Spec Kit)
├── docs/
│   ├── architecture.md           ← arquitectura viva del proyecto
│   ├── ai-code-trust-pipeline.md ← política de evidencia para código generado por IA
│   ├── engineering-verification.md ← verificación independiente de fórmulas técnicas
│   └── decisions/                ← ADRs (registro de decisiones)
├── SourceTemplate/               ← layout sugerido para COPIAR dentro del target de Xcode
│   ├── App/                      ← entry point, configuración global
│   ├── Features/                 ← una carpeta por feature (View + Model + Tests)
│   ├── Core/                     ← DesignSystem, Networking, Persistence, Extensions
│   └── Resources/                ← assets, String Catalogs
├── Tests/ExampleFeatureTests.swift  ← ejemplo con Swift Testing (@Test, #expect)
├── scripts/
│   ├── bootstrap.sh              ← setup one-time de la Mac
│   ├── new-project.sh            ← instancia este template en un proyecto Xcode nuevo
│   ├── verify.sh                 ← gate local/CI para confiar en código generado por IA
│   └── install-git-hooks.sh      ← instala hooks locales de seguridad
├── .swiftformat / .swiftlint.yml ← estilo consistente (los hooks los corren solos)
├── .github/workflows/ci.yml      ← build + tests en cada push
└── .gitignore
```

---

## Los archivos que más importan (leelos en este orden)

### 1. `CLAUDE.md` — el cerebro del proyecto
Es lo primero que Claude Code lee en cada sesión. Acá viven: stack, comandos de build/test,
arquitectura, reglas de estilo y la lista de APIs legacy prohibidas. **Cuanto mejor esté este
archivo, menos tenés que repetir en cada prompt.** Actualizalo cuando el proyecto cambie:
es un documento vivo, no un README decorativo.

### 2. `.specify/memory/constitution.md` — las reglas del juego
Spec Kit la usa como base de TODO: cada spec, plan y tarea se valida contra ella. Acá está
lo no negociable: Swift 6 strict concurrency, Swift Testing en vez de XCTest, test primero,
accesibilidad, nada de frameworks legacy. Si algún día querés cambiar una regla, cambiala
acá y no en prompts sueltos.

### 3. `.claude/agents/*.md` — tu equipo de tres
Cada agente es un Markdown con frontmatter YAML. La línea `model:` fija qué modelo usa
(`opus` y `sonnet` son alias que resuelven siempre a la versión más nueva de cada familia,
así el template no queda viejo). El `reviewer` tiene tools de solo lectura + Bash: puede
correr los tests pero **no puede tocar código** — eso lo obliga a dar feedback en vez de
"arreglar" en silencio.

### 4. `.claude/settings.json` — automatización determinística
Los hooks corren SIEMPRE, sin depender de que el modelo se acuerde:
- **PostToolUse**: cada `.swift` que Claude edita pasa por SwiftFormat + SwiftLint al toque.
- **PreToolUse**: bloquea ediciones a mano del `project.pbxproj` (fuente clásica de proyectos
  rotos — con buildable folders de Xcode no hace falta tocarlo nunca).
- **permissions**: pre-aprueba comandos seguros (xcodebuild, swift, git status…) para que
  no te pida confirmación a cada rato.

### 5. `docs/ai-code-trust-pipeline.md` — cómo confiar sin leer cada línea
Define la política de evidencia para código generado por IA: cambio chico, RED/GREEN real,
`/verify`, `/review`, `/trust-report`, clasificación de riesgo y cuándo sí hace falta revisión
humana. Para apps de ingeniería, `docs/engineering-verification.md` agrega reglas específicas
para fórmulas críticas y ejemplos numéricos independientes.

### 6. `specs/` — el corazón del SDD
Cada feature vive en `specs/NNN-nombre/` con su `spec.md`, `plan.md` y `tasks.md`
(los genera Spec Kit). **El spec es la fuente de verdad, no el chat.** Si algo cambia,
se cambia el spec primero.

---

## Cómo arrancar un proyecto nuevo (el flujo completo)

> Prerequisito: haber corrido `scripts/bootstrap.sh` una vez en tu Mac (ver `SETUP.md`).

```bash
# 1. Creá el proyecto en Xcode
#    File → New → Project → iOS App
#    Interface: SwiftUI · Language: Swift · Testing System: Swift Testing
#    Storage: SwiftData (si tu app persiste datos)
#    Guardalo en ~/Developer/MiApp

# 2. Instanciá el template adentro
cd ~/Developer/MiApp
/ruta/al/template/scripts/new-project.sh . MiApp

# 3. Inicializá Spec Kit para Claude Code
specify init . --force --integration claude

# 4. Abrí Claude Code con el pipeline de modelos
claude --model opusplan        # Opus planifica, Sonnet ejecuta

# 5. Adentro de Claude Code, el ciclo SDD por cada feature:
/speckit.constitution          # solo la primera vez: revisá/ajustá la constitución
/speckit.specify Quiero una pantalla de onboarding con 3 pasos y...
/speckit.clarify               # Opus te hace las preguntas que faltan
/speckit.plan                  # plan técnico (frameworks, arquitectura)
/speckit.tasks                 # desglose en tareas chicas y verificables
/speckit.implement             # Sonnet implementa tarea por tarea (TDD)
/verify                       # corre gates objetivos y captura evidencia
/review                       # Opus revisa el diff con ojos frescos
/trust-report                 # resumen final de riesgo/evidencia para decidir
# → arreglás lo que marque el review, commit, y siguiente feature
```

### El layout de código fuente

Copiá el contenido de `SourceTemplate/` **adentro de la carpeta del target** que creó Xcode
(la que tiene el mismo nombre que tu app). Desde Xcode 16 los proyectos nuevos usan
*buildable folders* (carpetas sincronizadas): todo archivo que aparezca en el disco aparece
en Xcode automáticamente, sin tocar el `.pbxproj`. Eso es clave para que los agentes puedan
crear archivos sin romper nada.

```
MiApp/                        ← carpeta del target
├── App/                      ← MiAppApp.swift (el @main que generó Xcode va acá)
├── Features/
│   └── Onboarding/           ← una carpeta por feature
│       ├── OnboardingView.swift
│       └── OnboardingModel.swift    (@Observable)
├── Core/
│   ├── DesignSystem/         ← colores, tipografía, componentes reutilizables
│   ├── Networking/           ← cliente HTTP async/await
│   ├── Persistence/          ← modelos SwiftData
│   └── Extensions/
└── Resources/                ← Assets.xcassets, Localizable.xcstrings
```

Los tests van en los targets que Xcode ya creó (`MiAppTests/`, `MiAppUITests/`),
espejando la estructura de `Features/`. Mirá `Tests/ExampleFeatureTests.swift` como
referencia de Swift Testing.

---

## Upgrade path: sumar Codex como reviewer externo

Cuando tengas fluidez con este flujo y quieras una segunda opinión de otro proveedor
para merges importantes:

```bash
specify integration install codex   # agrega la integración de Spec Kit para Codex
```

Y usás Codex solo para la fase de review: le pedís que lea el spec + el diff y devuelva
hallazgos (en Codex los comandos son `$speckit-*` en vez de `/speckit.*`). El resto del
pipeline no cambia.

## Mantenimiento

- Los alias `opus` / `sonnet` siempre apuntan al modelo más nuevo → no hay que tocar nada.
- `specify` se actualiza con: `uv tool upgrade specify-cli`
- Claude Code se actualiza solo; forzalo con `claude update`
- Skills de Swift de la comunidad (muy recomendadas): repo **Swift Agent Skills** de
  Hacking with Swift (SwiftUI, SwiftData, Swift Concurrency, Swift Testing).

*Generado en julio 2026. Los comandos de herramientas de terceros (Spec Kit, MCPs) pueden
cambiar de sintaxis: ante la duda, `specify --help` y `claude /help` mandan.*
