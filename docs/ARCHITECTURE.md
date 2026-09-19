# Arquitetura do Harness

WSL -> Codex CLI -> policy + specialists + skills + MCP + hooks + CLI diagnostics + memory.

## Responsabilidades
- AGENTS.md: regras estáveis e normativas.
- Agents: especialistas com escopo e guardrails.
- Skills: procedimentos específicos carregados sob demanda.
- MCP: capacidades/contexto externo; não duplicar shell/filesystem/git local sem necessidade.
- Hooks e CI: enforcement determinístico.
- LSP/CLI diagnostics: semântica, lint, type checking e testes.
- Memory: contexto persistente útil, nunca a única fonte de políticas críticas.

## Fluxo
pedido -> classificar domínio -> especialista mínimo -> evidência -> hipótese/design -> mudança focada -> validação -> diff/review -> conclusão com evidência.

## Produção
Produção privilegia inspeção read-only, dry-run, backup, rollback e aprovação explícita para operações destrutivas.