---
name: flow-plan
description: "Plan a non-trivial change before any edit: map the code, choose an approach, write .harness/plan.md. Use when a task touches more than one file or has design risk."
---

# Flow: Plan

Goal: a short, executable plan on disk, so later stages need no long chat history.

1. **Map** - delegate 1-3 parallel `explorer` tasks with narrow questions (entry points, callers, conventions). Word limit 150 each.
2. **Design** - delegate to `architect` with the explorer findings. Expect goal, options (max 3), steps (max 7), tests, risks, rollback, verify command.
3. **Persist** - write `.harness/plan.md` from `templates/project/.harness/plan.template.md` (copy the structure, keep it under 60 lines).
4. **Gate** - ask the user to approve only when the plan touches schema, public API, auth, production data or infrastructure. Otherwise proceed to `flow-implement`.

Do not edit source files in this stage.
