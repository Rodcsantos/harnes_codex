---
name: postgres-indexing
description: "Choose PostgreSQL index types and definitions (btree, GIN, GiST, BRIN, partial, covering) and create them safely. Use when queries need index support, an index is unused or bloated, or index creation on a big table is planned."
---

# PostgreSQL Indexing

## Use when
- Slow filters, joins, ordering, JSONB/array/full-text search, or time-series scans; reviewing unused or duplicate indexes.

## Diagnose first
- `SELECT indexrelid::regclass, idx_scan, pg_size_pretty(pg_relation_size(indexrelid)) FROM pg_stat_user_indexes WHERE relid='t'::regclass ORDER BY idx_scan;` (counters reset with stats resets).
- `SELECT indexdef FROM pg_indexes WHERE tablename='t';` and check duplicates by column list.
- `EXPLAIN (ANALYZE, BUFFERS)` of the target query before creating anything.
- Bloat suspicion: compare index size to table size and check `pgstattuple` if available.

## Decision rules
- Default btree: equality then range column order; leftmost-prefix applies.
- JSONB containment, arrays, full-text: GIN. Geometric/range/nearest-neighbour: GiST. Huge append-only, naturally ordered data: BRIN.
- Partial index (`WHERE active`) when queries always filter the same subset; expression index when the query uses the same expression.
- Covering: `INCLUDE (cols)` (PG 11+) for index-only scans; needs a recently vacuumed visibility map.
- Foreign key columns usually need an index on the referencing side for deletes and joins.
- `text_pattern_ops` or a trigram index (`pg_trgm`) for `LIKE 'x%'` under non-C collations or `LIKE '%x%'`.

## Anti-patterns
- Indexing every column; duplicate `(a)` and `(a,b)`; indexes on low-selectivity booleans; unused indexes kept "just in case".

## Safety
Use `CREATE INDEX CONCURRENTLY` on live tables (cannot run in a transaction; a failed run leaves an INVALID index to drop and retry). Plain `CREATE INDEX` blocks writes. `DROP INDEX CONCURRENTLY` likewise. Needs approval for large tables; check disk space first.

## Verify
- Plan uses the index (`Index Scan`/`Index Only Scan`/`Bitmap`), timing and buffers improved, `pg_index.indisvalid` is true, write latency unchanged.
