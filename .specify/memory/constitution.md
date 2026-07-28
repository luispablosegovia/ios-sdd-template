# __APP_NAME__ Constitution

<!-- Spec Kit valida cada spec, plan y tarea contra este documento.
     Cambios acá requieren tu aprobación explícita como dueño del proyecto. -->

## Core Principles

### I. Latest Frameworks Only (NON-NEGOTIABLE)

All code targets the latest stable Swift toolchain and iOS SDK with strict
concurrency enabled. UI is SwiftUI. Persistence is SwiftData. State uses the
@Observable macro. Asynchrony uses async/await and actors. Legacy patterns
(ObservableObject, Core Data, Combine for new async work, completion handlers,
UIKit-first screens, Storyboards) are forbidden in new code. When Apple ships a
modern replacement for an API this project uses, the plan for the next feature
must evaluate adopting it.

### II. Test-First (NON-NEGOTIABLE)

Every task begins with a failing test written in Swift Testing (`@Test`,
`#expect`). Implementation follows red → green → refactor. A task is complete
only when: the new tests pass, the full existing suite passes, and lint/format
are clean. Business logic lives in @Observable models and Core/ services so it
is testable without UI. Critical user flows get XCUITest coverage.

### III. Spec Before Code

No implementation without an approved spec in `specs/`. The spec captures WHAT
and WHY (user-facing behavior, acceptance criteria); the plan captures HOW
(frameworks, architecture); tasks are small, ordered, independently verifiable.
Ambiguity is resolved in `/speckit.clarify`, never improvised mid-implementation.
If implementation reveals the spec was wrong, stop and amend the spec first.

### IV. Simplicity & Apple-Native First

Start with the simplest design that satisfies the spec. No speculative
abstractions, no protocol soup, no third-party dependency when an Apple
framework does the job. Any new dependency requires an ADR in `docs/decisions/`
justifying it, and must come via Swift Package Manager.

### V. Accessibility & Localization Are Features, Not Chores

Every interactive element ships with accessibility labels/traits and supports
Dynamic Type. Every user-facing string lives in the String Catalog from day
one. Reviews reject code that fails either.

### VI. Privacy by Default

Collect the minimum data needed. No third-party tracking. Any data leaving the
device must be listed in the spec and justified. Secrets never live in the
repo or in code.

### VII. AI-Generated Code Trust Gates (NON-NEGOTIABLE)

AI-generated code is not accepted because it looks plausible. It must pass
objective verification. Every completed implementation task must produce: RED
command and expected failure output, GREEN command and passing output, full-suite
result, lint/format result, `scripts/verify.sh` result, fresh-context reviewer
verdict, and a short trust report. Missing evidence means the task is incomplete.

High-risk changes require explicit human review of the spec, critical tests, and
selected diff: security/privacy, networking/sync/export, permissions, payments,
Keychain/secrets/authentication, user-data deletion, SwiftData migrations, new
third-party dependencies, broad architecture changes, concurrency architecture,
and critical engineering formulas.

## Quality Gates

Before any merge: `bash scripts/verify.sh` green or green-with-explained-template
warnings, `xcodebuild test` green when an Xcode project is present, SwiftLint and
SwiftFormat clean, `/verify` evidence captured, `/review` (reviewer agent)
findings addressed, `/trust-report` generated, spec acceptance criteria checked
off.

## Governance

This constitution supersedes ad-hoc instructions in chat. The planner agent
must flag any spec/plan that conflicts with it. Amendments require the project
owner's explicit approval and a dated entry below.

**Version**: 1.0.0 | **Ratified**: <fecha> | **Last Amended**: <fecha>
