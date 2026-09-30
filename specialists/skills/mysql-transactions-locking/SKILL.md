---
name: mysql-transactions-locking
description: "Analyze MySQL InnoDB transactions, isolation, deadlocks and lock waits. Use when there are deadlock errors, lock wait timeouts, long-running transactions, or inconsistent reads."
---

# MySQL Transactions and Locks

## Use when
- `Deadlock found when trying to get lock` or `Lock wait timeout exceeded`; replication lag from big transactions; undo/history list growth.

## Diagnose first
- `SHOW ENGINE INNODB STATUS\G`: section LATEST DETECTED DEADLOCK, TRANSACTIONS, history list length.
- `SELECT * FROM sys.innodb_lock_waits\G` (waiting vs blocking statement, wait age).
- `SELECT trx_id, trx_started, trx_rows_locked, trx_query FROM information_schema.innodb_trx ORDER BY trx_started;`
- `SELECT @@transaction_isolation, @@innodb_lock_wait_timeout, @@autocommit;` Consider `innodb_print_all_deadlocks` for capture.

## Decision rules
- Default REPEATABLE READ uses next-key/gap locks; range scans on non-unique or unindexed columns lock more than expected. An index that narrows the scan reduces locks.
- Deadlock cause is usually different lock ordering: access tables and rows in one consistent order, keep transactions short, retry the whole transaction on error 1213.
- Lock wait on a hot row: shorten the transaction, move slow work outside it, update counters last.
- `SELECT ... FOR UPDATE` only when you will write; `SKIP LOCKED` / `NOWAIT` (8.0) for queue-like workers.
- READ COMMITTED reduces gap locking but changes semantics and requires row-based binlog: an owner decision.
- Never hold a transaction open across user think time or network calls.

## Anti-patterns
- Long-lived `BEGIN` from ORMs or scripts left idle; retrying only the failed statement; bulk update of millions of rows in one transaction.

## Safety
Approval before `KILL` on a transaction (rollback of a big transaction can itself take long) and before changing isolation level or timeouts globally.

## Verify
- Reproduce with two sessions or a test; after the fix, `SELECT count FROM information_schema.INNODB_METRICS WHERE name='lock_deadlocks'` (enable the counter if needed) stops rising, longest transaction age drops, and the retry path is covered by a test.
