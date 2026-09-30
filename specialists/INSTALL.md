# Codex Development Specialists

Pacote de agentes e skills progressivas para Python, Django, PHP, React, MySQL, PostgreSQL e Redis.

## Política de contexto
O repositório mantém todo o catálogo como fonte. A instalação padrão é **base**: somente `flow-*` e `shared-*`. Isso reduz o catálogo de descrições carregado em cada sessão. Adicione apenas as stacks usadas pelo projeto.

## Instalar
```bash
# base: flow-* + shared-*
./install.sh

# stacks específicas
./install.sh --skills react,php
./install.sh --skills django,postgres,redis

# Django inclui também as skills Python.
# Catálogo inteiro apenas quando necessário:
./install.sh --skills all
```

Também é possível definir `HARNESS_SKILL_PROFILES=react,php`.

O instalador mantém os agentes disponíveis, faz backup de entradas Codex substituídas/removidas em `$CODEX_HOME/backups/`, valida os arquivos instalados e não reescreve `config.toml`.

## Verificar
```bash
python3 verify.py "${CODEX_HOME:-$HOME/.codex}"
```

## Uso
Prefira o agente principal para tarefas rotineiras. Acione um especialista quando o domínio realmente trouxer ganho e use `fullstack_orchestrator` somente para trabalho cross-stack acoplado.
