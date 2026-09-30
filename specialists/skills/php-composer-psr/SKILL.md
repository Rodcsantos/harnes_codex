---
name: php-composer-psr
description: "Manage Composer dependencies, PSR-4 autoloading and PSR standards in PHP projects. Use when class not found errors appear, dependency conflicts arise, upgrading packages, or setting up a package or app skeleton."
---

# Composer and PSR

## Use when
- `Class ... not found`, version conflicts, adding/removing packages, publishing a library, or CI installing different versions than local.

## Diagnose first
- `composer validate`, `composer diagnose`, `composer why-not vendor/pkg 2.0`, `composer why vendor/pkg`.
- `composer show -i` and `composer outdated --direct`; check `composer.lock` is committed and in sync (`composer install` vs `update`).
- Autoload: read `autoload`/`autoload-dev` in `composer.json`; class file path must match namespace exactly (case-sensitive on Linux); `composer dump-autoload -o`.
- PHP constraint: `composer config platform` and `require.php`.

## Decision rules
- Applications: commit `composer.lock`, deploy with `composer install --no-dev --optimize-autoloader`. Libraries: declare ranges, do not commit the lock unless the project convention says so.
- `composer update vendor/pkg --with-dependencies` narrow updates, not blanket `composer update`.
- PSR-4: one class per file, file name = class name, namespace prefix maps to a directory; PSR-12 for style; PSR-3 logger, PSR-7/15/17 for HTTP, PSR-11 for containers.
- Use `require-dev` for tooling; `platform` config to pin the target PHP for resolution.
- Security: `composer audit` for known advisories; review scripts (`post-install-cmd`) of new packages.

## Anti-patterns
- Editing `vendor/`; `composer update` in production; wildcard `*` constraints; classmap-authoritative flags without regenerating; running Composer as root in CI without `--no-scripts` review.

## Safety
Major upgrades and lock changes need approval and a rollback (previous lock file). Do not run `composer update` on production hosts.

## Verify
- `composer validate --strict`, `composer install` from clean checkout, `composer audit`, tests pass, autoload optimized without class-not-found in a smoke test.
