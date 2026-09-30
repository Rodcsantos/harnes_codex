---
name: django-auth-permissions
description: "Implement Django authentication, authorization, object-level permissions and secure session handling. Use when adding login, roles or permissions, protecting views/APIs, or reviewing access control gaps."
---

# Django Auth Permissions

## Use when
- New protected endpoints, role-based access, multi-tenant data isolation, custom user model, or an IDOR/permission bug.

## Diagnose first
- `grep -rn "AUTH_USER_MODEL\|AUTHENTICATION_BACKENDS\|SESSION_\|CSRF_\|REST_FRAMEWORK" settings*/ config/ 2>/dev/null`
- List views/routes without protection: check for missing `LoginRequiredMixin`, `@login_required`, `permission_classes`, or DRF `DEFAULT_PERMISSION_CLASSES`.
- Find queries that trust ids from the request: `get_object_or_404(Model, pk=pk)` without an ownership/tenant filter.
- `python manage.py check --deploy` for cookie and HTTPS flags.

## Decision rules
- Use a custom user model from the start (`AUTH_USER_MODEL`); changing it later is painful.
- Authentication is not authorization: every object access must filter by owner/tenant/permission in the queryset (`Model.objects.filter(owner=request.user)`), not only check a login.
- Django permissions (`has_perm`) for model-level rules; object-level rules through DRF permission classes or a dedicated library, tested explicitly.
- DRF: set restrictive `DEFAULT_PERMISSION_CLASSES` (for example `IsAuthenticated`) and opt out per view deliberately.
- Passwords: keep Django's hashers and validators; never roll custom hashing. Sessions: `SESSION_COOKIE_SECURE`, `CSRF_COOKIE_SECURE`, `SESSION_COOKIE_HTTPONLY` in production.
- Token/JWT auth: short access lifetime, rotation and revocation plan; confirm the library and version.

## Anti-patterns
- Permission checks only in the frontend; `is_staff` as a role system; `csrf_exempt` on session-authenticated views; leaking existence via 403 vs 404 differences where it matters.

## Safety
Changing auth backends, user model or permission defaults affects every user: stage it, keep an admin recovery path, get approval.

## Verify
- Tests for anonymous, wrong-user, wrong-tenant and correct-user on each endpoint (expect 401/403/404 as designed); `check --deploy` passes on the auth-related items.
