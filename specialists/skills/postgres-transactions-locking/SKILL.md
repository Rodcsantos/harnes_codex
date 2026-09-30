---
name: postgres-transactions-locking
description: "Analyze PostgreSQL transactions, isolation levels, locks, deadlocks and blocking chains. Use when queries hang, deadlocks appear, transactions stay idle, or serialization failures occur."
---

# PostgreSQL Transactions and Locks

## Use when
- `deadlock detected`, `could not serialize access`, sessions waiting on locks, `idle in transaction` piling up, DDL stuck behind traffic.

## Diagnose first
- Blockers: `SELECT pid, pg_blocking_pids(pid) AS blocked_by, wait_event_type, wait_event, now()-xact_start AS xact_age, left(query,100) FROM pg_stat_activity WHERE cardinality(pg_blocking_pids(pid))>0;`
- Locks: `SELECT locktype, relation::regclass, mode, granted, pid FROM pg_locks WHERE NOT granted;`
- Old transactions: `SELECT pid, state, now()-xact_start AS age, left(query,80) FROM pg_stat_activity WHERE xact_start IS NOT NULL ORDER BY xact_start LIMIT 10;`
- Log deadlock details with `log_lock_waits=on` and read the server log entry.

## Decision rules
- Default READ COMMITTED; REPEATABLE READ and SERIALIZABLE raise serialization failures that the app must retry as a whole transaction.
- Deadlocks: take locks in a consistent order; keep transactions short; update rows sorted by key.
- Queues: `SELECT ... FOR UPDATE SKIP LOCKED` for workers; `NOWAIT` to fail fast.
- Counters and hot rows: avoid read-modify-write in the app; use `UPDATE ... SET n=n+1` or advisory locks deliberately.
- DDL needs `ACCESS EXCLUSIVE` on most operations and queues behind long transactions, blocking everyone behind it: set `lock_timeout`, retry.
- Idle-in-transaction sessions block vacuum and hold locks: set `idle_in_transaction_session_timeout`.

## Anti-patterns
- Transactions spanning HTTP calls or user input; retrying a single statement inside an aborted transaction; `LOCK TABLE` as a shortcut.

## Safety
`pg_cancel_backend` (query) before `pg_terminate_backend` (session), both with approval and knowing what will roll back.

## Verify
- Blocking chain cleared and does not recur under a two-session reproduction; deadlock and retry counts drop; a test covers the retry path.
