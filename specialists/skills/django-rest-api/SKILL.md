---
name: django-rest-api
description: "Build and review Django REST Framework APIs: serializers, viewsets, permissions, pagination and versioning. Use when adding or changing DRF endpoints, fixing validation or performance, or defining API contracts."
---

# Django REST APIs

## Use when
- New resource endpoints, serializer validation bugs, slow list views, breaking-change risk, or inconsistent error formats.

## Diagnose first
- `pip show djangorestframework`; read `REST_FRAMEWORK` settings (auth, permissions, pagination, throttling, renderers).
- Routes: `python manage.py show_urls` (django-extensions) or read `urls.py`/routers.
- Per-endpoint: queryset, serializer, permission classes; count queries with `assertNumQueries`.
- Existing error and pagination conventions in the codebase.

## Decision rules
- Explicit `fields` in serializers (never `__all__` for writable public APIs); separate read and write serializers when shapes differ.
- Validate in `validate_<field>`/`validate()` and keep DB constraints as the last line of defense; map integrity errors to 400/409 deliberately.
- Restrictive default permissions, per-view overrides; filter querysets by `request.user`/tenant in `get_queryset()`.
- Kill N+1 in list views with `select_related`/`prefetch_related` in `get_queryset()` and annotate computed fields in SQL, not per-object serializer methods.
- Always paginate lists (cursor pagination for large or fast-changing data); enable throttling on auth and expensive endpoints.
- Compatible evolution: add fields, do not rename or remove; version (URL or header) when a break is unavoidable.
- Consistent error shape via a custom exception handler.

## Anti-patterns
- Business logic in serializers `create()` spanning multiple aggregates without a transaction; `SerializerMethodField` querying the DB; returning 200 with error bodies; exposing internal ids or fields by accident.

## Safety
Changing response shapes, status codes or auth on a published API is a breaking change: needs approval and a deprecation path.

## Verify
- API tests for success, validation failure, permission denial and pagination; `assertNumQueries` on list endpoints; schema (drf-spectacular or similar) diff shows only intended changes.
