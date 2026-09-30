---
name: php-rest-api
description: "Design and implement REST APIs in PHP with correct HTTP semantics, validation, auth and error handling. Use when adding or changing endpoints in Laravel/Symfony/Slim or plain PHP, or defining API contracts."
---

# PHP REST APIs

## Use when
- New resources, validation or auth gaps, inconsistent status codes, pagination, versioning, or API performance problems.

## Diagnose first
- Framework and version, routing files, middleware stack, existing response/error format.
- List routes: `php artisan route:list` (Laravel) or `bin/console debug:router` (Symfony).
- Read one existing endpoint end to end (route, request validation, controller, resource/serializer) and follow its conventions.
- Test with `curl -i` for status codes, headers and error shape.

## Decision rules
- Correct verbs and status codes: 200/201 (+`Location`)/204, 400 malformed, 401 unauthenticated, 403 forbidden, 404, 409 conflict, 422 validation, 429 throttled.
- Validate input with the framework's request validation (Form Requests, Symfony Validator/constraints); never trust or mass-assign raw request data; whitelist fillable fields.
- Authorization on every object (policies/voters), scoped queries by user/tenant to prevent IDOR.
- Consistent JSON error format (code, message, field errors); do not leak stack traces or SQL.
- Lists: pagination (cursor for large sets), filtering/sorting whitelists, and eager loading to avoid N+1.
- Idempotency for retried writes (idempotency key or PUT semantics); rate limiting on auth and expensive routes.
- Evolve compatibly: add fields, deprecate before removing; version when breaking.

## Anti-patterns
- Returning 200 with error payloads; exposing model attributes wholesale; verbs in URLs (`/getUser`); business logic in controllers; CORS `*` with credentials.

## Safety
Changing response shapes, status codes or auth on a consumed API is a breaking change: approval and deprecation path needed.

## Verify
- Feature tests for success, validation failure (422), unauthenticated, forbidden and not found; query count bounded; contract (OpenAPI) diff shows only intended changes.
