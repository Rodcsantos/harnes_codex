# AGENTS.md

## Mission
This repository is the canonical source for the WSL + Codex/Claude development harness.

## Working rules
- Diagnose before changing and prefer root-cause fixes over symptom patches.
- Use the smallest relevant specialist/skill set; do not spawn agents or load procedures speculatively.
- Preserve project conventions unless evidence justifies a change.
- Never claim completion without fresh, relevant verification evidence.
- Keep repository reads and command output targeted.
- Never expose or commit credentials, tokens, private keys, .env secrets, production dumps, or personal data.

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

## Execution by risk
- **Routine/default:** keep the task in the main agent. Use one targeted domain skill or specialist only when it adds material value. Edit -> targeted verify -> done.
- **Complex:** use `flow-plan` when the change spans several coupled files, has unclear ownership, or requires a design trade-off. Spawn an `explorer` only for a specific unknown; use `architect` only when an architectural decision is actually required.
- **High-risk:** add independent review for schema/public API/auth/security/production-data/infra changes or before a PR when requested by policy. Security review is conditional on the touched trust boundary.
- Parallelize only independent, bounded work. Sequential or small work stays in the main context.
- Keep durable task state in `.harness/plan.md`, not repeated chat summaries.
- `flow-ship` is manual.

## Process agents
- tech_lead: decomposition/delegation for genuinely cross-cutting work; never edits.
- explorer: narrow read-only mapping.
- architect: read-only design choices, risks and rollback.
- test_engineer: tests only when a separate test context is useful.
- verifier: independent evidence for broad or ambiguous verification.
- reviewer/security_reviewer: independent, read-only, used conditionally.
- Delegations state goal, exact scope, expected output and a short word limit (normally <=200 words).

## Enforcement (hooks, not prose)
- Guard blocks destructive commands, force/main pushes and secret access; risky-but-legitimate commands require approval where the client supports it.
- Post-edit reports format/lint/syntax errors after edits.
- Stop gate runs only an explicitly configured project verify command (`HARNESS_VERIFY_CMD` or `.harness/verify.sh`); it must not invent and rerun a large test suite at every stop.

## Database safety
- Production database access is read-only by default.
- Never run DROP, TRUNCATE, destructive ALTER, bulk delete, failover, restore, role/privilege changes, or irreversible maintenance without explicit approval.
- Prefer EXPLAIN before EXPLAIN ANALYZE when execution risk is unknown.
- Every backup strategy includes restore verification. Replication is not a backup.

## Infrastructure safety
- Prefer inspect -> reproduce -> change -> validate -> rollback-ready.
- Never run destructive Docker/Kubernetes/Terraform/systemd/firewall operations without explicit approval when production impact is possible.
- Preserve working configuration before modifying it.

## Quality
- Follow actual project/runtime versions and repository-native tooling.
- Prefer deterministic tests, lint, type checks, builds and system checks that cover the changed behavior.
- Do not rewrite already-applied production migrations casually.
- Authentication is not authorization.
- Measure ORM/query/performance changes instead of guessing.

## Token-efficient context
1. If the location is known, start with `rg`, a narrow line range, `git diff`, or the exact symbol.
2. For an unfamiliar/large repository, use **Atlas or SigMap** to orient; do not run both by default. Keep the map/evidence budget small and focus it on the task.
3. Use LSP/code-intelligence or Serena when definition/reference/symbol-aware refactoring avoids multiple file reads.
4. Prefer native deferred tool discovery/tool search where the client supports it. Prefer a direct CLI over an MCP when it exposes the same operation compactly. Keep mcp2cli/mcpq only where native deferral is unavailable or measurably worse.
5. Read whole files or broad directories only when the narrower evidence cannot answer the question.
6. Treat subagents as a context-isolation/parallelism tool, not a default workflow: every subagent has its own context and consumes quota.
7. Use RTK for noisy command output when it preserves the evidence needed for the task.
8. After edits, reason from changed-file/diff context rather than re-reading the repository.

## Definition of done
Run only the checks relevant to the changed surface, widening from targeted checks to broader suites when risk justifies it. Completion requires fresh evidence for the behavior changed and no unexplained failures. Independent review/security review is required only when the risk, repository policy, or requested delivery stage calls for it.
