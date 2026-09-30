---
name: react-server-state
description: "Manage remote data in React with a server-state library: caching, invalidation, mutations and loading/error states. Use when fetching data with useEffect, handling stale caches, optimistic updates or duplicated requests."
---

# React Server State

## Use when
- Manual `fetch` in effects, loading and error flags scattered across components, stale lists after mutations, duplicate requests, pagination or infinite scroll.

## Diagnose first
- Which tool exists (TanStack Query, SWR, RTK Query, Apollo, framework loaders/Server Components); reuse it and its conventions.
- Network tab for duplicate or waterfall requests; how query keys are built; current `staleTime`/`gcTime` (or equivalents).
- Where mutations happen and what they should refresh.

## Decision rules
- Server state is a cache of remote data, not app state: keep it out of Redux/Context; keep UI state separate.
- Stable, hierarchical query keys that include every input (`['orders', {status, page}]`); one place defines keys and fetchers.
- Choose `staleTime` per data volatility; refetch on focus/reconnect where appropriate; do not disable refetching globally to hide bugs.
- Mutations: after success, invalidate affected keys or update cache directly; optimistic updates need rollback on error and a final refetch.
- Handle loading, error and empty states explicitly; use error boundaries and retries with limits; surface API errors accessibly.
- Avoid waterfalls: parallel queries, prefetch on hover/route, or fetch on the server (loaders/RSC) when the framework supports it.
- Pagination: keep previous data while loading the next page; cursor-based infinite queries for feeds.
- Abort or ignore outdated responses (libraries handle this; manual fetches need `AbortController`).

## Anti-patterns
- Copying query data into `useState`; fetching in many components with different keys for the same data; ignoring error states; invalidating everything after every mutation.

## Safety
Cache changes can show one user's data to another if keys omit user/tenant: include identity in keys and clear caches on logout.

## Verify
- Tests with mocked network (MSW) cover loading, success, error and mutation-invalidate flows; network tab shows one request per unique key; UI updates after mutation without manual refresh.
