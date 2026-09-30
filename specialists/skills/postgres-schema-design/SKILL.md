---
name: postgres-schema-design
description: "Design PostgreSQL schemas: types, constraints, keys, partitioning and safe migrations. Use when modeling tables, changing columns, adding constraints or partitions, or planning zero-downtime DDL."
---

# PostgreSQL Schema Design

## Use when
- New tables, type changes, adding NOT NULL/FK/UNIQUE on live data, partitioning decisions, multi-tenant modeling.

## Diagnose first
- `\d+ t` or `SELECT * FROM information_schema.columns WHERE table_name='t';`; existing conventions in migrations.
- Size and growth: `SELECT pg_size_pretty(pg_total_relation_size('t')), reltuples FROM pg_class WHERE oid='t'::regclass;`
- Locks that DDL would wait on: `SELECT * FROM pg_locks WHERE relation='t'::regclass;` and long transactions in `pg_stat_activity`.

## Decision rules
- Types: `bigint` identity keys (`GENERATED ... AS IDENTITY`), `numeric` for money, `timestamptz` for instants, `text` over `varchar(n)` unless a limit is a real rule, `uuid` when ids are generated outside.
- Enforce integrity in the database: `NOT NULL`, `CHECK`, `UNIQUE`, FKs with index on the referencing column.
- Adding a constraint without a long lock: `ADD CONSTRAINT ... NOT VALID` then `VALIDATE CONSTRAINT`; `NOT NULL` via validated `CHECK` first (PG 12+ can then set NOT NULL cheaply).
- Adding a column with a constant default is metadata-only since PG 11; volatile defaults rewrite the table.
- Partition (declarative, PG 10+) only for very large tables with a natural key such as time, mainly for retention and pruning; every unique key must include the partition key.
- JSONB for sparse or evolving attributes; keep queried fields as real columns.
- Set `lock_timeout` on migrations so DDL fails fast instead of queueing behind traffic.

## Anti-patterns
- `serial` for new designs when identity is available; storing money as float; enum types that change often; FK without index; one giant migration doing DDL and backfill together.

## Safety
DDL on production needs approval, `lock_timeout`, a rollback migration and a backfill in batches. `ALTER TYPE` and rewrites can block for hours on big tables.

## Verify
- Migration rehearsed on a production-size copy with timings; `\d+` matches intent; constraints validated; app tests pass; rollback tested.
