---
name: python-testing
description: "Write reliable Python tests with pytest: fixtures, parametrization, mocking boundaries and determinism. Use when adding or fixing tests, flaky or slow suites, or deciding what to mock."
---

# Python Testing

## Use when
- New behavior needs tests, a bug needs a regression test, tests are flaky, slow, or too coupled to implementation.

## Diagnose first
- `pytest -q -x --lf` (last failed), `pytest --durations=10` (slowest), `pytest -p no:randomly` vs `-p randomly` to expose order dependence, `pytest --collect-only -q | tail`.
- Config: `pyproject.toml`/`pytest.ini` markers, `conftest.py` fixtures, coverage settings (`pytest --cov=pkg --cov-report=term-missing`).
- For a flaky test: run it 50 times (`pytest --count=50` with pytest-repeat, or a shell loop) and note failure conditions.

## Decision rules
- Test behavior through public interfaces; assert outcomes, not call sequences. One reason to fail per test.
- Bug fix: write the failing test first, see it fail for the right reason, then fix.
- `pytest.mark.parametrize` for input tables; fixtures for setup with the narrowest scope that stays fast; `tmp_path` for files; `monkeypatch` for env/attrs.
- Mock only at boundaries you do not own (network, clock, payment APIs); use real DBs (containers/transactions) for persistence logic when feasible.
- Determinism: freeze time (`freezegun`/`time-machine`), seed randomness, no sleeps (poll with timeouts), no reliance on test order or shared state.
- Coverage is a signal for untested branches, not a target to game.
- Async code: `pytest-asyncio` or `anyio` with explicit modes.

## Anti-patterns
- Tests that mirror the implementation line by line; over-mocking so nothing real runs; shared mutable fixtures; assert-free tests; `sleep()` for synchronization; catching exceptions inside tests to make them pass.

## Safety
Never point tests at production databases or real third-party accounts; guard with environment checks and dedicated test credentials.

## Verify
- New test fails without the change and passes with it; full suite green and stable across repeated and random-order runs; slowest tests noted.
