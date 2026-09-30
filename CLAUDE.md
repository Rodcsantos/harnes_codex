@AGENTS.md

## Claude Code
- Use the normal main session for routine work. Start with `claude --agent tech-lead` only for genuinely complex/cross-stack coordination where delegation is expected to pay for itself.
- Flows are adaptive, not a mandatory chain: use `/flow-plan` for complex/risky planning, `/flow-implement` for an existing plan, `/flow-verify` for broad verification, `/flow-review` for PR/high-risk independent review, and `/flow-ship` manually.
- Subagents have independent context and consume quota. Keep them narrow; Sonnet is the default, Haiku for exploration, Opus only for architecture that needs it.
- Use `/clear` between unrelated tasks. Use `/compact` when continuing the same task; preserve only durable state such as `.harness/plan.md`, verify command, changed files and unresolved decisions.
- Use `/context`/`/usage` to identify real context/cota hotspots instead of assuming.
- Hooks, LSP/code-intelligence and MCP policy: `docs/HOOKS-LSP-MCP.md`.
