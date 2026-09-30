---
name: mysql-backup-replication
description: "Design and verify MySQL backups, point-in-time recovery and replication health. Use when a backup or restore is planned, replica lag or errors appear, or recovery objectives (RPO/RTO) are undefined."
---

# MySQL Backup and Replication

## Use when
- Choosing or auditing a backup method, or nobody has restore-tested it.
- `Seconds_Behind_Source` grows, a replica thread stopped, or GTID sets diverge.
- A point-in-time recovery or a new replica build is needed.

## Diagnose first
- `SELECT @@version, @@log_bin, @@binlog_format, @@gtid_mode, @@sync_binlog, @@innodb_flush_log_at_trx_commit, @@binlog_expire_logs_seconds;`
- On the replica: `SHOW REPLICA STATUS\G` (older: `SHOW SLAVE STATUS`): both IO/SQL threads, lag, `Last_IO_Error`, `Last_SQL_Error`, retrieved vs executed GTID sets.
- `SELECT * FROM performance_schema.replication_applier_status_by_worker WHERE LAST_ERROR_NUMBER<>0;`
- Inventory: last good backup time, size, tool, storage location, last restore test date.

## Decision rules
- Small or portable data: logical dump. Large data or tight RTO: physical (XtraBackup, MySQL Enterprise Backup, clone plugin); restore is far faster.
- InnoDB-only consistent dump: `mysqldump --single-transaction --routines --triggers --events --source-data=2` (older flag `--master-data=2`). MyISAM tables need locks.
- PITR = full backup + binlogs replayed with `mysqlbinlog --start-position/--stop-datetime`. It only works if binlog is on and retained longer than the backup interval.
- Prefer GTID with auto-positioning and row-based binlog; they make failover and re-pointing predictable.
- Lag with a single applier: enable multithreaded apply (`replica_parallel_workers`, `replica_parallel_type=LOGICAL_CLOCK`; pre-8.0.26 names use `slave_`). Other causes: huge transactions, tables without primary key on a row-based replica.

## Anti-patterns
- Backups on the same host or disk as the data; backups never restored.
- Skipping errors with `sql_replica_skip_counter` to "get green": it hides divergence.
- Reading from a replica as if it had zero lag.

## Safety
Ask before: `STOP/RESET REPLICA`, `CHANGE REPLICATION SOURCE`, skipping or injecting empty GTIDs, `PURGE BINARY LOGS`, any restore over a live database. Restore into a scratch instance first; keep the old data until the new one is verified.

## Verify
- Restore to scratch, compare `CHECKSUM TABLE` or pt-table-checksum on critical tables, record measured RTO.
- Replica: both threads `Yes`, lag trending to 0, executed GTID set catches up to the source.
