---
name: react-debugging
description: "Debug React bugs: wrong renders, stale state, effect loops, hydration errors and production-only failures. Use when the UI shows incorrect data, re-renders endlessly, warns in the console, or behaves differently in production."
---

# React Debugging

## Use when
- Stale values in handlers, infinite render/effect loops, `Cannot update a component while rendering`, hydration mismatch, flicker, or bugs that appear only in StrictMode or production.

## Diagnose first
- Console warnings and errors first (React names the component and cause); reproduce in dev with StrictMode on (effects run twice on mount in dev by design).
- React DevTools: Components (props/state/hooks values) and Profiler ("why did this render", commit timings).
- `console.log` inside render vs inside effects to see order; log dependency values for effect loops.
- Network tab and source maps for production errors; error boundary logs with component stack.

## Decision rules
- Wrong data: trace where the value is set; is it derived state duplicated from props, or a stale closure captured in a handler/effect?
- Effect loop: an effect sets state that is in its own dependencies, or a dependency is a new object/function each render: stabilize with `useMemo`/`useCallback`, move it outside, or remove the need for the effect.
- Stale closure: use functional updates (`setX(prev => ...)`), correct dependencies, or a ref for the latest value.
- Hydration mismatch: server and client rendered different output (dates, random, `window`, locale): render such values after mount or suppress deliberately.
- Rendering errors: keep render pure; side effects in effects/handlers; do not set state of another component during render.
- List problems: unstable or index `key` causes state to jump between items.
- Use error boundaries for graceful failure and reporting.

## Anti-patterns
- Disabling `react-hooks/exhaustive-deps` to silence a loop; `setTimeout` hacks; fixing by adding `key` randomly; mutating state or props.

## Safety
Do not ship debug logging or DevTools hooks; production repros with real user data need approval and redaction.

## Verify
- A test or steps reproduce the bug before and not after; console clean in StrictMode; Profiler shows expected render counts; behavior confirmed in a production build.
