# Hooks, LSP e MCP

## Hooks (`hooks/`, instalados em `~/.harness/hooks`)
| Evento | Script | Faz | Desliga |
|---|---|---|---|
| SessionStart | session_start.py | injeta só branch, dirty status e resumo do plano ativo; no Codex o bloco adicional é limitado | — |
| PreToolUse | guard.py | bloqueia operações destrutivas, push direto em main/master e leitura de segredos | `HARNESS_GUARD=off` |
| PostToolUse | post_edit.py | formata/checa somente o arquivo editado; fica silencioso se ok | `HARNESS_POST_EDIT=off` |
| Stop | stop_gate.py | roda **somente** o verify explicitamente configurado e bloqueia no máximo 2× | `HARNESS_STOP_GATE=off` |

Verify do Stop gate: `HARNESS_VERIFY_CMD` ou `.harness/verify.sh`. Sem um deles, o hook não inventa `pytest`, `npm test` ou `composer test`; descoberta e ampliação de testes pertencem ao `flow-verify`.

No Claude Code, comandos arriscados mas legítimos podem pedir aprovação pelo hook. No Codex, o guard bloqueia a operação e exige aprovação explícita no fluxo do agente. O instalador limita o `additionalContext` do SessionStart no Codex para impedir que um working tree/plano grande consuma a janela.

## LSP / code intelligence
- Servidores: `scripts/install-lsp.sh python ts php` (Pyright + Ruff, typescript-language-server, Intelephense).
- Claude Code: prefira plugins de code intelligence para definição, referências e diagnósticos; isso evita grep + leitura repetida.
- Codex: use LSP/Serena sob demanda quando navegação por símbolos superar `rg`/Atlas/SigMap.
- Piso determinístico: post-edit para erro barato e verify explícito para comportamento.

## MCP e ferramentas externas
- Habilite MCP por projeto e apenas quando necessário.
- Claude Code já adia definições de ferramentas MCP por padrão; não replique catálogos inteiros em prompts e não migre MCPs para mcp2cli apenas por hábito.
- Em stacks OpenAI que suportam tool search/deferred loading, prefira a descoberta nativa antes de wrappers.
- `mcp2cli/mcpq` fica como camada de compatibilidade quando um cliente/servidor ainda mantém schemas residentes ou quando o CLI produzido é comprovadamente mais compacto.
- Prefira uma CLI direta (`gh`, `psql`, `mysql`, etc.) quando ela expõe a mesma operação com menor overhead e permissões claras.
- Context7 e Playwright são exemplos opcionais, não defaults universais. Ative-os só em projetos que realmente precisam de documentação dinâmica ou verificação de UI.
