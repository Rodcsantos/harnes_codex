---
name: redis-memory-eviction
description: "Configure Redis maxmemory, eviction policy and memory use to avoid OOM and data loss. Use when Redis approaches its memory limit, evicts unexpectedly, returns OOM errors or fragments memory."
---

# Redis Memory and Eviction

## Use when
- `used_memory` near `maxmemory`, `evicted_keys` rising, `OOM command not allowed`, RSS much larger than data, or planning capacity.

## Diagnose first
- `INFO memory`: `used_memory`, `used_memory_rss`, `mem_fragmentation_ratio`, `maxmemory`, `maxmemory_policy`.
- `INFO stats`: `evicted_keys`, `expired_keys`; `INFO keyspace`: keys with vs without TTL.
- `MEMORY DOCTOR`, `MEMORY STATS`, `redis-cli --memkeys` (SCAN-based; off-peak).
- Host: total RAM, other processes, and copy-on-write headroom for fork-based persistence (RDB/AOF rewrite).

## Decision rules
- Pure cache: `allkeys-lru` or `allkeys-lfu`. Mixed cache plus durable data: `volatile-*` policies only evict keys with TTL, so persistent keys can fill memory; separate instances are cleaner.
- `noeviction` is right for a primary store or queue: writes fail loudly instead of losing data. Handle OOM errors in the app.
- Set `maxmemory` below physical RAM leaving room for fork COW, buffers and replication backlog.
- Reduce footprint: shorter keys and values, compact encodings for small collections, TTLs, trimming streams/lists, avoiding JSON blobs.
- Fragmentation ratio well above ~1.5: consider `activedefrag` (verify support and CPU cost) or restart during a window.

## Anti-patterns
- No `maxmemory` on a shared host; `volatile-lru` when most keys lack TTL; relying on eviction to hide unbounded growth.

## Safety
`CONFIG SET maxmemory*` on a live instance can trigger mass eviction immediately; test the value and get approval. Never `FLUSHALL` to free memory without approval.

## Verify
- Memory stabilizes below the limit with headroom at peak, `evicted_keys` matches intent, no OOM errors, persistence forks succeed.
