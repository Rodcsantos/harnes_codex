---
name: shared-root-cause-analysis
description: "Find the root cause of a bug or incident with evidence, timelines and falsifiable hypotheses before changing code. Use when something failed and the cause is unclear, symptoms recur, or a fix keeps not working."
---

# Root Cause Analysis

## Use when
- Incidents, regressions, flaky failures, or "it works now, I don't know why".

## Diagnose first
- Define the symptom precisely: what is expected, what happened, when it started, who or what is affected, how often.
- Build a timeline from evidence: deploys (`git log --since`), config changes, traffic shifts, dependency and infra events, log and metric inflection points.
- Preserve evidence before restarting or fixing: logs, thread/heap dumps, query plans, the failing request.
- Reproduce with the smallest case; if impossible, find what differs between failing and healthy instances.

## Decision rules
- List competing hypotheses; for each, state what you would observe if true and what would disprove it; test the cheapest discriminating check first.
- Change one variable at a time; `git bisect` for regressions; binary-search the input or the config.
- Separate trigger (what set it off) from cause (the defect that allowed it) from contributing factors (missing alert, no timeout).
- Ask "why" until you reach something you can change, and stop at a defect, not at a person.
- The fix must address the cause and a regression test or alert must fail without it.
- Record the conclusion with evidence, confidence, and what remains unknown.

## Anti-patterns
- Fixing the first plausible thing; restarting until it goes away; blaming the last deploy without checking; declaring root cause from correlation alone; closing with "human error".

## Safety
Mitigate first when users are impacted (rollback, flag off), using approved procedures; do not run experiments on production data or systems without approval.

## Verify
- The hypothesis predicted a specific observation that you then saw; after the fix the reproduction no longer fails and the metric returns to baseline; the regression test fails on the old code.
