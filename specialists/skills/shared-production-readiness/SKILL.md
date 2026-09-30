---
name: shared-production-readiness
description: "Check that a change or service is ready for production: observability, failure modes, rollout, rollback and capacity. Use when preparing a release, launching a feature, or assessing an unfamiliar service before it takes traffic."
---

# Production Readiness

## Use when
- Pre-launch review, post-incident hardening, first deployment of a service, or a risky change (schema, dependency, infra).

## Diagnose first
- Read the deploy path: build, config/secret sources, migrations order, health checks, how a bad release is reverted.
- Existing telemetry: logs with request ids, metrics (rate, errors, latency, saturation), traces, dashboards and alerts that would fire.
- Dependencies and their failure behavior: timeouts, retries, circuit breaking, what happens when each is down or slow.
- Data: backups exist and restore was tested; migrations are backward compatible with the running version.

## Decision rules
- Every external call has a timeout and bounded retries with backoff and jitter; retries only for idempotent operations.
- Rollout is reversible: feature flag or canary, expand/contract migrations, previous artifact retained. If a step cannot be undone, it needs explicit sign-off.
- Alerts on symptoms users feel (error rate, latency, saturation, queue age) with an owner and a runbook link; no alert without an action.
- Capacity: know the limit that breaks first (connections, memory, queue depth) and the graceful failure (shed load, degrade) beyond it.
- Config and secrets from the environment, validated at startup; safe defaults; no debug flags on.
- Security basics: authn/authz on new endpoints, least-privilege credentials, dependency audit.

## Anti-patterns
- "We'll add monitoring after launch"; migrations and code that must deploy atomically; unbounded queues and caches; health checks that always return OK; untested rollback.

## Safety
Production changes, flag flips and rollbacks need the owner's approval and a communicated window; do not test failure modes on production without explicit agreement.

## Verify
- Checklist with evidence per item (link, command output, test run); a staging or canary run shows the dashboards moving as expected; rollback exercised once.
