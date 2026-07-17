---
name: agentic-test-update
description: Reconcile agent tests after the user INTENTIONALLY changed main-code behavior — show each failing agent test as old-locked vs new-actual behavior, and update tests only with per-diff user confirmation. Use when agent tests fail after a deliberate behavior change.
---

# Agentic Test Update

Agent tests lock old behavior; the user changed behavior on purpose. This skill re-locks — but only where the user confirms the change was intended. Unconfirmed failures are potential regressions and must stay failing.

## RULES

1. **NEVER edit main code or user tests.** Only agent tests and plan files.
2. **Never update a test without the user's explicit per-diff confirmation.** No batch "update all".
3. An updated test must assert the NEW actual behavior (test-quality rules from `agentic-unit-test` apply). Never weaken a test to pass both old and new behavior.

## Step 1 — Collect failures

1. Run the full agent-test suite.
2. All green? Report "nothing to update" and STOP.
3. For each failing test, capture: test name, file, expected (old locked behavior), actual (new behavior). Group by source file.

## Step 2 — Confirm with the user, per behavior change

For each group, show a compact diff and ask ONE question:

```
src/pricing.ts — 3 agent tests failing
  old locked: priceWithTax(0, 0.2) → 0
  new actual: priceWithTax(0, 0.2) → throws RangeError
Intended change? (yes = update tests to lock new behavior / no = keep failing as regression)
```

Record every answer in `agentic-test-plan.md` under a `## Behavior updates <YYYY-MM-DD>` section: `confirmed` or `regression`.

## Step 3 — Update confirmed tests

For each `confirmed` group:

1. Rewrite the failing assertions to lock the NEW behavior. Keep test names honest (rename if the name describes old behavior).
2. Run the test file 3× (flakiness check). **3 attempts**; after the 3rd failure revert the test and mark it `FAILED to update: <reason>` in the plan.
3. Lint if configured.

Leave every `regression` test untouched and failing.

## Step 4 — Report

- **Updated**: tests re-locked to new behavior (per file).
- **Regressions**: failing tests the user did NOT confirm — listed loudly; the suite is intentionally left red until the user fixes main code or re-runs this skill.
- **Failed to update**: 3-attempt casualties with reasons (or "none").
- Final suite status: green, or red-with-known-regressions.
