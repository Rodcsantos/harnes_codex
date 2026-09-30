---
name: postgres-explain-analyze
description: "Read PostgreSQL execution plans with EXPLAIN (ANALYZE, BUFFERS) and find the real bottleneck. Use when a query is slow, a plan changed after deploy or data growth, or estimates and actual rows disagree."
---

# PostgreSQL EXPLAIN ANALYZE

## Use when
- Sequential scan where an index was expected, nested loop explosions, sorts spilling to disk, or plan flips between environments.

## Diagnose first
- `EXPLAIN (ANALYZE, BUFFERS, VERBOSE, SETTINGS) <query>;` ANALYZE executes the statement: for INSERT/UPDATE/DELETE wrap in `BEGIN; ... ROLLBACK;` or avoid on production.
- Read bottom-up; compare `rows=` (estimate) with `actual ... rows=` and `loops`. Multiply per-loop time by loops.
- Buffers: `shared hit` vs `read` (cache), `temp read/written` (spill), `Sort Method: external merge Disk`.
- `SELECT * FROM pg_stats WHERE tablename='t' AND attname='c';` and `SELECT relname, n_live_tup, last_analyze, last_autoanalyze FROM pg_stat_user_tables;`

## Decision rules
- Estimate off by 10x or more: stale statistics (`ANALYZE`), correlated columns (`CREATE STATISTICS`), or expression the planner cannot estimate.
- Seq scan is fine when the query needs a large fraction of the table; force nothing until you know the selectivity.
- Sort or hash spill: raise `work_mem` for that session or role, not globally; or add an index that provides order.
- Nested loop with large inner loops: missing index on the join key or bad row estimate.
- Generic vs custom plans in prepared statements can differ; check `plan_cache_mode` when only the app is slow.
- Do not tune with `enable_*` flags in production; use them only to compare plans in a session.

## Anti-patterns
- Reading only the total time; trusting a plan from a tiny dev dataset; changing indexes without re-running ANALYZE-based comparison.

## Safety
`SET` changes stay session-local; never `ALTER SYSTEM` for a single query. Do not run ANALYZE on destructive statements outside a rolled back transaction.

## Verify
- Same query, same parameters, before/after plans saved; actual time and buffers dropped; estimates within a small factor of actual rows.
