# __APP_NAME__ — Project Context for Claude Code

<!-- Este archivo lo lee Claude Code al inicio de CADA sesión.
     Mantenelo corto, preciso y actualizado. Está en inglés porque el
     ecosistema de skills/ejemplos lo está; traducilo si preferís. -->

## Overview

__APP_NAME__ is an iOS app built with the latest Apple frameworks.
One-line description: <completar: qué hace la app y para quién>.

## Tech stack (non-negotiable — see .specify/memory/constitution.md)

- Swift 6.x with **strict concurrency** enabled. Latest stable SDK.
- **SwiftUI** for all UI. UIKit only via representables when SwiftUI truly cannot do it.
- **SwiftData** for persistence (never Core Data in new code).
- **Swift Testing** (`import Testing`, `@Test`, `#expect`, `@Suite`) for unit tests.
  XCTest only for UI tests (XCUITest), which has no Swift Testing equivalent yet.
- **@Observable** macro for view models / state (never ObservableObject).
- **async/await** + actors for all asynchrony (no completion handlers, no Combine in new code).
- Dependencies via **Swift Package Manager only**. Prefer Apple frameworks over third-party.
- Min deployment target: latest major iOS unless the spec says otherwise.

## Commands

```bash
# Build (always pipe through xcbeautify to keep output readable)
xcodebuild -scheme __APP_NAME__ -destination 'platform=iOS Simulator,name=iPhone 17' build 2>&1 | xcbeautify

# Full test suite (unit + UI)
xcodebuild -scheme __APP_NAME__ -destination 'platform=iOS Simulator,name=iPhone 17' test 2>&1 | xcbeautify

# Single test (Swift Testing): prefer running via the XcodeBuildMCP test tools
# Verify all trust gates before review/commit
bash scripts/verify.sh

# Install local git safety hooks
bash scripts/install-git-hooks.sh
```

Prefer the **XcodeBuildMCP tools** (build, run tests, boot simulator, capture
screenshots, read runtime logs) over raw shell commands when available.
If a simulator named "iPhone 17" doesn't exist, list simulators first and pick
the newest iPhone.

## Architecture

- `App/` — entry point (`@main`), app-level configuration, environment setup.
- `Features/<FeatureName>/` — one folder per feature: `<Feature>View.swift`,
  `<Feature>Model.swift` (@Observable). Views stay dumb; logic lives in models.
- `Core/DesignSystem/` — colors, typography, reusable components. Always use these
  instead of hardcoding styles.
- `Core/Networking/` — async/await HTTP client. `Core/Persistence/` — SwiftData models.
- Tests mirror `Features/` structure in the test target.
- This project uses **Xcode buildable folders**: creating a file on disk adds it to
  the project automatically. **NEVER edit `project.pbxproj` directly** (a hook blocks it).

## Workflow (Spec Driven Development)

- Specs live in `specs/NNN-feature-name/` (spec.md, plan.md, tasks.md) — managed by Spec Kit.
- The spec is the source of truth. If reality diverges, update the spec first.
- Flow per feature: `/speckit.specify` → `/speckit.clarify` → `/speckit.plan` →
  `/speckit.tasks` → `/speckit.implement` → `/verify` → `/review` → `/trust-report`.
- Planning/spec phases: use the `planner` agent (Opus). Implementation: `implementer`
  agent (Sonnet), ONE task at a time. After each task: `/verify` (objective gates),
  then `/review` (reviewer agent, Opus), then `/trust-report` for human approval.
- **TDD**: every task starts with a failing test. No task is done until RED/GREEN
  evidence exists, the full suite passes, `scripts/verify.sh` passes, and lint is clean.

## Style rules

- Small, single-purpose types. Prefer structs; classes only when reference
  semantics or @Observable requires it.
- No force unwraps (`!`) outside tests. No `print` — use `os.Logger`.
- Every user-facing string goes through the String Catalog (localizable).
- Every interactive element gets an accessibility label; support Dynamic Type.
- Public types/functions in Core/ get a doc comment (///).

## Do NOT use (legacy — will fail review)

ObservableObject / @Published / @StateObject (use @Observable + @State),
Core Data, XCTest for unit tests, completion handlers, DispatchQueue for new
async work, Storyboards/XIBs, CocoaPods/Carthage, singletons for new services
(use environment injection).
