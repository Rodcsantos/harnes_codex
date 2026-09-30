---
name: python-debugging
description: "Debug Python failures methodically with tracebacks, reproduction, logging, pdb and profilers. Use when there is an exception, wrong output, flaky behavior or a production-only bug in Python code."
---

# Python Debugging

## Use when
- Stack traces to interpret, intermittent failures, memory growth, or "works on my machine".

## Diagnose first
- Read the traceback bottom-up: exception type, message, the last frame in project code. Note chained causes (`__cause__`, `__context__`).
- Reproduce minimally: failing test or script with the smallest input; record Python and dependency versions (`python -V`, `pip freeze | head`).
- Interactive: `python -m pdb script.py`, `breakpoint()`, or post-mortem `python -m pdb -c continue script.py`; `pytest --pdb -x`.
- Production: `faulthandler` (`python -X faulthandler`, `kill -SIGABRT`), `py-spy dump/top --pid` for hangs and CPU; `tracemalloc` for memory growth.

## Decision rules
- Form one hypothesis, predict what you will see, then check with a print/log/breakpoint; change one thing at a time.
- Bisect: `git bisect` for regressions, halving the input for data-dependent bugs.
- Flaky: look for time, randomness (seed it), ordering, shared state, concurrency, and environment differences before blaming the test.
- Fix the root cause and add a regression test that fails before the fix.
- Log with context (`logger.exception`, ids) instead of `print`; never log secrets.
- Distinguish "wrong assumption about data" from "wrong code": inspect real values at the failing frame.

## Anti-patterns
- Wrapping in broad `try/except` to silence errors; fixing symptoms at the caller; leaving `breakpoint()` or debug prints; debugging against stale `.pyc`/wrong virtualenv.

## Safety
Attaching profilers or debuggers to production processes and enabling debug logging can affect performance or leak data: use read-only samplers (py-spy) and get approval.

## Verify
- The reproduction fails before and passes after; regression test added; related test suite green; no new warnings.
