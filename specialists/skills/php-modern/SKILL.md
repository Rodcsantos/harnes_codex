---
name: php-modern
description: "Modernize PHP code with typed properties, enums, readonly, match and attributes without breaking compatibility. Use when upgrading PHP versions, cleaning legacy code, or writing new code that should use current language features."
---

# Modern PHP

## Use when
- Migrating to PHP 8.x, adding strict types, replacing arrays-of-everything with typed objects, or resolving deprecations.

## Diagnose first
- `php -v`, `composer.json` `require.php`, CI PHP versions; `php -d error_reporting=E_ALL -l file.php` for syntax under the target version.
- Deprecations: run tests with `E_ALL` and `error_log`; use Rector in dry-run (`rector process --dry-run`) and PHPCompatibility/PHPStan for the target version.
- Which features the minimum supported version allows (do not use 8.1 features on 7.4/8.0 targets).

## Decision rules
- `declare(strict_types=1);` in new files; scalar/union/return types on public methods; `?T`/`T|U` instead of docblock-only types.
- Constructor property promotion (8.0+), `readonly` properties (8.1+), `readonly` classes (8.2+), enums (8.1+) for closed sets, `match` instead of `switch` for value mapping, first-class callable syntax (8.1+), `#[Attributes]` (8.0+).
- Prefer value objects/DTOs over associative arrays for structured data; `never`, `static` return types where precise.
- Use `str_contains/str_starts_with` (8.0+), null-safe operator `?->`.
- Upgrade incrementally: fix deprecations on current version first, then bump.
- Confirm each feature against the project's minimum PHP version before using it.

## Anti-patterns
- Mass automated rewrites in one commit; adding types that change behavior (int/string coercion) without tests; `mixed` everywhere; enabling `strict_types` on legacy files without checking call sites.

## Safety
PHP version bumps and strict-type rollouts on legacy code can change runtime behavior: staged rollout with tests and approval.

## Verify
- Test suite and static analysis pass on all supported PHP versions in CI; no new deprecation notices; Rector dry-run shows no unintended edits.
