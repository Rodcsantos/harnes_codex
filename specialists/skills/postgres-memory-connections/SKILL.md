---
name: postgres-memory-connections
description: "Size PostgreSQL memory settings and connection handling (shared_buffers, work_mem, pooling). Use when there are too many connections, out-of-memory kills, swapping, or slow queries that spill to disk."
---

# PostgreSQL Memory and Connections

## Use when
- `too many clients already`, OOM killer hits postgres, high context switching, or sorts and hashes spill to temp files.

## Diagnose first
- `SHOW max_connections; SHOW shared_buffers; SHOW work_mem; SHOW maintenance_work_mem; SHOW effective_cache_size;`
- `SELECT state, count(*) FROM pg_stat_activity GROUP BY 1;` and long `idle in transaction` sessions with `now()-xact_start`.
- Temp spill: `SELECT datname, temp_files, pg_size_pretty(temp_bytes) FROM pg_stat_database;`
- Host: `free -m`, swap, `dmesg | grep -i 'out of memory'`.

## Decision rules
- Each connection is a process; hundreds of active ones hurt. Put a pooler (PgBouncer) in front and keep `max_connections` modest; transaction pooling breaks session state (prepared statements, `SET`, advisory locks): confirm app compatibility.
- `work_mem` applies per sort/hash node per query, times concurrency: raise per role or session for known heavy queries, not globally.
- `shared_buffers` often starts around 25% of RAM; `effective_cache_size` is a planner hint, not an allocation.
- `idle in transaction` holds locks and blocks vacuum: set `idle_in_transaction_session_timeout` and fix the app.
- Reserve `superuser_reserved_connections` so you can still log in during incidents.

## Anti-patterns
- Raising `max_connections` to fix pool exhaustion; global `work_mem` of hundreds of MB; ignoring connection leaks in the app.

## Safety
Most memory and connection settings require restart or reload: state which, plan a window, keep old values. `pg_terminate_backend` needs approval and knowledge of what the session holds.

## Verify
- Active connections stay below the limit at peak, no OOM events, `temp_bytes` growth slows, p95 latency stable under the same load.
