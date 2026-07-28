---
description: Generate an AI Code Trust Report for the current diff
---

Generate a concise AI Code Trust Report for the current diff using the verifier
and reviewer evidence available in this session. If evidence is missing, say so
explicitly; do not infer success.

Use this structure:

```markdown
# AI Code Trust Report

- Feature/task:
- Risk level: low | medium | high
- Diff size:
- Files changed:
- Tests added:
- RED observed:
- GREEN observed:
- Full suite:
- Build:
- Lint/format:
- Secret scan:
- Dependency policy:
- Reviewer verdict:
- Human review required:
- Recommendation:
```

Risk classification must follow `docs/ai-code-trust-pipeline.md`.
