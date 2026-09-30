# Especialistas

## Catálogo de agentes

O harness mantém **42 agentes-fonte** em `specialists/agents/`, gerando equivalentes Claude em `claude/agents/`.

O default não instala os 42. `--agents auto` mantém apenas quatro agentes core e acrescenta especialistas pela stack selecionada com `--skills`. Os perfis completos estão em `specialists/agent-profiles.json` e a descrição funcional em `docs/LIFECYCLE-AGENTS.md`.

Agentes core: tech-lead, explorer, reviewer, verifier.

Perfis de SDLC: product, architecture, frontend, backend, mobile, data, qa, security, devops, sre, delivery, dx e fullstack.

Especialistas de stack continuam disponíveis: python-expert, django-expert, php-expert, react-expert, mysql-dba, postgresql-dba, redis-expert e infra-expert.

## 65 skills originais
Django: django-architecture, django-auth-permissions, django-migrations, django-models, django-orm-optimization, django-production, django-rest-api, django-transactions.
MySQL: mysql-backup-replication, mysql-indexing, mysql-innodb-memory, mysql-observability-safety, mysql-query-optimization, mysql-schema-design, mysql-slow-query-diagnostics, mysql-transactions-locking.
PHP: php-architecture, php-composer-psr, php-database, php-modern, php-performance-debugging, php-rest-api, php-security, php-testing-static-analysis.
PostgreSQL: postgres-backup-pitr-replication, postgres-explain-analyze, postgres-indexing, postgres-memory-connections, postgres-observability-security, postgres-query-optimization, postgres-schema-design, postgres-transactions-locking, postgres-vacuum-statistics.
Python: python-architecture, python-asyncio, python-debugging, python-packaging, python-performance, python-security, python-testing, python-typing.
React: react-accessibility, react-architecture, react-debugging, react-forms-validation, react-hooks, react-performance, react-server-state, react-state, react-testing, react-typescript.
Redis: redis-cache-design, redis-data-modeling, redis-hotkeys-bigkeys, redis-invalidation, redis-locking-rate-limit, redis-memory-eviction, redis-persistence-ha-observability, redis-streams-queues.
Shared: shared-api-design, shared-code-review, shared-production-readiness, shared-root-cause-analysis, shared-security-review, shared-testing-strategy.

## Skills de fluxo (5)
flow-plan, flow-implement, flow-verify, flow-review, flow-ship.

specialists/manifest.json é a lista canônica do pacote.

## Instalação por perfil
O catálogo completo permanece versionado, mas não deve ficar todo globalmente ativo por padrão.

- `base`: `flow-*` + `shared-*` (padrão).
- `python`, `php`, `react`, `mysql`, `postgres`, `redis`: adicionam somente o prefixo correspondente.
- `django`: adiciona `django-*` + `python-*`.
- Perfis podem ser combinados por vírgula.
- `all`: instala as 70 skills e deve ficar restrito a laboratório ou projeto realmente multi-stack.

Exemplo: `./scripts/install-harness.sh --engine both --skills react,php`.
