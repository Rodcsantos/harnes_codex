---
name: redis-invalidation
description: "Design cache invalidation for Redis: TTL, explicit deletes, versioned keys and event-driven purge. Use when users see stale data, invalidation races appear after writes, or purge logic is scattered."
---

# Redis Cache Invalidation

## Use when
- Stale reads after updates, cache and database disagree, or writers must invalidate many related keys.

## Diagnose first
- Map write paths: every place that changes the source data, and every cache key derived from it.
- Reproduce the race: read-miss loads old data while a write commits and deletes, then the reader sets the stale value.
- `TTL` on affected keys and `INFO stats` for `expired_keys` to see whether expiry is the only safety net.

## Decision rules
- TTL is the backstop; explicit invalidation is the speed-up. Always have both.
- Delete-after-commit (not before): invalidate in the same code path after the DB transaction commits, or use an outbox/CDC event so a failed publish is retried.
- Race between reader refill and writer delete: short TTL on refills, versioned values, or set-if-newer using a version/timestamp compare in Lua.
- Many related keys: version namespace (`user:42:v7:*`, bump `v` on change) rather than scanning and deleting patterns.
- Cluster/multi-node local caches: publish an invalidation message (pub/sub is fire-and-forget; use streams if delivery matters).
- Prefer invalidating derived data lazily on read when correctness allows.

## Anti-patterns
- Deleting by `KEYS pattern` on production; invalidating before the transaction commits; relying on TTL alone for correctness-sensitive data; forgetting derived aggregates.

## Safety
Pattern deletes on shared instances need approval; use `SCAN` + `UNLINK` in batches with limits, or versioned keys instead.

## Verify
- A test that updates data and asserts the next read is fresh, including the concurrent refill race; stale-read reports stop; invalidation event failures are alerted.
