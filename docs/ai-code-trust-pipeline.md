# AI Code Trust Pipeline

This project treats AI-generated code as untrusted until it passes objective,
repeatable verification. The goal is not to eliminate human judgment; it is to
move human attention from line-by-line inspection to evidence, risk, and product
intent.

## Core principle

Do not trust the generator. Trust the verification process.

A task is accepted only when the change is small, spec-aligned, tested, checked
by deterministic tools, and reviewed from a fresh context.

## Pipeline

1. **Spec** — user-facing behavior, acceptance criteria, non-goals, edge cases.
2. **Plan** — Apple-native APIs, architecture, data model, test strategy, risks.
3. **Tasks** — small vertical slices, each with a test-first done condition.
4. **Implement** — one task at a time, strict RED → GREEN → REFACTOR.
5. **Verify** — run `bash scripts/verify.sh`; fail closed on missing evidence.
6. **Review** — fresh-context reviewer checks spec compliance, tests, security,
   architecture, accessibility, localization, and privacy.
7. **Trust report** — summarize evidence and risk for human approval.
8. **Commit/merge** — only green, reviewed vertical slices.

## Required evidence per implemented task

- RED command and observed failure for the expected reason.
- GREEN command and observed pass.
- Full test-suite result.
- Build result when an Xcode project is present.
- SwiftFormat/SwiftLint result.
- Secret scan result.
- Dependency policy result.
- Reviewer verdict.

If evidence is missing, the task is incomplete even if the code looks correct.

For medium/high-risk work, persist this evidence in `specs/<NNN-feature>/evidence/<task-id>.md` so CI/reviewers and future sessions can audit the claim instead of relying only on chat history.

## Risk classification

### Low risk

Usually eligible for automated gates + reviewer + brief human report:

- copy/text changes;
- isolated visual-only SwiftUI adjustments;
- tests only;
- formatting;
- small refactor with unchanged behavior and existing tests.

### Medium risk

Requires reading the trust report and spot-checking relevant tests/specs:

- new SwiftUI feature;
- new `@Observable` feature model;
- SwiftData model or simple persistence flow;
- navigation changes;
- validation logic;
- non-critical calculations;
- localized input/output handling.

### High risk

Requires explicit human review of the spec, critical tests, and selected diff:

- security/privacy-sensitive code;
- new permissions or `Info.plist` privacy keys;
- networking, sync, analytics, or data export;
- Keychain/secrets/authentication;
- deletion of user data;
- SwiftData migrations;
- payment/subscription code;
- new third-party dependency;
- broad architecture change;
- concurrency architecture or shared mutable state;
- critical engineering formulas.

## Hard gates

The change is rejected if any of these occur:

- production code without RED evidence for behavior changes;
- failing build/tests/lint without documented owner-approved exception;
- `project.pbxproj` or `.xcodeproj` edited directly without a numbered ADR, explicit `ALLOW_XCODEPROJ_CHANGE=1`, and human review;
- possible hardcoded secret;
- dependency files changed without an ADR;
- reviewer reports security concerns or logic errors;
- diff too large for routine review without human approval;
- spec acceptance criteria not addressed.

## Human review focus

Humans should review:

1. Is the spec the right product behavior?
2. Are the critical tests meaningful?
3. Does the architecture decision make sense?
4. Did the trust report pass without gaps?
5. Is the risk classification honest?

Humans do not need to read every line for low-risk changes with strong evidence.
