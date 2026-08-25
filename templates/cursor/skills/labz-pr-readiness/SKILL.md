---
name: labz-pr-readiness
description: Assess whether a change is ready for pull request review. Use when preparing, checking, or summarizing a pull request or branch.
---

# Pull request readiness

1. Read repository guidance, the request, status, and the complete diff.
2. Verify the change is focused and remove unrelated or accidental output.
3. Check correctness, failure modes, security, compatibility, rollout, and
   documentation impact.
4. Confirm bug fixes include practical regression coverage.
5. Run applicable format, lint, typecheck, test, dead-code, package/artifact,
   and build commands. Do not weaken checks to pass.
6. Report exact commands and results, plus anything not run and why.
7. Summarize purpose, meaningful changes, risk, and remaining uncertainty.

Treat CI as evidence rather than proof. Do not commit, push, open a pull
request, post comments, or perform other external writes unless authorized.
