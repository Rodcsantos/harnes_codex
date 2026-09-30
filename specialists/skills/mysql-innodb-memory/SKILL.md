---
name: mysql-innodb-memory
description: "Tune InnoDB buffer pool, redo, flushing and connection memory in MySQL. Use when memory pressure, low buffer pool hit rate, checkpoint stalls, swapping or OOM kills are observed."
---

# MySQL InnoDB Memory

## Use when
- High disk reads for a hot dataset, swapping, mysqld killed by OOM, periodic write stalls.
- Sizing a new server or changing `innodb_*` or per-connection buffers.

## Diagnose first
- `SELECT @@innodb_buffer_pool_size/1024/1024/1024 AS bp_gb, @@innodb_redo_log_capacity, @@max_connections, @@innodb_flush_log_at_trx_commit, @@innodb_flush_method;` (`innodb_redo_log_capacity` exists from 8.0.30; older uses `innodb_log_file_size` x files).
- Hit rate: `SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_read%';` compare `reads` (disk) with `read_requests`.
- `SHOW ENGINE INNODB STATUS\G`: log sequence and checkpoint age, pending writes, buffer pool section.
- Host: `free -m`, swap use, `dmesg | grep -i oom`.

## Decision rules
- Dedicated server: buffer pool commonly 50-75% of RAM, leaving room for OS cache, connections and other buffers. Confirm against the working set, not a fixed percentage.
- Worst-case memory is buffer pool + `max_connections` x (sort/join/read/tmp buffers). Raise per-session buffers per query, never globally.
- Checkpoint stalls with heavy writes: redo log too small. Bigger redo trades crash-recovery time for smoother flushing.
- `innodb_flush_log_at_trx_commit=1` and `sync_binlog=1` are the durable settings; relaxing them is a durability decision for the owner, not a tuning trick.
- `innodb_flush_method=O_DIRECT` on Linux avoids double buffering (confirm for the storage).

## Anti-patterns
- Buffer pool sized to 90% of RAM; huge `sort_buffer_size` or `tmp_table_size` globally; tuning from a status snapshot taken minutes after restart.

## Safety
`innodb_buffer_pool_size` is resizable online in chunks but still affects a live server; redo and flush settings need change window and approval. Keep the previous values written down.

## Verify
- Disk reads per second and hit rate before/after under the same load; no swap; p95 write latency and checkpoint age stable; memory headroom at peak connections.
