# Especialistas

## Agentes do pacote original
- django_expert
- fullstack_orchestrator
- mysql_dba
- php_expert
- postgresql_dba
- python_expert
- react_expert
- redis_expert

O projeto acrescenta infra_expert e 7 agentes de processo (tech_lead, explorer, architect, test_engineer, verifier, reviewer, security_reviewer). Veja `docs/TEAM.md`.

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
