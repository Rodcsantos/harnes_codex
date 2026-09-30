---
name: python-security
description: "Review and harden Python code against injection, unsafe deserialization, secret leaks and dependency risk. Use when handling untrusted input, subprocess/eval/pickle, auth tokens, file paths or reviewing dependencies."
---

# Python Security

## Use when
- Code parses user input, builds commands or queries, loads files or serialized data, stores secrets, or ships with third-party packages.

## Diagnose first
- Static: `bandit -r src/`, `ruff check --select S` (flake8-bandit rules), `pip-audit` or `safety` for known vulnerable dependencies.
- Grep dangerous sinks: `grep -rnE "eval\(|exec\(|pickle\.load|yaml\.load\(|subprocess\..*shell=True|os\.system|__import__|verify=False|md5\(|random\.(random|choice)" --include=*.py`.
- Secrets: `git log -p | grep -iE "api[_-]?key|secret|password"` (or gitleaks/trufflehog), `.env` in `.gitignore`.
- Trace each input from entry point to sink.

## Decision rules
- SQL: parameterized queries or ORM only; never f-strings in SQL. Shell: `subprocess.run([...], shell=False)` with a list and a validated allowlist.
- Deserialization: never `pickle`/`marshal` on untrusted data; `yaml.safe_load`; prefer JSON with schema validation (Pydantic/msgspec).
- Paths: resolve and check containment (`Path.resolve().is_relative_to(base)`), reject `..`; safe upload names and size limits.
- Secrets: from environment or a secret manager, `secrets` module for tokens, `hmac.compare_digest` for comparisons, passwords hashed with argon2/bcrypt/scrypt (not plain SHA/MD5).
- TLS: keep verification on (`verify=True`), set timeouts on requests.
- Templates: autoescape on; do not mark user input safe.
- Dependencies: pin, audit regularly, review new transitive packages.

## Anti-patterns
- `assert` for security checks (stripped with `-O`); catching all exceptions and continuing; logging tokens or PII; trusting `Content-Type`/filename from the client; SSRF via unvalidated URLs fetched server-side.

## Safety
Rotate any exposed secret immediately (needs owner approval); do not test exploits against production systems; changes to auth or crypto require review.

## Verify
- Tests with malicious inputs (injection strings, traversal paths, oversized bodies) are rejected; `bandit`/`pip-audit` clean or findings triaged; no secrets in repo history for the changed area.
