---
name: flow-verify
description: "Collect fresh evidence that a change works. Use before completion when verification spans several checks, stacks, or ambiguous failures."
---

# Flow: Verify

1. Resolve the repository's intended checks from `HARNESS_VERIFY_CMD`, `.harness/verify.sh`, project docs/CI, or the changed ecosystem.
2. Run the narrowest deterministic checks that cover the diff first.
3. Widen to a full suite/build only when repository policy, CI parity, blast radius, or risk justifies it.
4. Keep verification in the main context for simple changes. Delegate to `verifier` only when verification is broad, cross-stack, long-running, or needs a clean independent evidence context.
5. On failure, return the exact command, exit code and relevant output to the owning context. Avoid repeated full-suite loops; re-run the smallest check that proves the fix, then widen once if needed.
6. Distinguish introduced failures from pre-existing ones.

Done means fresh evidence covers the changed behavior and there is no unexplained failure. Do not run unrelated suites merely to satisfy a generic checklist.
