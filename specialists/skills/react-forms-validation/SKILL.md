---
name: react-forms-validation
description: "Implement React forms with controlled or uncontrolled inputs, schema validation, async submit and accessible errors. Use when building or fixing forms, validation logic, multi-step flows, or slow re-rendering forms."
---

# React Forms Validation

## Use when
- New forms, validation rules shared with the API, double submits, lost input, or large forms that lag.

## Diagnose first
- Which form library is in use (React Hook Form, Formik, TanStack Form, native/`useActionState`) and validation library (Zod, Yup, Valibot); reuse them.
- Where validation runs: client only, server only, or both; API error format for field errors.
- Profile re-renders with React DevTools if typing feels slow.

## Decision rules
- Validate on the server always; client validation is for feedback. Share one schema between client and server where the stack allows.
- Prefer uncontrolled inputs with a form library (React Hook Form) for large forms; controlled inputs only when the UI must react to each keystroke.
- Show errors after blur/submit rather than on first keystroke; keep the user's input on failure; move focus to the first invalid field on submit.
- Prevent double submit: disable the button while pending and make the endpoint idempotent; handle network failure with a retry path.
- Map server field errors back to fields (`setError`); show a general error for the rest.
- Accessible: real `label`s, `aria-invalid`, `aria-describedby` for messages, `required` semantics, correct `type`/`autocomplete`/`inputMode`.
- Convert types explicitly (numbers, dates) at the schema boundary; trim and normalize consistently.
- Multi-step: keep state in one place, validate per step, persist drafts if data loss hurts.

## Anti-patterns
- Client-only validation trusted by the backend; validating on every keystroke with heavy schemas; storing form state in global stores; using array index as key for dynamic fields; clearing the form on error.

## Safety
Never log form values containing passwords or personal data; sensitive fields need proper `autocomplete` and no persistence to local storage.

## Verify
- Tests: invalid input shows accessible errors, valid input submits once, server errors map to fields, keyboard-only submission works; typing stays responsive on large forms.
