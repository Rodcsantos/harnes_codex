---
name: php-testing-static-analysis
description: "Test PHP with PHPUnit/Pest and enforce quality with PHPStan/Psalm, code style and CI gates. Use when adding tests, fixing flaky suites, raising static analysis levels, or setting up quality tooling."
---

# PHP Testing and Analysis

## Use when
- New behavior or bug fixes need tests, static analysis errors appear, legacy code needs a baseline, or CI gates are missing.

## Diagnose first
- Tooling present: `composer.json` scripts, `phpunit.xml(.dist)`, `phpstan.neon`, `psalm.xml`, `.php-cs-fixer.php`, `pint.json`.
- Run narrow: `vendor/bin/phpunit --filter Name`, `--testsuite Unit`; slow tests: `--log-junit` or Pest `--profile`.
- Static analysis level: `vendor/bin/phpstan analyse --level=max --memory-limit=1G` on one path first.
- Coverage: `XDEBUG_MODE=coverage vendor/bin/phpunit --coverage-text` (or PCOV).

## Decision rules
- Bug fix: write the failing test first, then fix. Test behavior via public API; unit tests without DB/network, integration tests for repositories and HTTP layers.
- Data providers for input tables; test doubles (Mockery/PHPUnit mocks) only at boundaries; use an in-memory or transactional test database for persistence.
- Determinism: fixed clock (inject a clock), seeded randomness, refresh state between tests, no order dependence.
- PHPStan/Psalm: raise the level gradually per directory; use a baseline for legacy errors and forbid new ones; fix types instead of ignoring (`@phpstan-ignore` with reason only).
- Style automated (PHP-CS-Fixer/Pint) so review focuses on logic.
- CI runs lint, static analysis, tests, and `composer audit` on every PR.

## Anti-patterns
- Tests coupled to implementation details; mocking the class under test; assertions on private state; regenerating the baseline to hide new errors; skipping tests to go green.

## Safety
Do not run tests against shared or production databases; verify the test environment config before running destructive fixtures.

## Verify
- New test fails without the fix; suite and static analysis pass in CI; baseline size does not grow; coverage of changed lines reviewed.
