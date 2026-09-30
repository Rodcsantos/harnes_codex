---
name: react-state
description: "Choose and structure React state: local, lifted, reducer, context or external store, and avoid derived and duplicated state. Use when state is out of sync, prop drilling grows, re-renders spread widely, or a global store is proposed."
---

# React State Management

## Use when
- Bugs from duplicated state, complex update logic, deciding between useState/useReducer/context/store, or performance issues from broad state changes.

## Diagnose first
- Inventory state: for each piece, who reads it, who writes it, and whether it can be computed from other state or props.
- React DevTools: which components re-render when it changes; existing store libraries and patterns in the repo (Redux Toolkit, Zustand, Jotai, Context).
- Search for `useEffect` that only sets state from other state (a sign of derived state).

## Decision rules
- Keep state as local as possible; lift to the nearest common parent only when siblings need it.
- Do not store what you can compute: derive from the minimal source of truth during render.
- One source of truth: avoid mirroring props in state; reset with a `key` when identity changes.
- Related fields that change together or complex transitions: `useReducer` with typed actions; store ids and normalized data rather than nested copies.
- Context for low-frequency shared values (theme, user, config); for frequent updates use a store with selectors (Zustand, Redux Toolkit, Jotai) so consumers subscribe to slices.
- Remote data belongs in a server-state library (react-server-state); URL state (filters, pagination) in the URL; form state in the form library.
- State updates are snapshots: use functional updates for values based on previous state; never mutate.
- Model impossible states away (discriminated unions such as `status: 'idle'|'loading'|'error'`) instead of parallel booleans.

## Anti-patterns
- Global store for everything; contexts with large frequently changing objects; syncing two states with effects; storing derived arrays; boolean flag explosion.

## Safety
Changing the shape or persistence of global state (persisted stores, URLs) can break saved user data and deep links: version or migrate.

## Verify
- Tests exercise reducers/selectors and key flows; DevTools shows only expected components re-rendering; no effects exist merely to sync state.
