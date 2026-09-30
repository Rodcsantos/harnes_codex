---
name: redis-streams-queues
description: "Build reliable queues and event flows on Redis Streams, lists or pub/sub. Use when choosing a queue primitive, consumers lose or duplicate messages, or pending entries and stream size grow."
---

# Redis Streams and Queues

## Use when
- Background jobs, event fan-out, or worker pools using Redis; messages stuck, retried forever or lost.

## Diagnose first
- Which primitive is used and what delivery guarantee is required (at-most-once, at-least-once).
- `XLEN s`, `XINFO STREAM s`, `XINFO GROUPS s`, `XINFO CONSUMERS s g`, `XPENDING s g` (count, min/max id, per consumer).
- For lists: `LLEN`, and check whether workers use `BRPOPLPUSH`/`BLMOVE` for reliable handoff.

## Decision rules
- Pub/sub: fire-and-forget, no persistence or replay. Lists: simple queues, reliable only with a processing list. Streams: persistent log with consumer groups, acknowledgements and replay: the default for reliable work.
- Consumer group flow: `XGROUP CREATE`, read with `XREADGROUP ... >`, process, then `XACK`. Unacked entries stay in the PEL.
- Recover crashed consumers with `XAUTOCLAIM` (or `XCLAIM`) after an idle threshold; count deliveries and move poison messages to a dead-letter stream after N attempts.
- Delivery is at-least-once: handlers must be idempotent (idempotency key or upsert).
- Bound the stream: `XADD ... MAXLEN ~ N` or `MINID` trimming, chosen with retention needs; approximate trimming is cheaper.
- Scale by adding consumers to the group; partition streams by key when ordering per key matters.

## Anti-patterns
- Acknowledging before processing; never claiming pending entries; unbounded streams; using pub/sub for jobs that must not be lost; large payloads instead of references.

## Safety
`XTRIM`, `XGROUP DESTROY`, `XGROUP SETID`, `DEL` on a stream drop or replay data: approval required. Replays need consumers that are idempotent.

## Verify
- Kill a consumer mid-message and confirm the message is reclaimed and processed once effectively; `XPENDING` drains to zero under load; stream length stays bounded; dead-letter path tested.
