---
name: python-asyncio
description: "Write and debug Python asyncio code: tasks, cancellation, blocking calls, concurrency limits and timeouts. Use when async code hangs, leaks tasks, blocks the event loop, or mixes sync and async incorrectly."
---

# Python Asyncio

## Use when
- Hangs or slowness in async services, `Task was destroyed but it is pending`, un-awaited coroutines, blocking libraries inside async handlers, unbounded concurrency.

## Diagnose first
- `python -X dev` and `PYTHONASYNCIODEBUG=1` (or `asyncio.run(main(), debug=True)`): slow callback warnings, un-awaited coroutine warnings.
- Find blocking calls in async paths: `requests`, `time.sleep`, sync DB drivers, heavy CPU, file I/O: `grep -rn "requests\.\|time.sleep" --include=*.py`.
- Dump tasks when hung: `asyncio.all_tasks()` and their stacks; `py-spy dump --pid <pid>`.
- Python version (`TaskGroup` and `asyncio.timeout` need 3.11+).

## Decision rules
- Run independent I/O concurrently with `asyncio.gather` or, on 3.11+, `asyncio.TaskGroup` (structured: failures cancel siblings). Keep references to tasks created with `create_task`.
- Bound concurrency with `asyncio.Semaphore` or a queue with fixed workers; never spawn one task per item of an unbounded input.
- Timeouts everywhere on external I/O: `asyncio.timeout()` (3.11+) or `asyncio.wait_for`.
- Blocking or CPU-bound work: `await asyncio.to_thread(fn)` or a process pool; do not call it directly in a coroutine.
- Cancellation: let `CancelledError` propagate; clean up in `finally`; do not swallow it with bare `except`.
- Use async-native clients (httpx, asyncpg, aiohttp) inside async code; one event loop per process; never call `asyncio.run` inside a running loop.

## Anti-patterns
- Fire-and-forget `create_task` without storing the reference; `await` in a tight loop when calls are independent; sharing an async client across loops; `loop.run_until_complete` inside async code.

## Safety
Changing concurrency limits or timeouts alters load on downstream services: tune with metrics and approval for production.

## Verify
- Test with `pytest-asyncio`/`anyio`: cancellation, timeout and failure paths; measure latency and concurrency before/after; debug mode shows no slow callbacks or un-awaited coroutines.
