# Upstream Guidance Audit

Última revisão: **2026-09-30**.

Este arquivo registra quais recomendações oficiais justificam os defaults do harness. Ele existe para evitar que regras antigas virem "tradição" depois que Codex/Claude mudarem.

## OpenAI

- GPT-6 / model guidance: https://developers.openai.com/api/docs/guides/latest-model
- GPT-6 Luna: https://developers.openai.com/api/docs/models/gpt-6-luna
- Skills e prompts para GPT-6 Astra: https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra
- Tool search / deferred tool loading: https://developers.openai.com/api/docs/guides/tools-tool-search
- Multi-agent: https://developers.openai.com/api/docs/guides/agents-api/multi-agent
- Deployment checklist: https://developers.openai.com/api/docs/guides/deployment-checklist

### Decisões derivadas
- Skills têm descrição curta e específica; o catálogo global é seletivo por stack.
- `AGENTS.md` não obriga repo-map, documentação ampla ou pipeline completo antes de cada mudança.
- Luna é o default barato para tarefas focadas; Sol é reservado a coordenação/review/arquitetura mais exigentes.
- Subagentes são usados para trabalho independente e limitado. O harness limita concorrência padrão a 3.
- Verificação amplia de targeted para full suite conforme risco; full suite não roda automaticamente a cada Stop.
- Tool discovery deferred/nativa vem antes de wrappers que replicam schemas.
- Memória não é ligada pelo harness sem evidência de benefício.

## Anthropic / Claude Code

- Cost management: https://code.claude.com/docs/en/costs
- Skills: https://code.claude.com/docs/en/skills
- Memory / CLAUDE.md / rules: https://code.claude.com/docs/en/memory
- Feature/context model: https://code.claude.com/docs/en/features-overview

### Decisões derivadas
- Sonnet é o default dos subagentes Claude; Haiku atende exploração simples; Opus fica reservado a arquitetura realmente complexa.
- Equipes/subagentes permanecem pequenas porque cada agente mantém contexto próprio.
- `/clear` separa tarefas não relacionadas; `/compact` preserva somente estado útil da tarefa atual.
- MCP tool definitions já são deferred por padrão; mcp2cli não é migração automática no Claude.
- LSP/code intelligence é preferido quando reduz leituras repetidas.
- `CLAUDE.md` permanece curto; material ocasional fica em skill/rule sob demanda.

## Ferramentas externas

Ferramentas externas são avaliadas pelo impacto **por tarefa concluída**, não pelo percentual promocional de economia.

| Ferramenta | Status | Motivo |
|---|---|---|
| RTK | default | compacta stdout de comandos e tem integração nativa por hook com Codex |
| ast-grep | default | busca/rewrite estrutural local sem schema ou prompt permanente |
| Atlas | on-demand | mapa de repo com budget; útil para orientação inicial |
| SigMap | on-demand | signatures/evidence quando um mapa completo seria excesso |
| Serena | on-demand | navegação/refactor semântico quando busca estrutural não basta |
| mcp2cli/mcpq | compatibilidade | usar somente quando um MCP realmente gera overhead que a descoberta nativa não resolve |
| Headroom | experimental | compressão extra pode omitir evidência; exige A/B/eval antes de virar wrapper padrão |
| Tokview | observabilidade | mede consumo; não é mecanismo de economia por si só |

Claims de economia publicados por ferramentas de terceiros são tratados como benchmarks dos próprios projetos até serem reproduzidos no workload deste harness.

## Critério de reavaliação

Ao alterar um default, comparar em tarefas representativas:
1. conclusão correta sem correção manual;
2. tokens/contexto consumidos;
3. número de turns/tool calls;
4. latência até primeira edição e até evidência final;
5. retrabalho por contexto ausente ou comprimido;
6. quantidade de skills/agentes carregados/acionados.

Se uma otimização reduz tokens mas piora sucesso/retrabalho, ela não é uma otimização do harness.
