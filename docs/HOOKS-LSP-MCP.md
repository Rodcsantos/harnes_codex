# Hooks, LSP e MCP

## Hooks (`hooks/`, instalados em `~/.harness/hooks`)
| Evento | Script | Faz | Desliga |
|---|---|---|---|
| SessionStart | session_start.py | branch, status, últimos commits e topo do plano (≈1 KB) | — |
| PreToolUse | guard.py | bloqueia `rm -rf` amplo, force push, push em main/master, leitura de `.env`/chaves; pede aprovação em `reset --hard`, DROP/TRUNCATE, `kubectl delete`, `terraform apply`, `docker prune`... | `HARNESS_GUARD=off` |
| PostToolUse | post_edit.py | formata e checa o arquivo editado (ruff, prettier/eslint locais, `php -l`, `bash -n`, JSON/TOML); silencioso se ok | `HARNESS_POST_EDIT=off` |
| Stop | stop_gate.py | roda o verify se há mudanças; bloqueia no máx. 2× por sessão | `HARNESS_STOP_GATE=off` |

Verify do projeto: `HARNESS_VERIFY_CMD`, ou `.harness/verify.sh` (modelo em `templates/project/.harness/`), ou padrões (pytest, `npm test`, `composer test`). Sem comando, o gate não faz nada.

Códigos: exit 2 bloqueia e devolve o stderr ao agente. No Claude Code, comandos "arriscados mas legítimos" retornam `permissionDecision: ask`; no Codex viram bloqueio.

**Codex:** `install-harness.sh` grava em `~/.codex/hooks.json` com o mesmo esquema de eventos do Claude Code. Como o formato e o flag de hooks do Codex mudam entre versões, confira com `rtk init --show --codex` e `codex --help`; se divergir, ajuste `scripts/merge_hooks.py` (bloco `else`). Mesmo sem hooks no Codex, `AGENTS.md`, a CI e o `verifier` mantêm o gate.

## LSP
- Servidores: `scripts/install-lsp.sh python ts php` (pyright + ruff, typescript-language-server, intelephense).
- Claude Code: use plugins de code intelligence (`/plugin`) para definição, referências e diagnósticos em vez de grep + leitura de arquivo.
- Codex: Serena (já no stack) cobre navegação semântica sob demanda.
- Piso determinístico nos dois: o hook post-edit (sintaxe/lint) e o verify (tipos/testes).

## MCP (poucos, sob demanda)
- Padrão: context7 (docs de libs) e playwright (UI). Modelos em `config/mcp.claude.example.json` (copie para `.mcp.json` do projeto) e `config/codex-config.example.toml`.
- Prefira CLI a MCP quando existir: `gh` em vez de GitHub MCP; `psql`/`mysql` com usuário **somente leitura** em vez de MCP de banco.
- Cada MCP ativo custa contexto: habilite por projeto, não globalmente.
