---
name: postgres-memory-connections
description: "Reason about shared_buffers, work_mem, maintenance memory, sessions, and pooling limits. Use when work involves postgresql memory and connections."
---

# PostgreSQL Memory and Connections

Reason about shared_buffers, work_mem, maintenance memory, sessions, and pooling limits.

## Domain rules
Assume production data safety matters. Use actual plans/statistics/waits before tuning and never execute destructive or disruptive operations without explicit approval.

## Workflow
1. Inspect the repository/runtime version and existing conventions before proposing changes.
2. Gather direct evidence relevant to this topic; do not infer from naming alone.
3. State the failure mode or design goal in concrete terms.
4. Make the smallest defensible change that addresses the root cause.
5. Validate with the most targeted reliable checks, then broaden only when needed.
6. Report evidence, changes, validation, remaining risk, and version-sensitive assumptions.

## Focus checks
- account for work_mem multiplication.
- separate DB RAM from OS cache.
- control connection storms.
- use pooling when architecture needs it.

## Guardrails
- Do not broaden the task into unrelated modernization.
- Prefer measured evidence and repository-native tooling over generic advice.
- Preserve public contracts unless the requested change requires otherwise.
- For destructive, irreversible, privilege-changing, or production-disruptive actions, stop and request explicit approval.
- If behavior depends on a library/database/runtime version, verify that version before relying on version-specific behavior.

## Output expectation
Return a concise engineering result: root cause or design decision, exact files/objects affected, commands/tests run, observed outcome, and remaining risks.
