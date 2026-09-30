---
name: django-models
description: "Design Django models, constraints, managers and relations that keep data valid and queries simple. Use when creating or changing models, fields, relations, Meta options or custom managers."
---

# Django Models

## Use when
- New entities, field type choices, uniqueness/validation rules, deletion behavior, or repeated query logic that belongs in a manager.

## Diagnose first
- `python manage.py inspectdb` only for legacy DBs; otherwise read existing models and `Meta` conventions.
- `python manage.py sqlmigrate` after a change to see the DDL; `python manage.py check`.
- Look for missing indexes on filtered/ordered fields: `grep -rn "filter(\|order_by(" app/ | head`.

## Decision rules
- Put invariants in the database with `Meta.constraints` (`UniqueConstraint`, `CheckConstraint`) plus model `clean()` for friendly errors; validators alone are not enforcement.
- `on_delete` is a business decision: `PROTECT` for data that must not vanish, `CASCADE` for owned children, `SET_NULL` only with `null=True`.
- `null=True` on strings is usually wrong (use `blank=True` with empty string); nullable only when absence is meaningful.
- Use `TextChoices`/`IntegerChoices` for enumerations; `DecimalField` for money; `DateTimeField` with `USE_TZ=True`.
- Reusable filters as `QuerySet` methods exposed through `Manager.from_queryset`; default managers should not hide rows surprisingly.
- Add `db_index`/`Meta.indexes` for real query patterns, and `related_name` on relations for clarity.
- Avoid `save()` overrides for logic that must run on `bulk_create`/`update` (they bypass it).

## Anti-patterns
- Generic FKs everywhere; JSONField as a schema escape hatch for core fields; many-to-many without an explicit `through` when the link has attributes; business logic in signals.

## Safety
Field type changes, renames and constraint additions on populated tables need migration review (see django-migrations) and approval.

## Verify
- Constraint tests (violation raises `IntegrityError`), `makemigrations --check`, `sqlmigrate` reviewed, model tests pass.
