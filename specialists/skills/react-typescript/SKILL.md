---
name: react-typescript
description: "Type React components, props, hooks, events and generics with TypeScript without any-leaks. Use when adding types to components, fixing compiler errors, typing polymorphic or generic components, or tightening strictness."
---

# React TypeScript

## Use when
- Type errors in props/events/refs, `any` spreading through APIs, typing context and reducers, or migrating JS components.

## Diagnose first
- `tsc --noEmit` (project's `tsconfig.json`), `strict` and `noUncheckedIndexedAccess` flags, TypeScript and `@types/react` versions.
- Count leaks: `grep -rn ": any\|as any\|@ts-ignore\|@ts-expect-error" src | wc -l`.
- Read the exact error and the inferred type (hover in the editor or `type X = typeof y` tricks) before adding annotations.

## Decision rules
- Type props with an interface or type alias; do not use `React.FC` unless the codebase does; `children: React.ReactNode` when needed. Prefer inference for locals.
- Events: `React.ChangeEvent<HTMLInputElement>`, `React.MouseEvent<HTMLButtonElement>`; wrap native props with `React.ComponentPropsWithoutRef<'button'>` to extend elements.
- Discriminated unions for variants and states; exhaustive `switch` with a `never` check.
- Generics for reusable components (`<T,>(props: ListProps<T>)`) constraining with `extends`; avoid over-generic APIs.
- Context: provide a non-null hook (`useX` throws if missing) instead of `undefined!`; reducers with typed action unions.
- Refs: `useRef<HTMLDivElement>(null)`; forward refs typed with `forwardRef` (or `ref` as prop in newer React: confirm version).
- Validate external data at the boundary (Zod) and infer types from schemas (`z.infer`) rather than asserting with `as`.
- `unknown` over `any`; narrow with type guards; `satisfies` to check shape without widening.
- Keep `@ts-expect-error` (with reason) over `@ts-ignore`, so stale suppressions fail.

## Anti-patterns
- `as any` to pass the compiler; casting API responses; optional props for everything; duplicating types manually from the backend instead of generating or sharing them.

## Safety
Tightening compiler flags project-wide can surface hundreds of errors: roll out per directory and agree with the team before merging.

## Verify
- `tsc --noEmit` and lint pass; no new `any` or suppressions; runtime tests still pass; type tests (`expectTypeOf`/`tsd`) cover tricky generic APIs.
