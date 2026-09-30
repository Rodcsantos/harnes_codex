# Stack de Economia de Tokens

Objetivo: reduzir contexto e chamadas sem diminuir a capacidade de diagnosticar, editar e verificar corretamente. Economia de tokens só conta quando a taxa de acerto permanece estável.

## Princípio
A ordem padrão é **evidência mínima suficiente**. Não existe uma escada obrigatória de ferramentas.

1. `rg` / faixa de linhas / `git diff` / símbolo exato.
2. **Atlas OU SigMap** para orientar um repositório grande/desconhecido.
4. LSP/code intelligence/Serena quando navegação por símbolos ou referências evita leituras.
5. CLI direta ou ferramenta externa específica.
6. Leitura ampla somente quando a evidência estreita não basta.

## Ferramentas

| Ferramenta | Política | Melhor uso | Observação |
|---|---|---|---|
| RTK | manter | comprimir stdout ruidoso de testes, git, Docker, linters | use somente quando a saída compactada preserva a evidência necessária |
| ast-grep | manter | busca/reescrita estrutural local, rápida e determinística | zero schema/prompt permanente; use quando `rg` produzir ruído |\n| Atlas | sob demanda | mapa estrutural inicial de repo desconhecido, com budget pequeno | ainda é alpha; não injete mapa em toda tarefa |
| SigMap | sob demanda | busca estrutural/evidence pack determinístico e auditável | escolha em vez de Atlas quando a pergunta é por símbolos/evidência; não rode ambos por rotina |
| Serena | sob demanda | definição/referências/refactor semântico | maior custo operacional; vale quando grep/mapa não resolve |
| mcp2cli/mcpq | compatibilidade | clientes/servidores em que schemas MCP realmente ficam residentes | Claude Code já difere ferramentas MCP por padrão; não migrar MCPs do Claude automaticamente |
| Headroom | experimental | compressão adicional medida em workload próprio | não usar como wrapper global sem eval: Codex/Claude já têm compaction/cache e compressão pode ocultar detalhe |
| Tokview | observabilidade | descobrir onde tokens realmente são gastos | não economiza tokens sozinho |

Os percentuais publicados por projetos de terceiros são benchmarks dos próprios projetos. Antes de tornar qualquer ferramenta obrigatória, comparar em tarefas reais do harness: sucesso, tokens/contexto, número de turns, latência e retrabalho.

## Recursos nativos primeiro
- **Claude Code:** `/usage`, `/context`, `/clear` entre tarefas independentes, `/compact` com instruções úteis, MCP com tool definitions deferred por padrão, code-intelligence plugins e `/doctor prompt-audit`.
- **Codex/OpenAI:** contexto/compaction nativos, hooks com limite de contexto, multi-agent apenas para trabalho independente, e tool search/deferred definitions onde disponível.
- Skills/procedimentos: descrição curta; corpo só entra quando usado. Instale apenas os packs relevantes ao projeto sempre que possível.

## Instalação de skills
O repositório mantém todas as skills como fonte, mas a instalação deve ser seletiva por stack. Um projeto React não precisa pagar o listing de PostgreSQL, Redis, Django e PHP em toda sessão. O instalador aceita perfis; `all` existe para laboratórios e projetos realmente multi-stack.

## Medição
Antes/depois de cada mudança do harness, registre pelo menos:
- taxa de conclusão sem correção manual;
- tokens/contexto por tarefa;
- quantidade de tool calls/turns;
- tempo até primeira edição e até verificação;
- skills/agentes acionados;
- falhas por contexto ausente ou excessivamente comprimido.

A meta é menos contexto **por tarefa concluída**, não simplesmente menos tokens por request.
