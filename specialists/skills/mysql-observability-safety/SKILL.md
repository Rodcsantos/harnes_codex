---
name: mysql-observability-safety
description: "Gather MySQL evidence with performance_schema and sys and apply operational safety rules. Use when investigating a live incident, before any DDL or bulk write, or when defining monitoring for a MySQL instance."
---

# MySQL Observability Safety

## Use when
- Live slowness or saturation with unknown cause.
- Before running DDL, mass UPDATE/DELETE, or granting privileges on production.

## Diagnose first
- Active work: `SELECT * FROM sys.processlist WHERE command<>'Sleep' ORDER BY time DESC LIMIT 20;`
- Top statements: `SELECT * FROM sys.statement_analysis ORDER BY total_latency DESC LIMIT 10;`
- Waits and I/O: `SELECT * FROM sys.waits_global_by_latency LIMIT 10;` `SELECT * FROM sys.io_global_by_file_by_latency LIMIT 10;`
- Connections: `SHOW GLOBAL STATUS LIKE 'Threads_%'; SHOW GLOBAL STATUS LIKE 'Aborted_%';`
- Confirm `performance_schema=ON` and the instruments you need are enabled.

## Decision rules
- Read-only first: collect, then decide. Prefer a replica for heavy diagnostic queries.
- Before bulk writes: run the equivalent `SELECT COUNT(*)` with the same WHERE, note the count, chunk the change (for example 1-5k rows per transaction) with a pause, and keep a way back.
- Wrap a risky UPDATE/DELETE in an explicit transaction only when you will review the affected rows before `COMMIT`.
- Least privilege: separate read-only, app and admin accounts; avoid `%` hosts and `GRANT ALL`.
- Metadata locks queue behind long transactions: check `performance_schema.metadata_locks` and long-running trx before DDL.

## Anti-patterns
- `KILL` without knowing what the connection holds; diagnostics that themselves scan large tables on the primary; enabling every instrument permanently.

## Safety
Approval required for: DDL, `KILL`, bulk DML, `SET GLOBAL`, privilege changes, `FLUSH`, `RESET`. State expected impact and rollback before running.

## Verify
- The suspected cause is confirmed by at least two independent signals (statement stats and waits, for example).
- After a change, the same queries show the metric moved and no new errors in the error log.
