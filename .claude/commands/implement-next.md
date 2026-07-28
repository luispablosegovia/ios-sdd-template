---
description: Implement exactly one unchecked SDD task using strict TDD
---

Use the **implementer** agent to implement exactly one task from the feature in:

```text
$ARGUMENTS
```

If `$ARGUMENTS` is a feature directory, inspect its `spec.md`, `plan.md`, and
`tasks.md`, then choose the next unchecked task in order. If `$ARGUMENTS` names a
specific task, implement only that task.

Hard rules for the implementer:

1. Read `.specify/memory/constitution.md`, `CLAUDE.md`, and the feature's
   `spec.md`, `plan.md`, and `tasks.md` before editing.
2. Implement exactly one task. Do not advance to the next task.
3. Follow strict TDD:
   - write one Swift Testing test first;
   - run the specific test and capture the expected RED failure;
   - write the minimum production code required;
   - run the specific test again and capture GREEN;
   - run the full suite;
   - run `bash scripts/verify.sh`.
4. Do not widen scope, do drive-by refactors, or touch `.xcodeproj` for routine
   file additions.
5. If the task is medium/high risk, write evidence to:

```text
specs/<NNN-feature>/evidence/<task-id>.md
```

Use `specs/evidence/README.md` as the evidence template.

When finished, report:

- task id and title;
- files changed;
- tests added;
- RED command + observed failure;
- GREEN command + observed pass;
- full-suite result;
- `bash scripts/verify.sh` result;
- evidence file path, if applicable;
- whether `/review` should inspect any specific risk.

If RED evidence cannot be produced for a behavior change, stop and mark the task
incomplete rather than claiming success.
