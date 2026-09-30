---
name: python-packaging
description: "Manage Python packaging, dependencies, virtual environments and reproducible builds. Use when dependency conflicts, import errors after install, publishing a library, or unreproducible environments occur."
---

# Python Packaging

## Use when
- `ModuleNotFoundError` after install, version conflicts, choosing pyproject/lock tooling, building wheels, or CI installs differing from local.

## Diagnose first
- `which python; python -V; python -m pip --version; python -c 'import sys; print(sys.path)'`: is the intended virtualenv active?
- `python -m pip check`, `python -m pip list --outdated`, `pip show <pkg>`; for locks read `uv.lock`/`poetry.lock`/`requirements*.txt`.
- Read `pyproject.toml`: `[project]`, `dependencies`, `requires-python`, build backend, tool sections.
- Which package manager the repo uses; do not introduce a second one.

## Decision rules
- One environment per project (`python -m venv .venv` or the repo's tool such as uv/poetry); never install into system Python.
- Applications pin exact versions via a lock file with hashes when possible; libraries declare compatible ranges (lower bound, avoid tight upper caps without a reason).
- Declare all runtime imports as dependencies; put dev/test tools in optional groups.
- Use `src/` layout and `pyproject.toml` (PEP 517/621); build with `python -m build`; install locally with `pip install -e .`.
- Reproducibility: same Python minor version in CI and runtime, lock file committed, `pip install --require-hashes` or the tool's frozen install in CI.
- Resolve conflicts by finding which package needs the incompatible range (`pipdeptree -r -p pkg`) before pinning around it.

## Anti-patterns
- `sudo pip install`; unpinned production deploys; copying `site-packages`; `sys.path` hacks; mixing pip and conda in one env without care; `requirements.txt` as the only source of truth alongside a divergent `pyproject.toml`.

## Safety
Upgrading dependencies (especially major versions or security-sensitive packages) and publishing to PyPI need approval; publishing is irreversible per version.

## Verify
- Fresh venv install from the lock works and tests pass; `pip check` clean; wheel builds and installs in a clean environment; CI matrix green.
