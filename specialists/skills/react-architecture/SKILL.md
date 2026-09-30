---
name: react-architecture
description: "Organize React applications into features, components, hooks and data layers with clear boundaries. Use when a React codebase has giant components, prop drilling, circular imports or unclear ownership of state and data fetching."
---

# React Architecture

## Use when
- Deciding folder structure, splitting components, where to put data fetching and business logic, or scaling a codebase across a team.

## Diagnose first
- React and framework versions (`react`, Next.js/Vite/Remix in `package.json`); routing and rendering model (CSR, SSR, RSC).
- Size and coupling: `find src -name '*.tsx' | xargs wc -l | sort -n | tail`; cycles with `madge --circular src` or `dpdm`.
- Props depth: components passing more than a handful of props or forwarding untouched props through layers.

## Decision rules
- Organize by feature (`features/orders/{components,hooks,api,types}`) with a small public `index` per feature; shared UI in a design-system folder; avoid cross-feature deep imports.
- Presentational components take props and render; containers/hooks own data and side effects. Extract a custom hook when logic is reused or obscures the component.
- Put server data in a server-state library (see react-server-state), local UI state near where it is used, and only truly global state in a store.
- Composition over configuration: use `children`, slots and compound components before adding boolean props.
- Lift state only as far as needed; use context for stable, rarely changing values (theme, auth), not fast-changing state.
- With frameworks that support it (Next.js App Router), keep data fetching on the server and mark client components (`"use client"`) at the leaves; confirm against the project's version.
- Follow the project's existing conventions before introducing new ones.

## Anti-patterns
- One 800-line component; `utils` folder dumping ground; context holding everything; copy-pasted components with small variations; barrel files causing cycles and bundle bloat.

## Safety
Large moves and renames can break imports and code splitting: do them in mechanical steps with tests and get review for shared component API changes.

## Verify
- `tsc --noEmit`, lint, tests pass; no circular imports; features can be read and changed by touching one folder; bundle size not worse.
