@AGENTS.md

## Claude Code
- Sessão principal como tech lead: `claude --agent tech-lead` (ou `"agent": "tech-lead"` em settings). Subagentes não criam subagentes; toda delegação parte da sessão principal.
- Fluxo por skills: `/flow-plan` → `/flow-implement` → `/flow-verify` → `/flow-review` → `/flow-ship` (este último é manual).
- `/compact` deve preservar: `.harness/plan.md`, comando de verify e lista de arquivos alterados.
- Hooks ativos (guard, post-edit, stop-gate) e política de LSP/MCP: `docs/HOOKS-LSP-MCP.md`.
