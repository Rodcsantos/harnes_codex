---
name: redis-data-modeling
description: "Model data in Redis with the right data structures, key naming and access patterns. Use when choosing between strings, hashes, sets, sorted sets, lists, streams or JSON, or when a model needs multi-key atomicity."
---

# Redis Data Modeling

## Use when
- New feature storing state in Redis; slow or memory-heavy existing model; queries need range, membership or ranking.

## Diagnose first
- List the access patterns first (read by id, by range, top-N, membership, counters) and their frequency.
- Inspect real data: `TYPE key`, `MEMORY USAGE key`, `OBJECT ENCODING key`, `HLEN/SCARD/ZCARD/LLEN/XLEN`.
- `redis-cli --bigkeys` or `--memkeys` on a replica or off-peak (they scan).

## Decision rules
- Per-entity fields: hash (small hashes use compact encodings; check `hash-max-listpack-entries` for your version). Counters: `INCR`/`HINCRBY`.
- Membership and dedup: set. Ranking, time ordering, sliding windows: sorted set with score. Queue or log semantics with consumers: stream (see redis-streams-queues).
- Secondary lookups: maintain an index key (set or sorted set of ids) updated in the same MULTI/Lua step as the write.
- Multi-key operations must live in one hash slot on Redis Cluster: use hash tags `{user:42}:...` deliberately, and only where needed.
- Bound every collection (trim, TTL, max size); design for the largest realistic tenant.
- Atomicity across keys: `MULTI/EXEC` (no rollback of logic errors) or Lua/functions; keep scripts short since they block the server.

## Anti-patterns
- One giant hash/set/list per app; JSON blobs rewritten wholesale for one field change; using `KEYS`; lists as random-access arrays; storing relational joins in Redis.

## Safety
Changing an encoding or key shape on live data needs dual-write or versioned keys and a migration plan; no bulk deletes without approval.

## Verify
- Each access pattern runs in O(1)/O(log n)/bounded O(n) as designed (check `SLOWLOG GET 10`); `MEMORY USAGE` per entity within budget; test covers concurrent writers.
