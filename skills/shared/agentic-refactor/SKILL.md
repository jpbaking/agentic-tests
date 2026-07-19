---
name: agentic-refactor
description: Refactor or optimize main code while the agent-test suite (and user tests) must stay green after every change. The inverse of agentic-unit-test — main code may change, tests may not. Use when asked to refactor, optimize, or clean up code that agent tests already lock down.
---

# Agentic Refactor

The mirror image of `agentic-unit-test`: there, tests change and code is frozen; here, **code changes and tests are frozen**. The agent tests are the definition of correct behavior.

## 3 RULES

1. **NEVER edit any test** — not agent tests, not user tests, not to "fix" a failure. A failing test means YOUR change is wrong.
2. Behavior must not change. Refactor = same observable behavior, better internals. If a desired change WOULD alter behavior, STOP and tell the user to use the `agentic-test-update` skill after deciding intentionally.
3. Work in small steps; every step ends with a fully green suite and a checkpoint commit.

## Step 1 — Ask the user

1. "What should be refactored/optimized (files + goal: readability, performance, structure, ...)?"
2. "Is current agent-test coverage of those files enough to refactor safely?" — run the agent-tests-only coverage command (recipes: `../agentic-unit-test/docs/coverage-recipes.md`) and show the per-file numbers for the target files. If any target file is poorly covered, recommend using the `agentic-unit-test` skill on that file first and let the user decide.

## Step 2 — Preconditions (STOP if any fails)

1. All agent tests AND all user tests pass before touching anything.
2. Git repo, clean tree (`git status --porcelain` empty apart from plan files). Refactoring without git checkpoints is not allowed — STOP and say why.

## Step 3 — Plan

Write `agentic-refactor-plan.md` at the repo root (resume it if present — continue from the first non-`done` entry after re-running the suite):

```markdown
# Agentic refactor plan
Goal: <user's goal>

- [ ] step 1: <small, independently-green change> — pending
- [ ] step 2: ...
```

Statuses: `pending | in-progress | done | REVERTED (3 attempts): <reason>`. Update after every step.

## Step 4 — Refactor loop (per plan step)

1. Mark `in-progress`. Make ONE small change.
2. Build + run the FULL test suite (agent + user tests).
3. All green?
   - **Yes** → lint changed files, fix lint in main code (allowed here), commit: `git commit -am "refactor: <step> [agentic-refactor]"`. Mark `done`.
   - **No** → fix the CODE (never a test). **3 attempts.** After the 3rd: `git checkout -- .` back to the last checkpoint, mark `REVERTED (3 attempts): <reason>`, move on.
4. Performance goal? Measure before/after (the suite's runtime is not a benchmark — use the project's benchmark or a quick timed script in the scratchpad) and record numbers in the plan entry.

## Step 5 — Report

- **Goal**: restated, achieved or not.
- **Steps**: done vs reverted (with reasons).
- **Verification**: final full-suite run result (must be all green).
- **Measurements**: before/after numbers if performance was the goal.
- Commits made, in order.
