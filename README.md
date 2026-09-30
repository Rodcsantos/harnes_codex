# harnes_codex

Repositório canônico do ambiente **WSL + Codex CLI**: setup, economia de tokens, especialistas por stack, skills progressivas e operação de infraestrutura.

## Estado atual

- **16 agentes**: 9 especialistas de stack (Python, Django, PHP, React, MySQL, PostgreSQL, Redis, infraestrutura, orquestração full-stack) + 7 de processo (tech lead, explorer, architect, test engineer, verifier, reviewer, security reviewer).
- **70 skills**: 65 de domínio + 5 de fluxo (`flow-plan`, `flow-implement`, `flow-verify`, `flow-review`, `flow-ship`), cada uma com `SKILL.md` e `agents/openai.yaml`.
- **Codex CLI e Claude Code** com a mesma fonte: agentes Claude gerados dos TOML (`claude/agents/`), `CLAUDE.md` importa o `AGENTS.md`.
- **Hooks** (`hooks/`): guard, post-edit, stop-gate e session-start. Veja `docs/HOOKS-LSP-MCP.md`.
- **144/144 arquivos** do pacote original `codex-dev-specialists` recuperados e versionados em `specialists/`.
- Stack de eficiência: **RTK, Atlas, SigMap, Serena, mcp2cli/mcpq, Headroom e Tokview**.
- Documentação histórica preservada em `archive/`.
- Regras globais do harness em `AGENTS.md`.
- CI de integridade em `.github/workflows/verify-harness.yml`.

## Estrutura

```text
.
├── AGENTS.md
├── INSTALL.md
├── README.md
├── archive/
│   ├── codex-cli-profissional-python-django-etl.md
│   └── harness-desenvolvimento-maximo-codex-wsl.md
├── config/
│   └── codex-config.example.toml
├── docs/
│   ├── ARCHITECTURE.md
│   ├── INFRASTRUCTURE.md
│   ├── PROJECT-CENTRAL.md
│   ├── SOURCE-MANIFEST.md
│   ├── SPECIALISTS.md
│   ├── TOKEN-EFFICIENCY.md
│   └── WSL-SETUP.md
├── scripts/
│   ├── install-codex-efficient-stack.sh
│   ├── install-specialists.sh
│   └── verify.sh
└── specialists/
    ├── agents/
    │   ├── django-expert.toml
    │   ├── fullstack-orchestrator.toml
    │   ├── infra-expert.toml
    │   ├── mysql-dba.toml
    │   ├── php-expert.toml
    │   ├── postgresql-dba.toml
    │   ├── python-expert.toml
    │   ├── react-expert.toml
    │   └── redis-expert.toml
    ├── skills/                 # 65 skills
    ├── config-snippet.toml
    ├── install.sh
    ├── manifest.json
    ├── uninstall.sh
    └── verify.py
```

## Instalação no WSL

```bash
git clone https://github.com/Rodcsantos/harnes_codex.git
cd harnes_codex

chmod +x scripts/*.sh

# Ferramentas de eficiência/contexto para Codex
./scripts/install-codex-efficient-stack.sh

# Time completo + skills + hooks nos dois CLIs (ou --engine codex|claude)
./scripts/install-harness.sh --engine both

# Opcional: language servers (LSP)
./scripts/install-lsp.sh python ts

# Diagnóstico final
./scripts/verify.sh
```

O instalador de especialistas faz backup dos agentes/skills que substituir em `$CODEX_HOME/backups/` antes de copiar o pacote.

## Verificação do pacote

Sem instalar nada na home:

```bash
python3 specialists/verify.py specialists
```

Testes dos hooks e sincronia dos agentes Claude:

```bash
python3 -m unittest discover -s tests
python3 scripts/build-claude-agents.py --check
```

Validação de shell:

```bash
bash -n scripts/install-codex-efficient-stack.sh
bash -n scripts/install-specialists.sh
bash -n scripts/verify.sh
bash -n specialists/install.sh
bash -n specialists/uninstall.sh
```

## Segurança

Não versionar tokens, PATs, chaves privadas, `.env`, dumps reais, credenciais MCP ou certificados privados. Produção deve ser **read-only por padrão** para diagnóstico de banco/infra; operações destrutivas exigem aprovação explícita e rollback.

## Documentação

Comece por:

- `docs/PROJECT-CENTRAL.md` — visão consolidada.
- `docs/ARCHITECTURE.md` — arquitetura do harness.
- `docs/TEAM.md` — time, fluxo e regras de contexto.
- `docs/HOOKS-LSP-MCP.md` — hooks, LSP e MCP.
- `docs/SPECIALISTS.md` — catálogo de agentes/skills.
- `docs/INFRASTRUCTURE.md` — escopo operacional de infraestrutura.
- `docs/TOKEN-EFFICIENCY.md` — política de economia de tokens.
- `docs/SOURCE-MANIFEST.md` — origem e fidelidade dos artefatos.
