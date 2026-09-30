---
name: redis-cache-design
description: "Design Redis caches: key schema, TTLs, patterns and stampede protection. Use when adding or fixing a cache layer, hit rate is low, stale data is served, or expiry causes load spikes."
---

# Redis Cache Design

## Use when
- Introducing caching for a slow read path, choosing TTLs, or debugging thundering herds and stale reads.

## Diagnose first
- `redis-cli INFO stats | grep -E 'keyspace_(hits|misses)|expired_keys|evicted_keys'`: hit ratio = hits/(hits+misses).
- `redis-cli INFO keyspace` and `INFO memory` (used vs `maxmemory`, `maxmemory_policy`).
- Sample keys with `SCAN 0 MATCH prefix:* COUNT 100` (never `KEYS *` on production) and `TTL key` / `OBJECT FREQ` where available.
- Measure the uncached path first: is the source really slow, and how often is each key read?

## Decision rules
- Default pattern is cache-aside: read cache, on miss load and `SET key val EX ttl`. Write-through/write-behind only with a clear consistency owner.
- Key schema: `service:entity:id:version` with a stable prefix; put a schema version in the key so deployments can invalidate by changing it.
- Always set a TTL with jitter (for example base +/- 10-20%) so keys do not expire together.
- Stampede on hot key expiry: single-flight lock (`SET lock NX PX`), serve stale while one worker refreshes, or refresh ahead of expiry.
- Cache negative results briefly to stop repeated misses for absent data.
- Store compact values (ids, small JSON) rather than whole object graphs; big values raise latency and memory.

## Anti-patterns
- Caching without measuring; no TTL; unbounded key cardinality (per-user-per-filter permutations); caching errors as valid data; treating the cache as the source of truth.

## Safety
Never `FLUSHALL`/`FLUSHDB` or mass `DEL` on shared instances without approval; prefer targeted deletes and versioned keys. Key format changes must roll out compatibly across app versions.

## Verify
- Hit ratio and origin load before/after; p95 latency of the endpoint; no synchronized expiry spikes; memory stays under limit at peak.
