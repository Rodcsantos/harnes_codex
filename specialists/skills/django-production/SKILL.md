---
name: django-production
description: "Prepare Django for production: settings, security flags, static files, workers, logging and deploy checks. Use when deploying, hardening settings, debugging production-only failures or configuring gunicorn/ASGI."
---

# Django Production

## Use when
- First deploy, environment split, HTTPS and cookie hardening, static/media handling, worker tuning, or incident debugging in production.

## Diagnose first
- `python manage.py check --deploy` (read every warning); `python manage.py diffsettings | head -50`.
- `DEBUG`, `ALLOWED_HOSTS`, `SECRET_KEY` source, `CSRF_TRUSTED_ORIGINS`, `SECURE_*`, `DATABASES` (`CONN_MAX_AGE`/pooling), `CACHES`, `LOGGING`.
- Process model: gunicorn/uvicorn workers, timeouts, memory per worker; reverse proxy headers (`SECURE_PROXY_SSL_HEADER` only behind a trusted proxy).
- `python manage.py migrate --plan` and `collectstatic --dry-run`.

## Decision rules
- `DEBUG=False`, secrets from the environment, explicit `ALLOWED_HOSTS`, `SECURE_SSL_REDIRECT`, HSTS, secure/HttpOnly cookies.
- Static files: `collectstatic` at build, served by the proxy/CDN or WhiteNoise; user uploads on external storage, not container disk.
- Workers: sync gunicorn workers ~ (2 x cores)+1 as a starting point, then measure; long tasks go to a queue (Celery/RQ), not the request.
- Database connections: set `CONN_MAX_AGE` or use a pooler; watch total connections across workers.
- Logging to stdout in structured form; error tracking (Sentry or equivalent); health endpoint that does not hit heavy dependencies.
- Run migrations as a separate release step before new code that needs them (expand/contract).

## Anti-patterns
- Running `runserver` in production; committing `.env`; `ALLOWED_HOSTS=['*']`; sending emails or calling APIs synchronously in requests; unbounded request timeouts.

## Safety
Production settings, migrations, and restarts need approval and a rollback path (previous image/release). Never print secrets in logs.

## Verify
- `check --deploy` clean or explained; smoke test on staging with production-like settings; error and latency dashboards after release; rollback rehearsed.
