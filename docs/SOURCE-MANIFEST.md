# Manifesto de Origem

Atualizado em: 2026-09-19.

## Artefatos recuperados do projeto

| Artefato | Origem | Destino |
|---|---|---|
| `install-codex-efficient-stack.sh` | Projeto WSL, 2026-09-19 | `scripts/install-codex-efficient-stack.sh` |
| `INSTALL.md` do pacote de especialistas | Projeto WSL, 2026-09-19 | `INSTALL.md` e `specialists/INSTALL.md` |
| `codex-dev-specialists.zip` | Projeto WSL, 2026-09-19 | expandido integralmente em `specialists/` |
| Relatório “Codex CLI profissional para Python/Django/ETL” | Projeto WSL, 2026-09-12 | `archive/codex-cli-profissional-python-django-etl.md` |
| Relatório “Harness de desenvolvimento máximo para Codex CLI no WSL” | Projeto WSL, 2026-09-12 | `archive/harness-desenvolvimento-maximo-codex-wsl.md` |

## Integridade do pacote recuperado

O ZIP original foi recuperado em bytes e extraído com sucesso. A árvore recuperada contém:

- **144 arquivos**;
- **8 agentes originais**;
- **65 `SKILL.md`**;
- **65 `agents/openai.yaml`**;
- `install.sh`, `uninstall.sh`, `verify.py`, `manifest.json`, `config-snippet.toml` e documentação.

A árvore remota do GitHub foi conferida após o upload e contém os mesmos **144 arquivos recuperados**.

## Extensão do projeto

Além do pacote original, este repositório adiciona:

- `specialists/agents/infra-expert.toml` — especialista de infraestrutura/SRE construído para a frente Docker, Nginx, bancos, Linux/WSL, rede, observabilidade, backup/recovery e troubleshooting seguro.
- documentação central em `docs/`;
- regras globais em `AGENTS.md`;
- scripts de instalação/verificação;
- CI para preservar a integridade do harness.

Por isso o repositório final possui **9 agentes**, enquanto o `specialists/manifest.json` original permanece preservado com os **8 agentes** que pertenciam ao ZIP recuperado.

## Relatórios históricos

Os dois relatórios históricos excediam a janela de leitura de 1.000 linhas. Eles foram recuperados em páginas sucessivas e recombinados no GitHub até suas extensões completas:

- 1.051 linhas;
- 1.426 linhas.

## Nunca versionar

- tokens ou PATs;
- chaves SSH privadas;
- `.env` com segredos;
- dumps de produção;
- credenciais MCP;
- certificados/chaves privadas;
- dados pessoais ou corporativos sensíveis.
