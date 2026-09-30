---
name: django-orm-optimization
description: "Optimize Django ORM queries: N+1, select_related/prefetch_related, indexing, bulk operations and pagination. Use when a view or API is slow, query counts are high, or memory blows up loading large querysets."
---

# Django ORM Optimization

## Use when
- Many queries per request, slow list endpoints, admin slowness, large exports, or `.count()`/`len()` misuse.

## Diagnose first
- Count queries: `django.test.utils.CaptureQueriesContext` or `assertNumQueries` in a test; in dev use `django-debug-toolbar` or `connection.queries` with `DEBUG=True`.
- Inspect one query: `print(qs.query)` and `qs.explain(analyze=True)` (EXPLAIN executes the query: safe SELECTs only).
- Find loops touching relations: attribute access on FK/related managers inside `for` loops or serializers.
- Slow ones from the database: see mysql/postgres skills for `pg_stat_statements`/slow log.

## Decision rules
- FK/one-to-one accessed in loops: `select_related`. Reverse FK/M2M: `prefetch_related` (use `Prefetch(queryset=...)` to filter or `only`).
- Need few columns: `only()`/`defer()`/`values()`/`values_list()`; do not load full objects for aggregates.
- Aggregates in the database: `annotate`, `aggregate`, `Count`, `Sum`, `Exists()` subqueries instead of Python loops; `qs.exists()` not `if qs:`; `qs.count()` not `len(qs)` when rows are not needed.
- Bulk: `bulk_create(batch_size=...)`, `bulk_update`, `update()`/`delete()` on querysets (these skip `save()` and signals).
- Large iterations: `iterator(chunk_size=...)` (with server-side cursors caveats behind poolers).
- Pagination: keyset for deep pages; `Paginator` counts are costly on huge tables.
- Add indexes for real filters and orderings after measuring.

## Anti-patterns
- `prefetch_related` on everything; `.all()` in templates; `Model.objects.get()` inside loops; `count()` on every request for UI totals; `distinct()` hiding join duplicates.

## Safety
`bulk_*` and queryset `update()` on production data need a bounded WHERE, a count check first and approval; batch large writes.

## Verify
- `assertNumQueries` regression test with the new bound; before/after query count, `EXPLAIN` and endpoint latency on realistic data; result parity checked.
