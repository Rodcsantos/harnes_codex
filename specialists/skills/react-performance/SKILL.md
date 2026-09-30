---
name: react-performance
description: "Measure and fix React performance: unnecessary renders, expensive computations, list virtualization, bundle size and Web Vitals. Use when the UI feels slow, interactions lag, bundles are large, or Lighthouse/INP scores are poor."
---

# React Performance

## Use when
- Typing or scrolling lag, slow route transitions, large bundles, or regressions after adding a feature.

## Diagnose first
- React DevTools Profiler: record the interaction, find components with long or frequent commits and "why did this render".
- Browser Performance panel for long tasks and layout thrash; Lighthouse/Web Vitals (LCP, INP, CLS) on a production build, not dev mode.
- Bundle: `vite-bundle-visualizer`, `source-map-explorer`, or `next build` output; check what is imported on first load.
- Confirm React version and whether the React Compiler is in use (it auto-memoizes; manual memo may be redundant: confirm).

## Decision rules
- Measure, fix the biggest offender, measure again.
- Reduce work first: move state down or split components so fewer subtrees re-render; avoid new object/array/function props to memoized children.
- Then memoize: `React.memo` on expensive pure components, `useMemo` for costly derivations, `useCallback` only for stable props to memoized children or effects.
- Long lists: virtualize (`@tanstack/react-virtual`, react-window); paginate or window server data.
- Heavy updates that can lag: `useTransition`/`useDeferredValue` (React 18+) to keep input responsive; debounce expensive handlers.
- Split the bundle: route-level `React.lazy` + `Suspense`, dynamic imports for heavy libraries, tree-shakeable imports, remove unused dependencies, optimize images (dimensions, modern formats, lazy loading).
- Context that changes often re-renders all consumers: split contexts or use selector-based stores.

## Anti-patterns
- Wrapping everything in `memo`/`useMemo`; optimizing in dev mode; inline object props defeating memo; loading all routes eagerly; huge state in a top-level context.

## Safety
Performance refactors risk stale UI or behavior changes: keep behavior tests and review caching/memoization correctness before merge.

## Verify
- Profiler shows fewer/faster commits for the same interaction; production Web Vitals or Lighthouse improved; bundle size reduced; behavior tests still pass.
