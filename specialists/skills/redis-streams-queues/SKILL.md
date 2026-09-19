---
name: redis-streams-queues
description: "Design Streams/consumer groups, retries, pending entries, idempotency, and poison handling. Use when work involves redis streams and queues."
---

# Redis Streams and Queues

Design Streams/consumer groups, retries, pending entries, idempotency, and poison handling.

## Domain rules
Assume production safety and latency matter. Prefer bounded SCAN/sampling; never use destructive global commands without explicit approval.

## Workflow
1. Inspect the repository/runtime version and existing conventions before proposing changes.
2. Gather direct evidence relevant to this topic; do not infer from naming alone.
3. State the failure mode or design goal in concrete terms.
4. Make the smallest defensible change that addresses the root cause.
5. Validate with the most targeted reliable checks, then broaden only when needed.
6. Report evidence, changes, validation, remaining risk, and version-sensitive assumptions.

## Focus checks
- inspect PEL.
- define retry/dead-letter strategy.
- make consumers idempotent.
- monitor lag/backlog.

## Guardrails
- Do not broaden the task into unrelated modernization.
- Prefer measured evidence and repository-native tooling over generic advice.
- Preserve public contracts unless the requested change requires otherwise.
- For destructive, irreversible, privilege-changing, or production-disruptive actions, stop and request explicit approval.
- If behavior depends on a library/database/runtime version, verify that version before relying on version-specific behavior.

## Output expectation
Return a concise engineering result: root cause or design decision, exact files/objects affected, commands/tests run, observed outcome, and remaining risks.
