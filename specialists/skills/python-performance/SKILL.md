---
name: python-performance
description: "Profile and speed up Python code with measurements, algorithmic fixes and the right concurrency model. Use when Python code is slow, memory-hungry or CPU-bound, before any optimization."
---

# Python Performance

## Use when
- High latency or CPU, slow batch jobs, memory growth, or a proposed "optimization" without numbers.

## Diagnose first
- Time: `python -X importtime -c 'import app'` for startup; `python -m cProfile -o out.prof script.py` then `pstats`/`snakeviz`; `py-spy record -o flame.svg --pid <pid>` for a running process.
- Micro: `python -m timeit -s "setup" "stmt"`; benchmark with realistic input sizes, several runs.
- Memory: `tracemalloc` snapshots, `sys.getsizeof` for shallow sizes, `memray` if available.
- Determine I/O-bound vs CPU-bound: wait time in the profile vs CPU time.

## Decision rules
- Measure first, fix the top hotspot only, re-measure. Most wins are algorithmic: better complexity, fewer passes, caching (`functools.lru_cache`), batching I/O.
- Right data structure: `set`/`dict` for membership and lookups, `collections.deque` for queues, generators/iterators for streaming instead of building big lists, `str.join` for concatenation.
- I/O-bound: async or threads; CPU-bound: `multiprocessing`/`concurrent.futures.ProcessPoolExecutor` or vectorized libraries (NumPy, pandas), or a compiled extension. Note that free-threaded builds are version-specific: confirm before relying on them.
- Move invariants out of loops, avoid repeated attribute lookups only when profiling shows it matters.
- Database/network calls dominate most services: fix query count and batching before touching Python code.

## Anti-patterns
- Optimizing without profiling; micro-optimizing cold code; premature multiprocessing with heavy pickling; caching unbounded results.

## Safety
Caching and concurrency changes can alter correctness (staleness, races) and memory: keep behavior tests, bound caches, and get approval for production rollout.

## Verify
- Benchmark before/after on the same data with variance noted; profile shows the hotspot reduced; memory peak not worse; outputs identical.
