# Codex Development Specialists

Pacote completo de agentes SDLC + especialistas de stack + skills progressivas para Codex e Claude Code.

## Política de contexto

O repositório mantém **42 agentes-fonte** e 70 skills, mas a instalação padrão é seletiva:

- agentes: `auto` = core (`tech-lead`, `explorer`, `reviewer`, `verifier`) + especialistas inferidos por `--skills`;
- skills: `base` = `flow-*` + `shared-*`;
- perfis de Product, QA, Security, DevOps, SRE etc. entram somente quando solicitados.

## Instalar

```bash
# Base enxuta
./install.sh

# React + PHP: core + react-expert + php-expert
./install.sh --skills react,php

# Produto + arquitetura + frontend
./install.sh --skills react --agents product,architecture,frontend

# Backend Django/Postgres + QA/Security
./install.sh --skills django,postgres --agents backend,data,qa,security

# Infra/SRE/Security
./install.sh --agents devops,sre,security

# Tudo, somente laboratório/projeto excepcionalmente amplo
./install.sh --skills all --agents all
```

Variáveis equivalentes: `HARNESS_SKILL_PROFILES` e `HARNESS_AGENT_PROFILES`.

Perfis disponíveis: `product`, `architecture`, `frontend`, `backend`, `mobile`, `data`, `qa`, `security`, `devops`, `sre`, `delivery`, `dx`, `fullstack`.

O instalador faz backup das entradas Codex que substitui/remove em `$CODEX_HOME/backups/`, valida o catálogo instalado e não reescreve `config.toml`.

## Verificar

```bash
python3 verify.py "${CODEX_HOME:-$HOME/.codex}"
python3 select_agents.py --profiles auto --skills react,php
```

## Uso

Prefira o agente principal em tarefas rotineiras. Acione um perfil/especialista quando domínio, isolamento de contexto, revisão independente ou paralelismo trouxer ganho material. O catálogo funcional completo está em `docs/LIFECYCLE-AGENTS.md` no repositório principal.
