---
name: redis-hotkeys-bigkeys
description: "Find and fix Redis hot keys and big keys that cause latency spikes, memory imbalance or blocking. Use when Redis latency spikes, one shard or CPU core is saturated, or DEL/expire of one key stalls the server."
---

# Redis Hot Keys and Big Keys

## Use when
- p99 spikes, `SLOWLOG` entries on O(N) commands, uneven memory or traffic across cluster nodes, or slow `DEL` of a large key.

## Diagnose first
- `redis-cli SLOWLOG GET 20` and `LATENCY DOCTOR` (if latency monitoring is enabled).
- `redis-cli --bigkeys` and `--memkeys` (they SCAN; run against a replica or off-peak). Confirm with `MEMORY USAGE key SAMPLES 0`, `HLEN/SCARD/ZCARD/LLEN`.
- Hot keys: `redis-cli --hotkeys` requires an LFU `maxmemory-policy`; otherwise sample with `MONITOR` for seconds only (it is expensive) or use client-side counters.
- `INFO commandstats` for the calls and usec per command.

## Decision rules
- Big collection: shard by bucket (`key:{id % N}`), trim, or paginate with `SSCAN/HSCAN/ZRANGE` ranges instead of fetching everything.
- Delete large keys with `UNLINK` (asynchronous free), and expire them progressively; avoid `DEL` on multi-million element keys.
- Hot read key: local in-process cache with short TTL, or replicate the value across suffixed copies (`key:0..k`) and pick randomly.
- Hot write counter: split into shards and sum on read, or batch increments.
- Replace O(N) commands in request paths (`SMEMBERS`, `HGETALL`, `LRANGE 0 -1`) with bounded reads.

## Anti-patterns
- Running `--bigkeys` or `MONITOR` on a busy primary; fixing symptoms with bigger instances; unbounded lists and sets.

## Safety
Do not `DEL`, `FLUSH*`, or rewrite a live big key without approval and a plan for readers during the change.

## Verify
- `SLOWLOG` no longer shows the command, p99 back to baseline, distribution of memory/ops across nodes evened out, largest key size below the agreed cap.
