---
name: postgres-backup-pitr-replication
description: "Design and verify PostgreSQL backups, WAL archiving, point-in-time recovery and replication. Use when planning backups or restores, a replica lags or breaks, WAL fills the disk, or RPO/RTO are undefined."
---

# PostgreSQL Backup PITR Replication

## Use when
- Choosing a backup method, restoring to a point in time, building or repairing a replica, or WAL/disk growth from replication slots.

## Diagnose first
- `SELECT version(); SHOW wal_level; SHOW archive_mode; SHOW archive_command; SHOW max_wal_senders;`
- `SELECT * FROM pg_stat_archiver;` (failed_count, last_failed_time) and `SELECT * FROM pg_stat_replication;` (state, sent/write/flush/replay lag).
- Slots holding WAL: `SELECT slot_name, active, restart_lsn, pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) AS retained FROM pg_replication_slots;`
- Replica: `SELECT pg_is_in_recovery(), now()-pg_last_xact_replay_timestamp() AS replay_delay;`
- Inventory: tool (pgBackRest, Barman, pg_basebackup), last full, last restore test, WAL retention.

## Decision rules
- `pg_dump` is logical (single database, portable, slow to restore at scale). PITR needs a physical base backup plus continuous WAL archiving.
- Recovery to a time or LSN: restore base backup, set `restore_command` and a recovery target, then `recovery_target_action`; confirm with the tool's documented procedure for the installed major version.
- An inactive replication slot retains WAL forever: drop it or fix the consumer, and consider `max_slot_wal_keep_size`.
- Streaming replica lag: check network, replica I/O, long queries conflicting with replay (`max_standby_streaming_delay`, `hot_standby_feedback` trade-off: feedback causes bloat on the primary).
- Synchronous replication trades write latency and availability for zero data loss; decide by RPO, not by default.

## Anti-patterns
- Archiving to the same disk; `archive_command` that returns success without copying; never testing a restore; deleting files from `pg_wal` by hand.

## Safety
Approval before: promoting a replica, dropping slots, changing `archive_command`, `pg_resetwal`, restoring over a live cluster, `pg_rewind`. Restore into a separate host first.

## Verify
- Restore test reaches the target time, `SELECT` on known rows matches, application smoke test passes, RTO measured. `pg_stat_archiver.failed_count` stable; replay lag near zero.
