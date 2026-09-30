---
name: php-security
description: "Review and harden PHP applications against injection, XSS, CSRF, insecure uploads, weak auth and unsafe configuration. Use when handling user input, sessions, passwords, file uploads, or auditing a PHP codebase."
---

# PHP Security

## Use when
- New forms/endpoints, authentication work, file upload features, security review, or dependency and configuration hardening.

## Diagnose first
- Static analysis: `phpstan` with security-minded rules, `psalm --taint-analysis` if configured, `composer audit`.
- Grep sinks: `grep -rnE "eval\(|unserialize\(|shell_exec|exec\(|system\(|passthru|include\s*\(?\s*\\$|md5\(|sha1\(|mysqli_query\(.*\\$|echo\s+\\$_(GET|POST)" --include=*.php`.
- Config: `php -i | grep -E "display_errors|expose_php|session.cookie_(secure|httponly|samesite)|allow_url_include"`.
- Trace input from `$_GET/$_POST/$_FILES/headers` to output, query, command and filesystem sinks.

## Decision rules
- SQL: prepared statements only. Output: escape by context (`htmlspecialchars($s, ENT_QUOTES, 'UTF-8')` or the template engine's autoescape); never disable autoescape for user data.
- Passwords: `password_hash`/`password_verify` (bcrypt/argon2), rehash with `password_needs_rehash`; compare secrets with `hash_equals`; tokens from `random_bytes`/`random_int`.
- CSRF tokens on state-changing session requests; session cookies `Secure`, `HttpOnly`, `SameSite`; `session_regenerate_id(true)` after login.
- `unserialize()` on untrusted data is dangerous: use `json_decode` or `allowed_classes`.
- Uploads: validate size and detected MIME (`finfo`), generate server-side names, store outside the web root or with no-execute, never trust the client filename or extension.
- `display_errors=Off` in production, errors to logs; keep `allow_url_include` off; restrict `open_basedir` where practical.
- Authorization on every object, not just login.

## Anti-patterns
- `md5`/`sha1` for passwords; `extract($_POST)`; `include` with user-controlled paths; CORS `*` with cookies; secrets in the repository or logs; trusting `X-Forwarded-*` from anyone.

## Safety
Rotate exposed secrets with the owner's approval; never run exploit tests against production; changes to auth flows need review.

## Verify
- Tests/payloads for injection, XSS, CSRF and traversal are rejected; `composer audit` and static analysis clean or triaged; production `php -i` values confirmed.
