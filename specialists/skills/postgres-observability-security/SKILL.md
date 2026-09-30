---
name: postgres-observability-security
description: "Observe PostgreSQL with pg_stat views and harden roles, privileges and access. Use when diagnosing a live incident, enabling monitoring, or reviewing roles, pg_hba.conf, SSL and least privilege."
---

# PostgreSQL Observability Security

## Use when
- Unknown load source, monitoring setup, audit of who can do what, or preparing a database for production access.

## Diagnose first
- `SELECT pid, usename, state, wait_event_type, wait_event, now()-query_start AS age, left(query,100) FROM pg_stat_activity WHERE state<>'idle' ORDER BY age DESC;`
- Top statements (needs `pg_stat_statements`): `SELECT calls, round(total_exec_time) ms, mean_exec_time, rows, left(query,80) FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 10;` (older versions: `total_time`).
- Security: `\du+`, `SELECT * FROM pg_roles WHERE rolsuper OR rolcreaterole;`, `SELECT * FROM pg_hba_file_rules;`, `SHOW ssl; SHOW password_encryption;`
- Log settings: `log_min_duration_statement`, `log_lock_waits`, `log_connections`.

## Decision rules
- Separate roles: owner (DDL), app (DML on needed schemas), read-only, admin. The app never connects as superuser or owner.
- `REVOKE ALL ON DATABASE/SCHEMA public FROM PUBLIC` then grant explicitly; set `ALTER DEFAULT PRIVILEGES` for future tables. PG 15+ already restricts CREATE on `public`, but confirm.
- `pg_hba.conf`: specific hosts, `scram-sha-256`, `hostssl` for remote access; no `trust` outside local dev.
- Row-level security for multi-tenant isolation where the app cannot be trusted to filter.
- Turn on `log_lock_waits` and a sensible `log_min_duration_statement` before an incident, not after.

## Anti-patterns
- Shared superuser credentials; `0.0.0.0/0` with password auth; storing secrets in `ALTER ROLE ... PASSWORD` history-visible scripts; monitoring queries that lock or scan big tables.

## Safety
Approval before: `GRANT/REVOKE`, `ALTER ROLE`, editing `pg_hba.conf`, `pg_terminate_backend`, `pg_reload_conf`. Test connectivity from a second session before closing the working one.

## Verify
- Each app role can do only its needed actions (test with `SET ROLE` and a denied statement); monitoring dashboards show the incident metric; no unexpected `trust` or `PUBLIC` grants remain.
