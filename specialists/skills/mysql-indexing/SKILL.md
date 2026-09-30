---
name: mysql-indexing
description: "Design composite and covering MySQL indexes from predicates, joins, ordering and selectivity. Use when a WHERE/JOIN/ORDER BY/GROUP BY is slow, an index is proposed or dropped, or write cost from indexes is a concern."
---

# MySQL Indexing

## Use when
- A query does full scans, filesorts or temporary tables.
- Adding, changing or removing an index; suspecting redundant or unused indexes.

## Diagnose first
- `EXPLAIN FORMAT=TREE <query>` or `FORMAT=JSON`: access type, `key`, `rows`, `Extra`. `EXPLAIN ANALYZE` (8.0.18+) executes the query: only for safe SELECTs.
- `SHOW INDEX FROM t;` and `SELECT COUNT(DISTINCT c)/COUNT(*) FROM t;` for selectivity.
- `SELECT * FROM sys.schema_redundant_indexes; SELECT * FROM sys.schema_unused_indexes;` (unused data resets on restart: check uptime).

## Decision rules
- Composite order: equality columns first, then one range column, then ORDER BY columns if they can still be used. Columns after a range predicate do not filter by index.
- Leftmost prefix: `(a,b)` serves `a` and `a,b`, not `b`. Drop `(a)` when `(a,b)` exists.
- Covering index (`Using index` in Extra) avoids row lookups; add `INCLUDE`-like columns only when the query is hot.
- Predicate wraps a column in a function: rewrite to a sargable form, or use a functional index / generated column (8.0.13+).
- Mixed ORDER BY directions: descending index parts are honored in 8.0.
- Every secondary index carries the primary key: keep the PK short.
- Test a drop safely with `ALTER TABLE t ALTER INDEX i INVISIBLE` (8.0), then watch.

## Anti-patterns
- Single index on a low-cardinality flag; `LIKE '%x'`; comparing a string column to a number (implicit cast disables the index); `OR` across different columns; indexing every column.

## Safety
Large tables: state `ALGORITHM=INPLACE, LOCK=NONE` explicitly so it fails instead of silently locking; it still waits on metadata locks behind long transactions. For very large tables consider gh-ost or pt-online-schema-change. Needs approval; rollback is `DROP INDEX` or making it visible again.

## Verify
- EXPLAIN before/after: `key`, `rows`, no filesort or temporary in `Extra`.
- Timing on production-like data, write latency unchanged, slow log digest shows no new regression.
