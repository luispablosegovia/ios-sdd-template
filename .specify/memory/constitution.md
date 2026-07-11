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

## Quality Gates

Before any merge: `xcodebuild test` green, SwiftLint clean, `/review` (reviewer
agent) findings addressed, spec acceptance criteria checked off.

## Governance

This constitution supersedes ad-hoc instructions in chat. The planner agent
must flag any spec/plan that conflicts with it. Amendments require the project
owner's explicit approval and a dated entry below.

**Version**: 1.0.0 | **Ratified**: <fecha> | **Last Amended**: <fecha>
