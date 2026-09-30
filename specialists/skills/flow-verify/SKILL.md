---
name: flow-verify
description: "Collect fresh evidence that a change works: lint, types, tests, build. Use before saying a task is done or before review."
---

# Flow: Verify

1. Delegate to `verifier`. It resolves the command from `HARNESS_VERIFY_CMD`, `.harness/verify.sh`, CI config or ecosystem defaults.
2. Narrow checks first (files in the diff), then the full suite.
3. On failure, hand the exact failing output to the owning specialist. Maximum 3 fix attempts, then escalate to the user with the evidence.
4. Distinguish failures introduced by the diff from pre-existing ones.

Done means: every check ran in this session, exit codes recorded, no unexplained failure. A summary without commands and exit codes is not evidence.
