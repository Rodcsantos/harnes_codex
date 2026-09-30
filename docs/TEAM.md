# Time de engenharia

Fonte única: `specialists/agents/*.toml` (Codex). Os agentes do Claude Code em `claude/agents/` são **gerados** por `scripts/build-claude-agents.py` (a CI falha se divergirem).

## Agentes de processo
| Agente | Função | Escrita | Modelo (Claude) |
|---|---|---|---|
| tech_lead | decompõe, delega, sintetiza; não edita | não | opus |
| explorer | mapeia código; ≤150 palavras | não | haiku |
| architect | plano com opções, riscos, rollback | não | opus |
| test_engineer | teste que falha primeiro; só arquivos de teste | sim | sonnet |
| verifier | lint/types/testes/build com evidência | sim (caches) | sonnet |
| reviewer | revisão independente do diff | não | opus |
| security_reviewer | authn≠authz, injeção, segredos, deps, infra | não | opus |

## Especialistas de stack
python_expert, django_expert, php_expert, react_expert, mysql_dba, postgresql_dba, redis_expert, infra_expert, fullstack_orchestrator (cross-stack). Acionados só quando o domínio pesa.

## Fluxo (skills)
`flow-plan` → `flow-implement` → `flow-verify` → `flow-review` → `flow-ship`.
- Plan: explorers em paralelo → architect → `.harness/plan.md`.
- Implement: teste primeiro → especialista → hooks de pós-edição → marca passo.
- Verify: verifier; máx. 3 tentativas de correção, depois escala.
- Review: reviewer sempre; security_reviewer quando toca auth, entrada, segredos, deps, SQL ou infra; máx. 2 rodadas.
- Ship: manual; commit convencional; PR com evidência; nunca push em main.

## Regras de contexto
1. Delegar leitura pesada a subagentes: só o resumo volta para a sessão principal.
2. Plano em arquivo, não em conversa. `/clear` entre tarefas.
3. Ordem de busca: grep/range → Atlas → SigMap → LSP/Serena → MCP → leitura ampla.
4. Saídas de comando compactas (RTK) e hooks que só falam quando há erro.
