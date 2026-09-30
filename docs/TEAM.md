# Time de engenharia

Fonte única de agentes Codex: `specialists/agents/*.toml`. Os agentes Claude Code em `claude/agents/` são gerados por `scripts/build-claude-agents.py`; a CI deve falhar se houver drift.

## Agentes de processo
| Agente | Função | Escrita | Claude |
|---|---|---|---|
| tech_lead | coordena trabalho cross-stack/complexo | não | sonnet |
| explorer | responde uma pergunta de mapeamento | não | haiku |
| architect | decisões arquiteturais realmente complexas | não | opus |
| test_engineer | contexto separado para testes quando útil | testes | sonnet |
| verifier | verificação independente quando ampla/ambígua | caches | sonnet |
| reviewer | revisão independente de PR/risco | não | sonnet |
| security_reviewer | revisão de trust boundaries quando relevante | não | sonnet |

Sonnet é o padrão do Claude para engenharia. Opus fica reservado ao `architect` e pode ser escolhido manualmente quando uma decisão realmente exige raciocínio mais pesado. Times/subagentes multiplicam contexto, portanto não são um mecanismo padrão de qualidade.

## Especialistas de stack
`python_expert`, `django_expert`, `php_expert`, `react_expert`, `mysql_dba`, `postgresql_dba`, `redis_expert`, `infra_expert` e `fullstack_orchestrator`. Use apenas o domínio tocado.

## Roteamento adaptativo
### Rotina
Main agent -> skill/domínio mínimo -> edição -> verificação direcionada. Sem `explorer`, `architect`, `test_engineer`, `verifier` ou `reviewer` automáticos.

### Complexo
- `flow-plan` quando há múltiplas superfícies acopladas, arquitetura incerta ou risco de contrato.
- 1 `explorer` por incógnita concreta; paralelize somente perguntas independentes.
- `architect` apenas se existe decisão arquitetural/trade-off real.
- Plano curto em `.harness/plan.md`; implementação segue esse estado persistido.

### Alto risco / entrega
- `verifier` quando a validação envolve múltiplos stacks, CI ambígua ou falhas difíceis de atribuir.
- `reviewer` antes de PR/merge quando política do repo ou risco pede revisão independente.
- `security_reviewer` só quando o diff toca autenticação/autorização, entrada não confiável, segredos, dependências, SQL, arquivos, rede ou infraestrutura.
- `flow-ship` é manual.

## Regras de contexto
1. Delegue somente quando isolamento de contexto, especialização ou paralelismo superar o overhead do subagente.
2. `.harness/plan.md` guarda estado durável; não repita o plano no chat.
3. Conhecendo o local: `rg`/range/diff primeiro. Repo desconhecido: Atlas **ou** SigMap. Símbolos/referências: LSP/Serena.
4. CLI direta e descoberta deferred nativa antes de catálogos MCP residentes.
5. RTK em stdout ruidoso; diffs e arquivos alterados após edição.
6. `/clear` entre tarefas não relacionadas no Claude Code.
7. Cada agente recebe objetivo, escopo e saída curta; não recebe histórico irrelevante.


## Perfis do ciclo de vida

O catálogo fonte possui **42 agentes**, mas o default `--agents auto` instala somente:
`tech-lead`, `explorer`, `reviewer`, `verifier` + especialistas inferidos por `--skills`.

Perfis opcionais:
- `product`: product-manager, product-discovery, business-analyst, ux-ui-designer.
- `architecture`: architect, software-architect.
- `frontend`: react-expert, frontend-performance.
- `backend`: backend-engineer, api-integration.
- `mobile`: mobile-engineer.
- `data`: database-architect, database-performance, mysql-dba, postgresql-dba, redis-expert.
- `qa`: qa-architect, test-engineer, e2e-browser, performance-engineer.
- `security`: security-architect, security-reviewer, secops.
- `devops`: devops-engineer, platform-engineer, infra-expert, cloud-iac, kubernetes-engineer.
- `sre`: sre-engineer, observability-engineer, incident-rca.
- `delivery`: release-manager, documentation-agent.
- `dx`: developer-experience.
- `fullstack`: fullstack-orchestrator.

O catálogo funcional completo está em `docs/LIFECYCLE-AGENTS.md`. A existência de um perfil não significa que todos os agentes dele devam ser usados na mesma tarefa.
