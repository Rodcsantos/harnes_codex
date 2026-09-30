---
name: php-architecture
description: "Structure PHP applications with clear layers, dependency injection and framework-independent domain code. Use when a PHP codebase has fat controllers, static/global state, tangled dependencies or unclear boundaries."
---

# PHP Architecture

## Use when
- Deciding where logic lives, introducing services or repositories, untangling `new`/static calls, or organizing a Laravel/Symfony/plain PHP project.

## Diagnose first
- `php -v`; `composer show -i | head -30`; identify the framework and its conventions before changing structure.
- Find fat controllers and god classes: `wc -l src/**/*.php | sort -n | tail`; grep for `::getInstance`, `global `, `$_GET|$_POST` outside the HTTP layer.
- Dependency direction: `grep -rn "^use " src/Domain | grep -v "Domain"` shows the domain importing outward.
- Autoload map in `composer.json` (`psr-4`).

## Decision rules
- Controllers translate HTTP to a call and back; business rules live in services/use-case classes; persistence behind repositories or the framework's ORM used consistently.
- Constructor injection with type-hinted interfaces; let the container (Laravel/Symfony DI, PHP-DI) wire it; avoid service locators and statics.
- Domain objects take and return plain values or value objects, not request/response objects.
- One class, one responsibility; `final` classes and `readonly` properties where the PHP version allows (8.1+/8.2+; confirm project version).
- Keep framework glue thin so logic is unit-testable without booting the framework.
- Follow the framework's own structure (Laravel actions/jobs, Symfony bundles) rather than inventing a parallel one.

## Anti-patterns
- Superglobals deep in the code; business logic in Blade/Twig templates or model events; static helpers holding state; anemic controllers replaced by anemic services with 40 methods.

## Safety
Moving namespaces or classes breaks autoload and serialized data (queues, caches, sessions): coordinate with deploys and get approval for public API moves.

## Verify
- `composer dump-autoload -o` clean; static analysis (PHPStan/Psalm) and tests pass; core classes instantiate without the framework in unit tests.
