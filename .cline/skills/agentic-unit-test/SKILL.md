---
name: agentic-unit-test
description: Generate agent-authored unit tests ("agent tests") to reach a user-defined coverage goal for one target file/class or the whole project, without ever modifying main code or user-made tests. Use when asked to write unit tests, raise coverage, or lock down existing behavior before refactoring/optimization.
---

# Agentic Unit Test Generator

You write NEW test files to lock down existing behavior. You NEVER change production code. You NEVER change tests the user wrote.

## 3 RULES — read again before every file you touch

1. **NEVER edit main code (production source) or user tests.** You may only create/edit agent tests, test config files (jest/vitest/pytest/maven/gradle/cmake/go.mod/Cargo.toml test setup, lint config), and `agentic-test-plan.md`. (Rust: never turn a private item `pub` to reach it — that edits main code.)
2. **Only agent tests count for coverage.** Every coverage run must execute agent tests ONLY.
3. **Main code is correct by definition.** If a test shows weird behavior: assert the weird behavior as-is, add a note to the plan file, move on. Do NOT fix the source.

If you are about to edit a file, check its name against the table below. Not an agent test, not test config, not the plan file → STOP, do not edit it.

## What is an "agent test"?

A test file YOU create, named exactly like this:

| Language | Agent-test filename |
|---|---|
| TypeScript | `<name>.agentic.spec.ts` (`.tsx` if the test contains JSX) |
| JavaScript | `<name>.agentic.spec.js` (`.jsx` if the test contains JSX) |
| Java (JUnit) | `<Name>AgenticTest.java` |
| Groovy (Spock) | `<Name>AgenticSpec.groovy` |
| Python | `test_agentic_<name>.py` |
| C | `<name>_agentic_test.c` |
| C++ | `<name>_agentic_test.cpp` |
| Go | `<name>_agentic_test.go` (funcs named `TestAgentic…` so `-run '^TestAgentic'` selects them) |
| Rust | `tests/agentic_<name>.rs` — an **integration** test (unit tests would edit main code) |
| Other | framework's normal test name, with `agentic` added into the filename |

Any test file NOT matching these patterns = **user test** = read-only.

## Step 1 — Ask the user (always, before anything else)

Ask these 3 questions and wait for answers:

1. "Scope: one file/class, or the whole project?" (skip if the user already named a target)
2. "Coverage metric: line, branch, function, or statement?"
3. "Coverage goal: what %? And does it apply per-file, or to the project overall?"

Do not run any command before you have all 3 answers.

## Step 2 — Check preconditions (STOP if any fails)

Run these checks. If one fails, tell the user exactly what failed and STOP.

1. Build/compile the main code (e.g. `npx tsc --noEmit`, `mvn compile`, `python -m compileall`, `make`, `go build ./...`, `cargo build`). It must pass with no errors.
2. A test framework must exist (jest/vitest/junit/spock/pytest/gtest/`go test`/`cargo test`...). If none, ask the user before installing one as a dev/test dependency.
3. If the folder is a git repo: run `git status --porcelain`. Every listed file must be an agent test, test config, or `agentic-test-plan.md`. Anything else → tell the user to commit or stash it, and STOP.

## Step 3 — Baseline + plan

1. Run coverage on agent tests only. Open `docs/coverage-recipes.md` (in this skill folder) and copy the command for your framework. If no agent tests exist yet, coverage is 0% — that is fine.
2. Create `agentic-test-plan.md` at the repo root (if it exists, resume it instead — see "Resuming" below). Use exactly this format:

```markdown
# Agentic test plan
Goal: <metric> >= <N>% (<per-file | overall>)
Baseline: <X>%

- [ ] src/foo.ts — pending
- [ ] src/bar.ts — pending
```

One line per source file in scope. Statuses: `pending`, `in-progress`, `done (NN%)`, `FAILED (3 attempts): <short reason>`.

3. Update this file's status line immediately after finishing each file. Never batch updates.

**Resuming:** if `agentic-test-plan.md` already exists, re-run the baseline coverage command, then continue from the first line that is not `done`.

## Step 4 — Write tests, one plan entry at a time

For the current plan entry, repeat this loop:

1. Mark the entry `in-progress`.
2. Write (or extend) the agent test for that file. Test the public functions/branches that coverage shows as uncovered.
   - New file? Copy the skeleton for your language from `docs/templates/` (in this skill folder).
   - Need to isolate time, randomness, network, filesystem, or a dependency? Open `docs/mocking-recipes.md`.
3. Run only that test file **3 times in a row** (flakiness check — a flaky test is worse than no test).
4. Did all 3 runs pass, AND does every test obey the quality rules below?
   - **Yes** → go to step 5.
   - **No** → fix the TEST (never the source) and rerun. **You get 3 attempts total.** A flaky run or a quality-rule violation counts as a failed attempt. After the 3rd failure: restore the test file to the last version that passed (delete the file if no version ever passed), mark the entry `FAILED (3 attempts): <reason>`, and move to the next entry.
5. If the project has a linter, run it on the test file and fix all lint errors in the test file.
6. Run the agent-tests-only coverage command again. Write the file's % into the plan entry: `done (NN%)`.
7. Goal already met (per the user's per-file/overall choice)? → go to Step 5 (finish). Otherwise → next plan entry.

The same 3-attempt rule applies to one specific hard-to-reach branch: 3 tries, then keep the passing parts of the test, note the unreached branch in the plan entry, move on.

### Test-quality rules — a test breaking any of these does NOT count as passing

- Every test must call the code under test and assert on its result or observable effect.
- Banned: `expect(true).toBe(true)` / `assertTrue(true)`, empty test bodies, and tests whose only assertion is "does not throw" (unless not-throwing IS the behavior being locked).
- Do not assert on values you just configured in a mock — asserting your own setup proves nothing.
- Never delete or weaken an assertion just to make a test pass or hit a coverage number.

## Step 5 — Finish

Do these 4 things, in order:

1. Run ALL agent tests once. Every one must pass. A failing one gets the same 3-attempt/revert treatment.
2. Run the agent-tests-only coverage command one final time.
3. Print a report with exactly these sections:
   - **Goal**: metric, %, per-file or overall — and **MET** or **NOT MET** (if not met: by how much).
   - **Coverage**: overall % and a per-file table (file, %).
   - **Failures**: every `FAILED` plan entry — file/function, one-line reason. Write "none" if empty.
   - **Notes**: surprising behaviors you locked down as-is (from Rule 3). Write "none" if empty.
4. Delete nothing. Leave `agentic-test-plan.md` and all agent tests in place.
