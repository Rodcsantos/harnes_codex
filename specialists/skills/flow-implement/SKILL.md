---
name: flow-implement
description: "Execute an existing .harness/plan.md with minimal diffs. Use after flow-plan or when a plan file already exists."
---

# Flow: Implement

Read `.harness/plan.md` once and execute from it; do not re-explore answered questions.

For each step:
1. Use the main agent or the one owning specialist. Do not create a separate specialist when the main context already has the necessary domain knowledge.
2. For a bug, establish a failing regression test when practical. A separate `test_engineer` is optional and is useful only when isolated test design materially improves confidence or can run independently.
3. Make the smallest change that satisfies the step and keep related edits together.
4. Let post-edit hooks catch cheap syntax/lint errors; fix them before broadening verification.
5. Tick the step in `.harness/plan.md`.

Rules: never run two agents on overlapping files; do not broaden scope; if evidence contradicts the plan, update only the affected plan item instead of restarting discovery.
