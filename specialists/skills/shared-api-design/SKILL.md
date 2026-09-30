---
name: shared-api-design
description: "Design or review API contracts for consistency, compatibility, errors, pagination and idempotency across REST or RPC styles. Use when defining new endpoints, changing an existing contract, or reviewing an API for breaking changes."
---

# API Design

## Use when
- New API surface, versioning question, client breakage after a change, inconsistent errors or pagination, retry/duplicate problems.

## Diagnose first
- Find the current contract: OpenAPI/schema files, route definitions, client SDKs, and real consumers (who calls this and how).
- Compare with actual behavior using recorded requests or `curl -i`: status codes, headers, error bodies, nullability.
- Check for existing conventions (naming, envelopes, pagination style, error format) and follow them.

## Decision rules
- Resources as nouns, verbs from HTTP semantics; correct status codes; one consistent error shape with a stable machine-readable code.
- Backward compatible by default: adding optional fields/endpoints is safe; removing, renaming, tightening validation or changing types/defaults is breaking.
- Breaking change: version it (path or header), deprecate with a date and telemetry on old usage, then remove.
- Lists: bounded page size, cursor pagination for large or changing data, explicit sort/filter allowlists.
- Writes that clients may retry: idempotency keys or naturally idempotent methods; define behavior for duplicates.
- Auth, rate limits and quotas documented per endpoint; timeouts and retry guidance for clients.
- Contract first: update the schema and generate/validate against it in tests.

## Anti-patterns
- Leaking internal ids or database shapes; boolean flags that multiply states; 200 for errors; unbounded responses; renaming fields "for consistency" without a compatibility path.

## Safety
Contract changes on published APIs need owner approval and consumer communication; never remove fields to test impact in production.

## Verify
- Contract tests or schema validation pass; consumer-driven tests or sample clients still work; diff of the schema shows only intended additive changes.
