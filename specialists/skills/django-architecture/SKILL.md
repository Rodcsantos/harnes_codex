---
name: django-architecture
description: "Structure Django projects into cohesive apps with clear service, model and view boundaries. Use when a Django codebase has fat views or models, circular imports, unclear app boundaries or scattered business logic."
---

# Django Architecture

## Use when
- Deciding where logic lives, splitting or merging apps, untangling imports, or preparing a project to scale in size or team.

## Diagnose first
- `python manage.py check --deploy` is for production; for structure run `python manage.py showmigrations --plan | tail` and list apps in `INSTALLED_APPS`.
- Import graph and hot spots: `grep -rn "^from .*models import" --include=*.py app/ | head`, look for cycles and views importing many apps.
- Find fat views/models: `wc -l */views.py */models.py | sort -n | tail`.
- Check versions: `python -m django --version`, `python --version`, and settings layout (`base`/`prod`).

## Decision rules
- An app owns one domain concept and its models; cross-app access goes through a small public surface (services/selectors), not by reaching into another app's internals.
- Views (or DRF viewsets) parse input, call a service, return output. Multi-step business rules go in service functions; read queries in selectors/managers.
- Model methods for behavior that concerns one instance; managers/querysets for reusable filters.
- Signals only for decoupled side effects; hidden business flow in signals is hard to trace: prefer explicit calls.
- Settings from environment, split by environment, no secrets in the repo.
- Follow the project's existing conventions before introducing a new layer.

## Anti-patterns
- Business logic in templates or serializers; `import *`; god `utils.py`; circular FK strings avoided by moving code instead of fixing boundaries; adding a service layer for CRUD that needs none.

## Safety
Moving models between apps needs migration care (`SeparateDatabaseAndState`) and approval; renaming apps changes table names and content types.

## Verify
- `python manage.py check` and `makemigrations --check --dry-run` clean; test suite passes; import cycles gone; a change to one domain touches one app.
