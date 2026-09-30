---
name: flow-implement
description: "Execute an approved .harness/plan.md step by step with tests first and minimal diffs. Use after flow-plan or when a plan file already exists."
---

# Flow: Implement

Read `.harness/plan.md` first; do not re-explore what it already answers.

For each step, in order:
1. `test_engineer` writes the failing test (bugs) or the behavior test (features) and shows the run.
2. The owning specialist (`python_expert`, `django_expert`, `react_expert`, DBA, ...) makes the smallest change that turns it green.
3. Post-edit hooks report lint/format/syntax errors; fix them before moving on.
4. Tick the step in `.harness/plan.md`.

Rules: never run two agents on overlapping files; keep each step commit-sized; if reality contradicts the plan, stop and update the plan instead of improvising; do not broaden scope.
