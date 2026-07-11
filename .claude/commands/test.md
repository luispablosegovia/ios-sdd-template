---
description: Run the full test suite and report results
---

Run the complete test suite for this project. Prefer the XcodeBuildMCP test
tools; if unavailable, use:

xcodebuild -scheme <scheme> -destination 'platform=iOS Simulator,name=<newest iPhone>' test 2>&1 | xcbeautify

If any test fails: show the failing test names and assertion messages, explain
the likely cause, and propose a fix — but do NOT change code until I confirm.
If all pass, give me the one-line summary only.
