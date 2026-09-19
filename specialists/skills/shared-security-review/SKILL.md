---
name: shared-security-review
description: "Review trust boundaries using practical OWASP-style threat paths without generic checklist noise. Use when work involves application security review."
---

# Application Security Review

Review trust boundaries using practical OWASP-style threat paths without generic checklist noise.

## Domain rules
Apply this skill across stacks while preserving the repository architecture and user-requested scope.

## Workflow
1. Inspect the repository/runtime version and existing conventions before proposing changes.
2. Gather direct evidence relevant to this topic; do not infer from naming alone.
3. State the failure mode or design goal in concrete terms.
4. Make the smallest defensible change that addresses the root cause.
5. Validate with the most targeted reliable checks, then broaden only when needed.
6. Report evidence, changes, validation, remaining risk, and version-sensitive assumptions.

## Focus checks
- identify assets/actors.
- trace untrusted inputs.
- verify authz server-side.
- prioritize exploitable paths.

## Guardrails
- Do not broaden the task into unrelated modernization.
- Prefer measured evidence and repository-native tooling over generic advice.
- Preserve public contracts unless the requested change requires otherwise.
- For destructive, irreversible, privilege-changing, or production-disruptive actions, stop and request explicit approval.
- If behavior depends on a library/database/runtime version, verify that version before relying on version-specific behavior.

## Output expectation
Return a concise engineering result: root cause or design decision, exact files/objects affected, commands/tests run, observed outcome, and remaining risks.
