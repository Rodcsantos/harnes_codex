---
name: redis-locking-rate-limit
description: "Implement Redis distributed locks and rate limiters correctly with atomic operations. Use when adding mutual exclusion, idempotency guards, or request throttling backed by Redis."
---

# Redis Locks and Rate Limits

## Use when
- Preventing duplicate job runs, guarding a critical section across processes, limiting API calls per user/IP/key.

## Diagnose first
- Is a lock really needed? Prefer database constraints, idempotency keys or a single consumer per partition when they solve it.
- Check failure model: what happens if the holder crashes, pauses (GC), or the Redis primary fails over?
- Existing code: are `SETNX` + `EXPIRE` done as two commands (race)?

## Decision rules
- Acquire: one command `SET lock:key <unique-token> NX PX <ttl>`. Release: Lua compare-and-delete (`if GET==token then DEL`), never plain `DEL`.
- TTL must exceed worst-case work time; long work needs a renewal (only by the owner, checking the token) or a fencing token checked by the protected resource.
- A single-Redis lock is best-effort, not a strict mutual exclusion guarantee (failover can lose it; pauses can outlive the TTL). For correctness-critical cases use fencing tokens at the resource or a consensus system.
- Rate limit: fixed window (`INCR` + `EXPIRE` on first hit, set atomically via Lua) is simplest; sliding window or token bucket via sorted set/Lua for smoother limits.
- Make limiter and lock scripts atomic with Lua or `SET ... NX EX`; return remaining/reset values for clients.
- Fail-open or fail-closed on Redis errors: decide explicitly per endpoint.

## Anti-patterns
- Lock without token or TTL; `EXPIRE` after `SETNX` as separate calls; per-request `KEYS` scans; limiter keys with unbounded cardinality and no TTL.

## Safety
Force-deleting lock keys or resetting limiter keys in production needs approval and knowledge of who holds them.

## Verify
- Concurrent test (many workers) proves only one holder at a time and safe release after crash/timeouts; limiter test at boundary counts; behavior on Redis outage is exercised.
