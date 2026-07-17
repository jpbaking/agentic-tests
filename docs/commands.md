# Command reference

All commands are Cline workflows — type `/` and pick them from autocomplete. Inline arguments are positional; each one you provide skips its interactive question.

---

## `/agentic-unit-test.md` — generate the safety net {#agentic-unit-test}

```
/agentic-unit-test.md [path] [metric] [goal%] [per-file|overall]
```

| Example | Meaning |
|---|---|
| `/agentic-unit-test.md` | fully interactive |
| `/agentic-unit-test.md src/foo.ts` | one file; asks metric + goal |
| `/agentic-unit-test.md src/foo.ts branch 90 per-file` | zero questions |
| `/agentic-unit-test.md . line 80 overall` | whole project |

**Does:** precondition checks → baseline coverage (agent tests only) → crash-proof plan → per-file generation with 3-attempt / flakiness / quality gates → final report.
**Writes:** agent tests, `agentic-test-plan.md`, test config if needed. Nothing else.

---

## `/agentic-mutation-check.md` — prove the net holds {#agentic-mutation-check}

```
/agentic-mutation-check.md [score% | report-only]
```

**Requires:** all agent tests passing; clean git tree. **Tools:** StrykerJS (JS/TS), PIT (Java), mutmut (Python); C/C++ unsupported.
**Does:** runs mutations against agent tests only → strengthens assertions to kill survivors (3 attempts each) → reports score before/after, unkilled mutants, and justified equivalents.
**Never:** edits main code or user tests — mutation tools mutate source *temporarily and automatically*; the agent itself touches only agent tests.

---

## `/agentic-refactor.md` — change code, tests frozen {#agentic-refactor}

```
/agentic-refactor.md [path] [goal...]
e.g. /agentic-refactor.md src/parser.ts make it faster
```

**Requires:** git with a clean tree; full suite (agent + user tests) green; shows you per-file agent coverage of the targets first so you can bail if the net is thin.
**Does:** small steps, full suite after each, checkpoint commit per green step, `git checkout` revert after 3 failed attempts. Performance goals get measured before/after.
**Never:** edits any test. A failing test means the change was wrong. Intentional behavior change? That's `/agentic-test-update.md`.

---

## `/agentic-test-update.md` — re-lock after intentional change {#agentic-test-update}

```
/agentic-test-update.md [path]
```

**Does:** runs agent tests → groups failures by source file → shows each as `old locked vs new actual` → asks **per diff**: intended change, or regression? Confirmed diffs get tests rewritten to lock the new behavior (same quality/flakiness gates); unconfirmed ones **stay red** and are reported loudly as regressions.
**Never:** batch-updates, weakens an assertion to pass both behaviors, or touches main code.

---

## `/agentic-coverage-report.md` — where do we stand? {#agentic-coverage-report}

```
/agentic-coverage-report.md
```

Read-only. Runs agent-tests-only coverage and prints: goal from `agentic-test-plan.md` (MET/NOT MET), overall + per-file table, failing agent tests. Creates and modifies nothing.

---

## `/agentic-test-clean.md` — remove everything {#agentic-test-clean}

```
/agentic-test-clean.md
```

Finds every agent test + plan file, shows the full list, and deletes **only after an explicit yes**. Main code, user tests, and test config are untouched — one command returns your repo to its pre-suite state.
