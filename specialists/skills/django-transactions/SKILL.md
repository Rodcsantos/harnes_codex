---
name: django-transactions
description: "Use Django transactions correctly: atomic blocks, on_commit hooks, locking and concurrency-safe updates. Use when writes must be all-or-nothing, race conditions or lost updates appear, or side effects fire before commit."
---

# Django Transactions

## Use when
- Multi-step writes, double-spend or counter races, emails/tasks triggered before data is committed, `TransactionManagementError`, deadlocks.

## Diagnose first
- `DATABASES['default']['ATOMIC_REQUESTS']` and `AUTOCOMMIT`, and the isolation level in `OPTIONS`.
- Find write sequences without `transaction.atomic`, and side effects (tasks, emails, HTTP) inside atomic blocks.
- Reproduce races with two threads/processes in a test using `TransactionTestCase`.
- Database-side lock evidence: see mysql/postgres transactions-locking skills.

## Decision rules
- Wrap dependent writes in `with transaction.atomic():`; nested atomic creates savepoints; catching `IntegrityError` inside must happen outside the atomic block that failed (or use a nested block).
- Side effects after commit: `transaction.on_commit(lambda: task.delay(...))`; in tests `TestCase` needs `captureOnCommitCallbacks(execute=True)`.
- Prevent lost updates: `select_for_update()` inside `atomic` for read-modify-write, or atomic SQL updates with `F()` expressions (`update(count=F('count')+1)`).
- Lock in a consistent order to avoid deadlocks; keep blocks short; retry on deadlock/serialization errors.
- `ATOMIC_REQUESTS=True` is simple but holds a transaction for the whole request; opt out for slow views.
- `select_for_update(skip_locked=True)` for workers on databases that support it.

## Anti-patterns
- Network calls inside `atomic`; swallowing exceptions inside a transaction and continuing; `save()` read-modify-write without locks; assuming `TestCase` transactions reveal commit behavior.

## Safety
Changing isolation level or `ATOMIC_REQUESTS` globally affects all code paths: approval and staged rollout required.

## Verify
- Concurrency test (threads with `TransactionTestCase`) proves no lost update; failure injection shows full rollback; on_commit side effect fires once, only after commit.
