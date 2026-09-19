# harnes_codex

Ambiente centralizado para **WSL + Codex CLI** com foco em desenvolvimento profissional, baixo consumo de tokens, especialistas por stack e operação de infraestrutura.

## Objetivos

- Reproduzir o ambiente de desenvolvimento WSL/Codex.
- Centralizar scripts, configurações, instruções, agentes e skills.
- Manter histórico técnico e artefatos anteriores em `archive/`.
- Separar regras globais, especialistas de desenvolvimento e operação de infraestrutura.
- Facilitar instalação, diagnóstico, atualização e rollback.

## Estrutura

```text
.
├── AGENTS.md
├── INSTALL.md
├── README.md
├── agents/
├── archive/
├── config/
├── docs/
├── scripts/
└── skills/
```

## Instalação rápida

```bash
git clone https://github.com/Rodcsantos/harnes_codex.git
cd harnes_codex
chmod +x scripts/*.sh
./scripts/install-codex-efficient-stack.sh
./scripts/install-specialists.sh
./scripts/verify.sh
```

O stack eficiente inclui Codex CLI, RTK, Atlas, SigMap, Serena, mcp2cli, Headroom, Tokview e política de MCP lazy/on-demand.

Os especialistas cobrem Python, Django, PHP, React, MySQL, PostgreSQL, Redis, infraestrutura e orquestração full-stack.

> Revise scripts e configurações antes de executar em ambientes corporativos ou produtivos. Credenciais, tokens e segredos nunca devem ser commitados.

Veja `docs/PROJECT-CENTRAL.md` e `docs/SOURCE-MANIFEST.md` para contexto, decisões e origem dos artefatos.
