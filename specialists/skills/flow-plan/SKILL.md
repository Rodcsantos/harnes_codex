---
name: flow-plan
description: "Plan a complex or risky change before editing. Use when several coupled files, unclear ownership, architecture trade-offs, public contracts, schema, auth, production data or infrastructure make direct implementation unsafe."
---

# Flow: Plan

Goal: create the smallest executable plan that removes uncertainty without paying for an agent pipeline by default.

1. **Inspect narrowly in the main context** — start from the exact request, known files/symbols, `rg`, diffs, and nearby conventions.
2. **Map only unknowns** — delegate one `explorer` per concrete unanswered question. Use 2 in parallel only when the questions are independent; do not spawn explorers for facts already known.
3. **Design only when needed** — use `architect` only if there is a real architecture/trade-off decision. Otherwise the main agent chooses the smallest repository-native approach.
4. **Persist** — write `.harness/plan.md` from the template. Keep it under 50 lines and include only goal, constraints, steps, risk/rollback and verify command.
5. **Gate** — ask for approval only for decisions that change scope, schema/public API/auth, production data/infra or another irreversible contract. Otherwise continue.

Do not re-read material already captured in the plan. Do not create a planning subagent merely because more than one file changes.
