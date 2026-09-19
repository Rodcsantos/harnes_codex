# Codex Development Specialists

Ready-to-install Codex custom agents and progressive-disclosure skills for Python, Django, PHP, React, MySQL, PostgreSQL and Redis.

## Included
- `django-expert.toml`
- `fullstack-orchestrator.toml`
- `mysql-dba.toml`
- `php-expert.toml`
- `postgresql-dba.toml`
- `python-expert.toml`
- `react-expert.toml`
- `redis-expert.toml`

Skills: **65** task-focused skills, each with `SKILL.md` and `agents/openai.yaml`.

## Install in WSL
```bash
unzip codex-dev-specialists.zip
cd codex-dev-specialists
./install.sh
```

The installer backs up only entries it replaces under `$CODEX_HOME/backups/`, validates installed files, and does not rewrite your existing `config.toml`. Optionally merge `config-snippet.toml` into your Codex configuration.

## Verify
```bash
python3 verify.py "${CODEX_HOME:-$HOME/.codex}"
```

## Example usage
Ask Codex explicitly to use `django_expert`, `mysql_dba`, `react_expert`, etc., or ask `fullstack_orchestrator` to delegate a cross-stack investigation.
