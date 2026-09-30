---
name: python-architecture
description: "Structure Python code into modules with clear boundaries, dependency direction and testable seams. Use when a Python codebase has tangled imports, god modules, hidden globals or logic that is hard to test."
---

# Python Architecture

## Use when
- Deciding module layout, extracting services, breaking import cycles, or introducing dependency injection without over-engineering.

## Diagnose first
- Layout and size: `find . -name '*.py' -not -path './.venv/*' | xargs wc -l | sort -n | tail`.
- Cycles: `python -X importtime -c 'import pkg' 2>&1 | tail` for slow/circular imports; `pydeps`/`import-linter` if present.
- Global state: `grep -rn "^[A-Za-z_]* = \|global " --include=*.py src/ | head`.
- Python version and packaging (`pyproject.toml`), existing conventions.

## Decision rules
- Dependencies point inward: domain logic has no imports of frameworks, ORMs or I/O clients; adapters (DB, HTTP, queue) depend on the domain, not the reverse.
- Pass collaborators as arguments (functions, small classes, `Protocol`s) instead of importing singletons; construct them at the edge (`main`, app factory).
- Prefer functions and plain dataclasses; add classes when state and behavior belong together. Avoid inheritance for reuse; use composition.
- One reason to change per module; break cycles by moving shared types down or inverting with a `Protocol`.
- Keep I/O at the boundaries so core logic is pure and unit-testable.
- Follow the repo's existing structure before proposing a new one.

## Anti-patterns
- `utils.py` dumping ground; import-time side effects (connections, config reads); module-level mutable state; deep class hierarchies; premature abstractions for one implementation.

## Safety
Large moves and renames change public import paths: keep re-exports or a deprecation period and get approval for public API changes.

## Verify
- Tests pass before and after; import cycle check clean; core module imports without I/O; a new adapter can be swapped in a test without patching internals.
