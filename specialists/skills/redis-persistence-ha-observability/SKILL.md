---
name: redis-persistence-ha-observability
description: "Configure Redis persistence (RDB/AOF), replication, Sentinel/Cluster failover and monitoring. Use when durability, failover behavior, replication lag or restart time must be defined or has failed."
---

# Redis Persistence HA Observability

## Use when
- Choosing durability settings, data lost after restart, failover misbehaves, replicas lag, or setting up alerts.

## Diagnose first
- `INFO persistence`: `rdb_last_bgsave_status`, `aof_enabled`, `aof_last_write_status`, `loading`; `CONFIG GET save appendonly appendfsync`.
- `INFO replication`: role, `connected_slaves`, `master_repl_offset` vs replica offset, `repl_backlog_*`.
- Sentinel/Cluster: `SENTINEL masters`, `CLUSTER INFO`, `CLUSTER NODES` (state ok, slots covered).
- `INFO stats`: `rejected_connections`, `sync_full`, `sync_partial_ok`; `LATENCY LATEST`.

## Decision rules
- Cache only: persistence can be off. Durable data: AOF (`appendfsync everysec` is the usual balance, `always` for strictest) plus periodic RDB for backups.
- Replication is asynchronous: acknowledged writes can be lost on failover. `WAIT` reduces but does not eliminate the window; `min-replicas-to-write` limits writes when replicas are missing.
- Repeated full syncs mean the backlog is too small (`repl-backlog-size`) or replicas are too slow.
- Sentinel needs an odd quorum of independent hosts; clients must be sentinel/cluster-aware and re-resolve the primary.
- Watch: memory, evictions, connected clients, slowlog, replication offset lag, fork time (`latest_fork_usec`), persistence status.
- Back up RDB/AOF off-host and test restore time.

## Anti-patterns
- Assuming replicas are backups (deletes replicate); persistence on the same disk as heavy logs; sentinels co-located with the primary; alerting only on "up".

## Safety
Approval before: `FAILOVER`/`SENTINEL failover`, `REPLICAOF`, `CONFIG SET appendonly`, `BGREWRITEAOF` on constrained hosts, `DEBUG`, deleting AOF/RDB files.

## Verify
- Restore a backup on a scratch instance and compare key counts; controlled failover in staging with measured downtime and no client errors beyond the target; alerts fire in a drill.
