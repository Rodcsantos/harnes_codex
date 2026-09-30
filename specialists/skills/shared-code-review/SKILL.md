---
name: shared-code-review
description: "Review a code change for correctness, regressions, security, maintainability and missing tests using the diff and surrounding code. Use when asked to review a PR or diff, or before merging your own work."
---

# Code Review

## Use when
- A diff, branch or PR needs an independent review with prioritized findings.

## Diagnose first
- Get the exact scope: `git diff --stat <base>...HEAD` then `git diff <base>...HEAD -- <file>`; read the commit messages and linked issue for intent.
- Read the surrounding code of each changed function (callers, callees, invariants) before judging it.
- Run or read the checks: tests, linters, type checks, CI results; note what the diff changes in tests.
- Identify risky areas: auth, money, migrations, concurrency, public API, config, dependencies.

## Decision rules
- Verify claims by reading code and running checks; do not trust descriptions.
- Findings need file:line, the failure scenario, and a concrete fix; classify MUST-FIX (bug, security, data loss, contract break), SHOULD-FIX, NIT.
- Look specifically for: unhandled errors and edge cases (empty, null, large, concurrent), wrong assumptions, race conditions, transaction boundaries, backward compatibility, migrations safety, N+1 and unbounded work, secrets and logging of sensitive data, missing or weak tests.
- Skip what a formatter or linter enforces. Do not request unrelated refactors or scope creep.
- Say what you did not review or could not verify.
- End with a verdict: approve, approve with nits, or changes required, listing the blocking items.

## Anti-patterns
- Style-only reviews; approving because tests pass without reading the change; vague comments ("consider improving"); rewriting the author's approach without a concrete defect.

## Safety
Review is read-only: do not modify the branch, force-push, or merge as part of a review unless explicitly asked.

## Verify
- Each MUST-FIX has a reproducible scenario or evidence; after fixes, re-check only the changed hunks and confirm the original finding is resolved.
