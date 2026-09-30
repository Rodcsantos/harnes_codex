---
name: php-performance-debugging
description: "Profile and debug PHP performance and runtime problems: OPcache, FPM, slow requests, memory and profilers. Use when PHP requests are slow, workers exhaust, memory limits hit, or production errors are hard to reproduce."
---

# PHP Performance Debugging

## Use when
- High TTFB, FPM `max_children reached`, memory exhausted, slow scripts, or intermittent 500s.

## Diagnose first
- Runtime: `php -v; php -m | grep -iE "opcache|xdebug|pcntl"`; `php -i | grep -E "opcache.enable|memory_limit|max_execution_time"`. Xdebug slows production heavily: it should be off there.
- FPM: pool config (`pm`, `pm.max_children`), status page (`pm.status_path`), `slowlog` with `request_slowlog_timeout` for stack traces of slow requests.
- Profilers: Blackfire, XHProf/Tideways, or Xdebug profiler in staging; look at inclusive time and call counts.
- Logs: PHP error log and framework logs correlated with a request id; database slow log for query time.

## Decision rules
- Most slowness is I/O: fix query count/slow queries, remote calls (timeouts, parallelism, caching) before micro-optimizing PHP.
- OPcache on in production (`opcache.validate_timestamps=0` with deploy-time reset, confirm your deploy process), enough `opcache.memory_consumption`, and preloading only if measured.
- Size `pm.max_children` from memory: available RAM / average worker RSS; too many children causes swapping.
- Memory growth in long-running workers (queues, Octane/Swoole): avoid static caches, free large arrays, use generators/`chunk`; restart workers after N jobs.
- Cache expensive results (APCu, Redis, framework cache) with explicit invalidation.
- Autoload optimization: `composer install --optimize-autoloader --classmap-authoritative` in production builds.

## Anti-patterns
- Enabling Xdebug or verbose logging in production; raising `memory_limit` to hide leaks; guessing without a profile; unbounded `foreach` over ORM collections.

## Safety
Changing FPM/OPcache settings restarts workers and affects live traffic: reload in a window, keep the previous config, get approval. Profilers on production only with sampling and approval.

## Verify
- Profile or slowlog shows the hotspot reduced; p95 latency and error rate improved under similar load; memory per worker stable over time.
