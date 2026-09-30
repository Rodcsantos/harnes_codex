---
name: mysql-query-optimization
description: "Rewrite and tune MySQL queries using execution plans and measured row counts. Use when a specific SQL statement is slow, scans too many rows, sorts on disk or is called too often."
---

# MySQL Query Optimization

## Use when
- One query dominates latency or CPU; N+1 patterns in the application; large OFFSET pagination; heavy GROUP BY or subqueries.

## Diagnose first
- `EXPLAIN FORMAT=TREE` (or JSON) and compare estimated vs actual rows with `EXPLAIN ANALYZE` on a safe SELECT (8.0.18+).
- `SELECT * FROM sys.statement_analysis WHERE query LIKE '%fragment%'\G`: exec count, rows examined vs sent, tmp tables, sort merge passes.
- `SHOW WARNINGS` right after EXPLAIN for the rewritten query.

## Decision rules
- Rows examined much larger than rows sent: missing or unusable index, or non-sargable predicate. Fix predicate or index before restructuring SQL.
- Deep pagination: replace `LIMIT n OFFSET big` with keyset (`WHERE (k) > last ORDER BY k LIMIT n`).
- Correlated subquery or `IN (SELECT ...)`: try a JOIN or `EXISTS`; measure, because the 8.0 optimizer often already flattens them.
- `SELECT *` on wide rows prevents covering indexes; select needed columns.
- Selecting then updating in the app loop: collapse into set-based SQL or batched `IN` lists.
- Leave hints (`USE INDEX`, `STRAIGHT_JOIN`, optimizer hints) as the last resort, with a comment and a test that proves the need.

## Anti-patterns
- Functions on indexed columns in WHERE; `ORDER BY RAND()`; `COUNT(*)` on huge tables for UI badges; `DISTINCT` to hide a bad join; implicit collation or charset mismatch in joins.

## Safety
Do not run `EXPLAIN ANALYZE` on statements with side effects. Changing an application query contract (ordering, columns) needs review of callers.

## Verify
- Plan and rows examined improved on production-like volume; results identical (diff a sample or compare checksums); latency percentile improved in the statement digest.
