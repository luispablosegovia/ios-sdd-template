---
description: Run the objective verification gate with the verifier agent
---

Use the **verifier** agent to verify the current working tree changes.

Context for the verifier: $ARGUMENTS

The verifier must run `bash scripts/verify.sh`, report exact command results, and
must not edit code. If verification fails or is incomplete, report the blocker
verbatim and stop.
