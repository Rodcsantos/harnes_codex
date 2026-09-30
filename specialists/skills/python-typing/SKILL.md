---
name: python-typing
description: "Add and fix Python type hints with mypy or pyright, generics, protocols and gradual adoption. Use when type checker errors appear, public APIs need contracts, or typing an untyped codebase incrementally."
---

# Python Typing

## Use when
- `mypy`/`pyright` failures, `Any` leaking through APIs, TypedDict/dataclass/Pydantic modeling questions, or adding typing to legacy code.

## Diagnose first
- `python -V` (syntax like `X | None` and `list[int]` need 3.10/3.9+; `typing_extensions` otherwise); the repo's checker and config (`[tool.mypy]`, `pyrightconfig.json`).
- Run the checker on the narrow path first: `mypy path/to/module.py` or `pyright path/`; `--show-error-codes` to see codes.
- Count `Any`/`# type: ignore`: `grep -rn "type: ignore\|Any" --include=*.py | wc -l`.

## Decision rules
- Type public function signatures and data models first; let inference handle locals. Adopt gradually: per-module strictness overrides rather than one big-bang `--strict`.
- Prefer precise types: `Sequence`/`Mapping` for read-only params, `Protocol` for structural interfaces, `TypedDict`/`dataclass`/Pydantic for structured data, `Literal`/`Enum` for closed sets, `NewType` for ids.
- Narrow `Optional` with checks (`if x is None`), not with `assert` in production paths or casts.
- `cast` and `# type: ignore[code]` only with a comment saying why; keep them rare and specific.
- Generics: `TypeVar`/PEP 695 syntax (3.12+, confirm target version); `ParamSpec` for decorators that preserve signatures.
- Avoid `Any` at boundaries; use `object` or `unknown`-style narrowing after validation.

## Anti-patterns
- Blanket `# type: ignore`; `Any` to silence errors; annotating with `dict` when a `TypedDict` exists; runtime-changing code only to satisfy the checker without understanding the error.

## Safety
Changing public type contracts in a library is an API change; check downstream users and versions. Do not change runtime behavior under the banner of "typing".

## Verify
- Checker passes on the touched scope with no new ignores; runtime tests still pass; strictness for the module increased, not decreased.
