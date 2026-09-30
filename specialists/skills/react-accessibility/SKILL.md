---
name: react-accessibility
description: "Build and audit accessible React UIs: semantics, keyboard, focus, ARIA and screen reader behavior. Use when adding interactive components, forms, dialogs or menus, or when an accessibility audit or bug is reported."
---

# React Accessibility

## Use when
- Custom buttons/menus/modals/tabs, forms with errors, dynamic content updates, or failing axe/Lighthouse checks.

## Diagnose first
- Automated: `eslint-plugin-jsx-a11y`, `jest-axe`/`@axe-core/playwright` in tests, browser axe or Lighthouse. They catch only part of the problems.
- Manual: navigate the flow with keyboard only (Tab, Shift+Tab, Enter, Space, Esc, arrows) and check visible focus order.
- Inspect the accessibility tree in browser devtools; try a screen reader (VoiceOver/NVDA) on the critical path.
- Check contrast, zoom to 200%, and reduced motion.

## Decision rules
- Use native elements first: `button`, `a href`, `input`, `label`, `select`, `dialog`, headings and landmarks. ARIA only fills gaps native HTML cannot; wrong ARIA is worse than none.
- Every control has an accessible name (`label`/`htmlFor`, `aria-label`, `aria-labelledby`); icon-only buttons need one.
- Custom widgets follow the WAI-ARIA Authoring Practices keyboard patterns and manage roles/states (`aria-expanded`, `aria-selected`).
- Modals: focus moves in, is trapped, `Esc` closes, focus returns to the trigger, background inert. Prefer a proven library (Radix, React Aria, Headless UI) over hand-rolled.
- Errors: associate messages with fields (`aria-describedby`, `aria-invalid`), announce dynamic updates with `aria-live` regions sparingly, move focus to the first error on submit.
- Never rely on color alone; keep focus outlines visible; honor `prefers-reduced-motion`.
- Route changes in SPAs: update the title and move focus to the new content heading.

## Anti-patterns
- `div onClick` as button; `tabIndex` > 0; removing outlines; placeholder as label; `aria-hidden` on focusable content; autoplay without control.

## Safety
Replacing shared components changes behavior everywhere: check usages and get review for design-system changes.

## Verify
- axe tests pass in CI, keyboard-only walkthrough completes the task, screen reader announces name/role/state correctly, contrast ratios meet WCAG AA (confirm the target level).
