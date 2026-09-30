---
name: mysql-slow-query-diagnostics
description: "Find and rank MySQL slow queries with the slow log, digests and plans. Use when latency or load rises with no known culprit, or before choosing which query to optimize first."
---

# MySQL Slow Query Diagnostics

## Use when
- p95 latency or CPU increased; a deploy changed load; a ranked list of worst queries is needed.

## Diagnose first
- Settings: `SELECT @@slow_query_log, @@long_query_time, @@log_queries_not_using_indexes, @@slow_query_log_file;`
- Digest ranking: `SELECT DIGEST_TEXT, COUNT_STAR, ROUND(SUM_TIMER_WAIT/1e12,2) total_s, ROUND(AVG_TIMER_WAIT/1e9,1) avg_ms, SUM_ROWS_EXAMINED, SUM_ROWS_SENT FROM performance_schema.events_statements_summary_by_digest ORDER BY SUM_TIMER_WAIT DESC LIMIT 10;`
- Or aggregate the file: `pt-query-digest slow.log` / `mysqldumpslow -s t`.
- Running now: `SELECT * FROM sys.processlist WHERE command='Query' ORDER BY time DESC;`

## Decision rules
- Rank by total time (frequency x latency), not by the single slowest execution.
- Low `long_query_time` briefly (for example 0.2-1 s) during the incident, then restore; leaving it at 0 floods disk.
- Rows examined/sent ratio above ~100 points to indexing; high `tmp_disk_tables` or sort merge passes point to sort/group design.
- Lock waits show as long `Query_time` with tiny `Lock_time`/rows: switch to locking analysis (`sys.innodb_lock_waits`).
- Digest counters reset on restart or `TRUNCATE`: compare like with like.

## Anti-patterns
- Optimizing the query that ran once in 10 s while a 5 ms query runs 2M times; changing several things at once; diagnosing on a cold cache.

## Safety
Changing `slow_query_log` settings is a global change: note prior values and revert. Do not run diagnostics that scan large tables on a busy primary.

## Verify
- Same digest ranking after the fix shows lower total time; before/after numbers recorded from the same window and load.
