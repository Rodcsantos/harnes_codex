---
name: postgres-vacuum-statistics
description: "Manage PostgreSQL autovacuum, bloat, transaction ID wraparound risk and planner statistics. Use when tables bloat, queries slow as data churns, autovacuum lags, or age(datfrozenxid) grows."
---

# PostgreSQL Vacuum and Statistics

## Use when
- Dead tuples pile up, index-only scans stop working, disk grows without data growth, wraparound warnings, or plans degrade after bulk changes.

## Diagnose first
- `SELECT relname, n_live_tup, n_dead_tup, last_autovacuum, last_autoanalyze FROM pg_stat_user_tables ORDER BY n_dead_tup DESC LIMIT 15;`
- Wraparound: `SELECT datname, age(datfrozenxid) FROM pg_database ORDER BY 2 DESC;` and per table `age(relfrozenxid)`.
- Running vacuums: `SELECT * FROM pg_stat_progress_vacuum;`
- Blockers: old transactions, unused replication slots (`backend_xmin`, `xmin` in `pg_replication_slots`), prepared transactions (`pg_prepared_xacts`).
- Bloat estimate with `pgstattuple` when installed.

## Decision rules
- Vacuum cannot remove tuples visible to the oldest transaction: fix long transactions, stale slots and forgotten prepared transactions before tuning.
- Hot, large tables: lower per-table `autovacuum_vacuum_scale_factor` (and `autovacuum_vacuum_insert_scale_factor` on PG 13+) rather than only global changes; raise cost limits if vacuum is throttled too much.
- After large loads or deletes: run `ANALYZE` explicitly.
- Reclaiming space to the OS needs `VACUUM FULL` (exclusive lock, rewrite) or `pg_repack`; ordinary vacuum only makes space reusable.
- Approaching wraparound: prioritize aggressive vacuum on the oldest tables immediately.

## Anti-patterns
- Disabling autovacuum; scheduling `VACUUM FULL` routinely; ignoring `age(relfrozenxid)`; tuning while an old transaction still pins the horizon.

## Safety
`VACUUM FULL`, `REINDEX` (non-concurrent), `pg_repack` and `autovacuum` parameter changes need approval and disk-space check (a rewrite needs about the table size free).

## Verify
- `n_dead_tup` and table/index size trend down, `last_autovacuum` recent, `age(datfrozenxid)` well below `autovacuum_freeze_max_age`, plans and index-only scans recover.
