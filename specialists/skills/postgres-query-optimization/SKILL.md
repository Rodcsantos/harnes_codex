---
name: postgres-query-optimization
description: "Optimize specific PostgreSQL queries by rewriting SQL, fixing estimates and reducing round trips. Use when one statement dominates pg_stat_statements, pagination is slow, or an ORM produces N+1 or huge joins."
---

# PostgreSQL Query Optimization

## Use when
- A known query is slow, called too often, returns too many rows, or plan quality degrades with data growth.

## Diagnose first
- Rank first: `pg_stat_statements` by `total_exec_time`, then check `calls`, `mean_exec_time`, `rows`, `shared_blks_read`.
- `EXPLAIN (ANALYZE, BUFFERS)` on realistic data (see postgres-explain-analyze).
- App side: count queries per request (N+1), and payload size versus rows used.

## Decision rules
- Filter early and select only needed columns; wide `SELECT *` blocks index-only scans and inflates I/O.
- Deep `OFFSET`: use keyset pagination on an indexed, unique ordering.
- `IN (subquery)` vs `EXISTS` vs `JOIN`: since PG 12 CTEs are inlined unless `MATERIALIZED` is written or they are recursive/side-effecting; test alternatives with real plans.
- Repeated per-row lookups from the app: batch with `= ANY($1)` or a join.
- Large aggregate on OLTP path: precompute (materialized view refreshed `CONCURRENTLY` with a unique index) or summarize incrementally.
- Bulk writes: multi-row `INSERT`, `COPY`, or `INSERT ... ON CONFLICT`; batch in chunks.
- Wrong estimates: `ANALYZE`, extended statistics, or rewrite; hints do not exist in core Postgres.

## Anti-patterns
- `DISTINCT` to mask duplicate joins; `NOT IN` with nullable subquery (use `NOT EXISTS`); functions on indexed columns in WHERE; `COUNT(*)` on huge tables for UI totals.

## Safety
Rewrites must preserve results and ordering contracts; get caller review for changed semantics. Materialized view refresh and bulk DML need approval and batching on production.

## Verify
- Before/after `EXPLAIN (ANALYZE, BUFFERS)` and `pg_stat_statements` deltas; identical result sets on a sample; no new lock waits.
