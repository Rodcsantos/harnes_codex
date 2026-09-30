---
name: mysql-schema-design
description: "Design or change MySQL schemas: types, keys, constraints, charset and online migration path. Use when creating tables, altering columns, choosing primary keys or data types, or planning a risky migration."
---

# MySQL Schema Design

## Use when
- New table or feature model; column type change; adding constraints; large table migration; charset/collation decisions.

## Diagnose first
- `SHOW CREATE TABLE t\G`; `SELECT table_name, engine, table_rows, data_length, index_length, table_collation FROM information_schema.tables WHERE table_schema=DATABASE();`
- Existing conventions in the repo's migrations (naming, timestamps, soft delete, tenancy column).
- `SELECT @@sql_mode, @@character_set_server, @@collation_server, @@version;`

## Decision rules
- InnoDB table, explicit primary key, monotonically increasing when possible (`BIGINT UNSIGNED AUTO_INCREMENT`); random UUID keys fragment the clustered index (use ordered UUIDs or a surrogate key).
- Smallest correct type: `INT` vs `BIGINT` by growth, `DECIMAL(p,s)` for money (never FLOAT), `DATETIME`/`TIMESTAMP` chosen deliberately (TIMESTAMP range ends in 2038).
- `utf8mb4` for text; keep collation consistent across joined columns.
- Enforce integrity in the database: `NOT NULL`, `UNIQUE`, foreign keys (with an index on the child column), `CHECK` (enforced from 8.0.16).
- JSON columns for sparse attributes only; index queried paths through generated columns.
- Changing a column on a large table: expand, backfill in batches, switch reads, contract later.

## Anti-patterns
- EAV tables for core data; comma-separated lists in a column; nullable everything; `ENUM` for values that change often; missing FK index.

## Safety
DDL on production: choose explicit `ALGORITHM`/`LOCK`, check metadata-lock waiters, prefer gh-ost or pt-osc for large tables, take approval, keep a reversible migration. Type narrowing can silently truncate unless `sql_mode` is strict.

## Verify
- Migration runs on a copy with production-scale data; timing recorded; schema diff matches intent; application tests pass; rollback rehearsed.
