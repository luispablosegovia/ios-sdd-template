# Task Evidence

For medium/high-risk tasks, keep a small audit trail under the feature directory:

```text
specs/001-feature/evidence/T003.md
```

Use this template:

```markdown
# Evidence — <task id>

- Feature/task:
- Risk level: low | medium | high
- RED command:
- RED observed failure:
- GREEN command:
- GREEN observed pass:
- Full suite:
- Build:
- Lint / format:
- Secret scan:
- Dependency policy:
- Reviewer verdict:
- Human review required:
- Commit:
```

Evidence is required for high-risk changes and recommended for medium-risk changes. High-risk examples include security/privacy, networking/sync/export, permissions, Keychain/authentication, user-data deletion, SwiftData migrations, dependencies, broad architecture, concurrency architecture, and critical engineering formulas.
