# Getting started

## Prerequisites

- [Cline](https://cline.bot) (v3.48+ for skills support)
- A project that **builds cleanly** — the suite refuses to test broken code
- A test framework (Jest/Vitest, JUnit, pytest, GoogleTest, …). If missing, the skill will ask before installing one as a dev dependency
- Recommended: a git repository with a **clean working tree** — required by `agentic-refactor` and `agentic-mutation-check`, and checked by `agentic-unit-test`

## Installation

**Per-project** — copy both folders into the project root:

```
your-project/
├── .cline/skills/agentic-unit-test/      (+ the 3 sibling skills)
└── .clinerules/workflows/agentic-*.md
```

**Global** — available in every project:

```bash
cp -r .cline/skills/*            ~/.cline/skills/
cp    .clinerules/workflows/*    ~/Documents/Cline/Workflows/
```

Cline picks both up automatically; type `/` in the chat box and the `agentic-*` commands appear in autocomplete.

## Your first run

1. Commit or stash any pending changes (`git status` should be clean).
2. In Cline, type:

   ```
   /agentic-unit-test.md src/pricing.ts
   ```

3. Answer the two questions (coverage metric, goal % + per-file/overall) — or skip them by passing everything inline:

   ```
   /agentic-unit-test.md src/pricing.ts branch 90 per-file
   ```

4. Watch the plan file `agentic-test-plan.md` appear at the repo root and tick over as each file completes. If the session dies, just re-run the command — it resumes from the plan.
5. Read the final report: goal MET/NOT MET, per-file coverage table, and anything the agent failed to test (with reasons).

Whole project instead of one file? Use `.` as the path, or just omit it and answer "whole project" when asked.

## What you'll have afterwards

- New test files next to your code (or in your test dir), clearly named: `pricing.agentic.spec.ts`, `PricingAgenticTest.java`, `test_agentic_pricing.py`, …
- `agentic-test-plan.md` — the run's plan/progress log. Keep it (it records the goal for `/agentic-coverage-report.md`) or delete it; it regenerates.
- **Zero changes** to your source code or your own tests. Verify: `git diff --stat` shows only new agent-test files and (possibly) test config.

## Next steps

- Prove the tests actually bite → [`/agentic-mutation-check.md`](commands.md#agentic-mutation-check)
- Refactor with the net up → [`/agentic-refactor.md`](commands.md#agentic-refactor)
- Understand the rules of the game → [Core concepts](concepts.md)
