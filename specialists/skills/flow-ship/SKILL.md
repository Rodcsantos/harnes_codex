---
name: flow-ship
description: "Prepare commit and pull request after verify and review are green. Manual only; never pushes to main."
disable-model-invocation: true
---

# Flow: Ship

Preconditions: `flow-verify` green and `flow-review` without open MUST-FIX. If either is missing, stop and say which.

1. Stage only intended files; show `git status -s` and `git diff --stat`.
2. Conventional commit message (`feat:`, `fix:`, `refactor:`, ...) explaining why, not what.
3. PR body: summary, plan link, evidence table (command, exit code), review verdict, risk and rollback.
4. Ask for explicit approval before any `git push`. Never force-push and never push directly to main or master.
