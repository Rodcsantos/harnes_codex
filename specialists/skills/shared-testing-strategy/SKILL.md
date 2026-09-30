---
name: shared-testing-strategy
description: "Choose the right mix of unit, integration and end-to-end tests, test data and CI gates for a change or system. Use when planning tests for a feature, reducing flakiness or slowness, or deciding what not to test."
---

# Testing Strategy

## Use when
- Deciding test scope for new work, an untested legacy area, a flaky or slow suite, or unclear confidence before release.

## Diagnose first
- Inventory the current suites: counts by level, runtime (`--durations`), flake rate from CI history, coverage of the changed code.
- Identify the risk: what breaks users or money if wrong? Which boundaries (DB, network, time, concurrency) does the change cross?
- Check for existing test utilities, fixtures and conventions and reuse them.

## Decision rules
- Many fast unit tests for logic, fewer integration tests for real boundaries (database, queue, HTTP), a small number of end-to-end tests for critical journeys.
- Test at the lowest level that can catch the bug; add a higher-level test only for wiring or user-visible flow.
- Bug fixes start with a failing regression test.
- Prefer real dependencies via containers or transactional databases over mocks for persistence; mock only what you do not control.
- Deterministic tests: injected clock, seeded random, isolated data, no sleeps, no order dependence, independent parallel runs.
- Cover boundaries and failure modes (empty, max, invalid, timeout, duplicate, concurrent) more than happy-path variations.
- Quarantine flaky tests with a ticket and owner; fix or delete, never ignore.
- CI gates: fast checks on every change, slower suites on merge or schedule; coverage on changed lines as a signal.

## Anti-patterns
- Testing implementation details; ice-cream cone of slow UI tests; shared mutable test data; asserting on logs or ordering that is not part of the contract; chasing a coverage number.

## Safety
Never run tests against production data or third-party live accounts; use dedicated test resources and guard configuration.

## Verify
- The risky behaviors each have at least one test that fails when the behavior breaks (mutation check by temporarily breaking the code); suite time and flake rate are stable or improved.
