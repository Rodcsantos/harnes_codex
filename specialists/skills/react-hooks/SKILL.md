---
name: react-hooks
description: "Use React hooks correctly: dependency arrays, effects vs event handlers, custom hooks, refs and cleanup. Use when effects misbehave, values are stale, hooks rules are violated, or logic should be extracted into a custom hook."
---

# React Hooks

## Use when
- `exhaustive-deps` warnings, effects that fetch or subscribe, duplicated logic across components, or timers/listeners leaking.

## Diagnose first
- Confirm `eslint-plugin-react-hooks` is enabled (`rules-of-hooks`, `exhaustive-deps`) and read each warning before changing code.
- List each `useEffect`: what does it synchronize with, what are its dependencies, does it clean up?
- Check React version for available hooks and behavior (`useId`, `useSyncExternalStore`, `useTransition`, `use` and Actions are newer: confirm against the project's version).

## Decision rules
- An effect synchronizes with something outside React (subscriptions, timers, DOM APIs, network). Derived values belong in render (or `useMemo` when costly), user-triggered work in event handlers.
- Do not copy props to state to derive values; compute during render, or reset state with a `key`.
- Dependencies must list every reactive value used; fix warnings by restructuring (move functions inside the effect, use functional updates, `useRef` for non-reactive values, `useEffectEvent` where available), not by suppressing.
- Always clean up: unsubscribe, clear timers, abort fetches (`AbortController`) to avoid race conditions between responses.
- Data fetching in effects is easy to get wrong; prefer a data library or framework loaders (see react-server-state).
- Custom hooks: name `useX`, encapsulate one concern, return a stable, minimal API; call hooks at the top level only.
- `useMemo`/`useCallback` are performance tools with a measured need or for stable identities passed to memoized children/effects, not defaults.
- `useRef` for mutable values that must not trigger renders; `useReducer` for state with multiple related transitions.

## Anti-patterns
- Empty dependency array to "run once" when values are used; state updates in effects that trigger the same effect; hooks inside conditions or loops; effects for event handling.

## Safety
Changing effect timing on shared hooks affects every consumer: check usages and add tests before modifying.

## Verify
- Lint clean without disable comments; tests cover mount, update and unmount (no leaked listeners/timers); StrictMode double-invocation causes no bugs; no race between overlapping requests.
