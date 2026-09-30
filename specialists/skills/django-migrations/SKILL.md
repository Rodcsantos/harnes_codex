---
name: django-migrations
description: "Create, review and apply Django migrations safely, including data migrations and zero-downtime changes. Use when models change, migrations conflict, a migration is slow or risky, or squashing/rollback is needed."
---

# Django Migrations

## Use when
- `makemigrations` output needs review, merge conflicts in migration graph, large-table schema change, data backfill, or reverse migration required.

## Diagnose first
- `python manage.py showmigrations --plan | tail -20`, `python manage.py makemigrations --check --dry-run`.
- `python manage.py sqlmigrate app 0042` to read the SQL Django will run; look for table rewrites and locks.
- Multiple leaf nodes: `python manage.py makemigrations --merge` is needed only when two branches diverge.
- Database and version: `python -m django --version` and engine (behavior differs, for example `ALTER` locking).

## Decision rules
- Never edit a migration that has been applied anywhere shared; add a new one.
- Separate schema and data migrations; data migrations use `apps.get_model` (historical models) and `RunPython` with a reverse function or `RunPython.noop`.
- Zero-downtime pattern: expand (add nullable column/new table) -> deploy code that writes both -> backfill in batches -> switch reads -> contract (drop) in a later release.
- Adding NOT NULL or a default on a big table can rewrite it; check `sqlmigrate` output for your database. Renames: `RenameField` is cheap in SQL but breaks running old code; stage it.
- Postgres: create indexes concurrently with `AddIndexConcurrently` (`atomic = False`) from `django.contrib.postgres.operations`.
- Squash only after all environments have applied the old chain.

## Anti-patterns
- Importing current models in `RunPython`; giant single-transaction backfills; committing auto-generated migrations without reading them; dropping a column in the same release that stops using it.

## Safety
Applying migrations to production, `migrate app zero`, `--fake`, or deleting migration files needs approval and a backup/rollback plan.

## Verify
- Migrate forward and backward on a copy of production-size data with timing; `makemigrations --check` is clean; tests pass on a fresh database and on an upgraded one.
