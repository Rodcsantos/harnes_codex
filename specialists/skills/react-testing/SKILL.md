---
name: react-testing
description: "Test React components and hooks with Testing Library, user-centric queries, mocked network and stable async handling. Use when adding or fixing component tests, flaky async tests, or deciding what to test at the UI level."
---

# React Testing

## Use when
- New component or bug needing tests, `act` warnings, brittle snapshot tests, flaky waits, or testing hooks and forms.

## Diagnose first
- Runner and setup: Vitest/Jest config, `@testing-library/react` and `user-event` versions, `setupTests`, jsdom vs browser mode.
- Run one test: `vitest run path -t "name"` or `jest path -t "name"`; `--reporter=verbose`; look at `screen.debug()` and `logRoles` output on failures.
- Look for network calls, timers and randomness that are not controlled.

## Decision rules
- Test behavior as a user perceives it: render, interact with `userEvent` (`await user.click`), assert visible results. Do not assert on state, props, or component internals.
- Query priority: `getByRole` (with name), `getByLabelText`, `getByText`, then `getByTestId` as last resort. This also validates accessibility.
- Async: use `findBy*` and `waitFor` for things that appear later; no arbitrary sleeps; `await` every `userEvent` call.
- Network: mock at the boundary with MSW rather than mocking `fetch` or hooks inside the component; reset handlers between tests.
- Wrap providers (router, query client, theme) in a shared `renderWithProviders`; create a fresh QueryClient per test.
- Time: fake timers explicitly (`vi.useFakeTimers`) and restore.
- Snapshots only for small, stable output; prefer explicit assertions.
- Hooks: test through a component or `renderHook`; test custom hooks' contract, not their internals.
- Critical journeys: a few E2E tests (Playwright/Cypress); most logic covered by fast component/unit tests.

## Anti-patterns
- Shallow rendering internals; `container.querySelector`; testing implementation names; `act` warnings suppressed rather than understood; sharing state between tests.

## Safety
Do not hit real APIs or production services in tests; ensure MSW `onUnhandledRequest: 'error'` so accidental calls fail.

## Verify
- Test fails without the fix and passes with it; suite stable across repeated runs (`--repeat` or loop); no `act`/unhandled request warnings; queries used are accessible ones.
