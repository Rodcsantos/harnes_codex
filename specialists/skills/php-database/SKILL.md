---
name: php-database
description: "Use PHP database access safely and efficiently with PDO or ORM: prepared statements, transactions, N+1 and migrations. Use when writing queries, fixing slow endpoints, handling transactions or connection issues in PHP."
---

# PHP Database

## Use when
- New queries, ORM relation problems, slow list pages, transaction bugs, connection limits, or SQL injection risk.

## Diagnose first
- Which layer is used (PDO, Eloquent, Doctrine, query builder) and the DB engine/version.
- Query count per request: Laravel `DB::listen`/Debugbar/Telescope, Doctrine profiler, or enable the DB slow log.
- Find raw SQL built by concatenation: `grep -rnE "(query|exec)\(.*\\$|\\.\s*\\$_(GET|POST|REQUEST)" --include=*.php`.
- Run `EXPLAIN` on the suspicious statement (see mysql/postgres skills).

## Decision rules
- Always prepared statements with bound parameters (PDO `prepare/execute`, `?`/named); PDO with `ERRMODE_EXCEPTION`, real prepares (`ATTR_EMULATE_PREPARES=false` where supported), `utf8mb4`.
- Identifiers and sort columns cannot be bound: whitelist them.
- N+1: eager load (`with()` in Eloquent, `JOIN FETCH`/`EXTRA_LAZY` tuning in Doctrine); select only needed columns; paginate; chunk (`chunkById`) large jobs.
- Transactions: `beginTransaction/commit/rollBack` (or `DB::transaction`) around dependent writes; keep short; retry on deadlock; no HTTP calls inside.
- Lost updates: `SELECT ... FOR UPDATE` (`lockForUpdate()`) or atomic `UPDATE ... SET n=n+1`.
- Migrations via the framework's tool, reviewed like code; large-table changes follow zero-downtime steps.
- Persistent connections and pool limits: watch total connections across FPM workers.

## Anti-patterns
- String-concatenated SQL; `SELECT *` in hot paths; queries in loops; catching `PDOException` and ignoring it; mass assignment of request data.

## Safety
Schema changes, bulk updates/deletes and raw SQL with user input need approval and review; test destructive statements on a copy first.

## Verify
- Injection attempts in tests return safe results; query count/`EXPLAIN` improved; transaction rollback test proves atomicity; migration runs up and down.
