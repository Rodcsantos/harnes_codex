# AGENTS.md

## Mission
This repository is the canonical source for the WSL + Codex development harness.

## Working rules
- Diagnose before changing.
- Prefer root-cause fixes over symptom patches.
- Use the smallest relevant specialist/skill set.
- Preserve existing project conventions unless there is a concrete reason to change them.
- Never claim completion without fresh verification evidence.
- Keep repository reads and command output targeted.
- Never commit credentials, tokens, private keys, .env secrets, production dumps, or personal data.

## Specialist routing
- Python: python_expert
- Django: django_expert
- PHP: php_expert
- React/TypeScript: react_expert
- MySQL/InnoDB: mysql_dba
- PostgreSQL: postgresql_dba
- Redis: redis_expert
- Infrastructure/containers/proxy/Linux/observability: infra_expert
- Cross-stack work: fullstack_orchestrator

Do not spawn every specialist by default. Delegate only when the domain materially benefits.

## Engineering team and flow
- Process agents: tech_lead (plans/delegates, never edits), explorer (read-only map), architect (read-only plan), test_engineer (tests only), verifier (evidence), reviewer and security_reviewer (independent, read-only).
- Default flow for non-trivial work: flow-plan -> flow-implement -> flow-verify -> flow-review -> flow-ship (manual).
- Keep the plan in `.harness/plan.md` instead of chat history. Delegations state goal, scope, output format and a word limit (default 200 words).
- Trivial edits (one file, no design risk) skip the flow: edit, verify, done.

## Enforcement (hooks, not prose)
- Guard blocks destructive commands, force/main pushes and secret access; risky-but-legit commands ask for approval.
- Post-edit reports format/lint/syntax errors right after each edit. Stop gate refuses to finish while the verify command fails.
- Project verify command: `HARNESS_VERIFY_CMD` or `.harness/verify.sh`.

## Database safety
- Production database access is read-only by default.
- Never run DROP, TRUNCATE, destructive ALTER, bulk delete, failover, restore, role/privilege changes, or irreversible maintenance without explicit approval.
- Prefer EXPLAIN before EXPLAIN ANALYZE when execution risk is unknown.
- Every backup strategy must include restore verification.
- Replication is not a backup.

## Infrastructure safety
- Prefer inspect -> reproduce -> change -> validate -> rollback-ready.
- Never run destructive Docker/Kubernetes/Terraform/systemd/firewall operations without explicit approval when production impact is possible.
- Preserve working configuration before modifying it.

## Quality
- Follow actual project/runtime versions.
- Prefer deterministic tests, lint, type checks, builds and system checks.
- Do not rewrite already-applied production migrations casually.
- Authentication is not authorization.
- Measure ORM/query changes instead of guessing.

## Token-efficient workflow
- Prefer RTK-compatible compact commands.
- Use Atlas for repo orientation when needed.
- Use SigMap when signatures/evidence can replace whole-file reads.
- Use Serena only for semantic navigation/refactoring that grep/signatures cannot answer.
- Keep local stdio MCP discovery lazy through mcp2cli/mcpq where configured.
- Prefer diffs and changed-file context after edits.

## Definition of done
A task is complete only after the relevant tests, lint/format, type checks, builds/system checks, database validation, security review and diff review have fresh evidence with no unexplained failures.