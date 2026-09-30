---
name: flow-review
description: "Run an independent diff review when risk or delivery stage justifies it. Use for PR/merge review, high-risk changes, or when repository policy requires an independent reviewer."
---

# Flow: Review

1. Compute the exact diff range and provide reviewers only that diff plus the minimum surrounding code needed.
2. Use `reviewer` for PR/merge or high-risk correctness review. Do not create an independent reviewer for every routine local edit.
3. Add `security_reviewer` only when the diff touches a trust boundary: auth/authz, untrusted input, secrets, dependencies, SQL, filesystem/network access, uploads or infrastructure.
4. Independent read-only reviews may run in parallel because their scopes do not overlap.
5. MUST-FIX items go back to the owning context; re-run the smallest verification covering the fix and re-review only changed hunks.
6. Cap review loops at two rounds.

Output only evidence-backed findings and a compact verdict. Ignore formatting/style noise enforced deterministically.
