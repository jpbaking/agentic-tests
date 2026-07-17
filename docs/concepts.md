# Core concepts

## Agent tests vs user tests

Everything hinges on one filename convention:

| Language | Agent-test filename |
|---|---|
| TypeScript | `<name>.agentic.spec.ts` (`.tsx` with JSX) |
| JavaScript | `<name>.agentic.spec.js` (`.jsx` with JSX) |
| Java | `<Name>AgenticTest.java` |
| Groovy (Spock) | `<Name>AgenticSpec.groovy` |
| Python | `test_agentic_<name>.py` |
| C / C++ | `<name>_agentic_test.c` / `.cpp` |
| Go | `<name>_agentic_test.go` (funcs named `TestAgentic…`) |
| Rust | `tests/agentic_<name>.rs` (integration test — never a `#[cfg(test)]` mod in source) |

Files matching these patterns are **agent tests**: the suite creates, edits, strengthens, and (on request) deletes them. Every other test file is a **user test**: read-only, always, no exceptions.

This split is what makes the suite safe to run repeatedly and trivial to undo — `/agentic-test-clean.md` can delete every trace because agent tests are unmistakable by name.

## Characterization, not judgment

The suite assumes your main code is **correct by definition**. Its job is to *lock down* current behavior so you can refactor, optimize, or upgrade dependencies with proof that nothing observable changed.

Consequence: if a generated test reveals surprising behavior (`priceWithTax(0, 0.2)` returns `-0`?), the test asserts the surprise **as-is** and flags it in the report. The agent never "fixes" your code — that decision is yours, and when you make it, [`agentic-test-update`](commands.md#agentic-test-update) re-locks the tests afterwards.

## The hard rules

1. **Main code and user tests are never edited.** Only agent tests, test *configuration* (jest config, surefire includes, pytest options, lint globs), and plan files.
2. **Coverage is measured on agent tests alone.** Your existing suite's coverage doesn't count toward the goal — the point is a safety net that stands by itself.
3. **A failing test is never "fixed" by weakening it** — and in `agentic-refactor` the polarity flips: there, a failing test means the *code change* is wrong.

## Quality gates (why the numbers are trustworthy)

- **Test-quality rules** — assertion-free tests, `expect(true)`-style padding, and asserting on your own mock setup are rule violations that count as *failed attempts*, not shortcuts to the goal.
- **Flakiness gate** — every test must pass **3 consecutive runs** before it counts. Nondeterminism (real time, real network, shared state) gets caught at birth.
- **3-attempt gate** — the agent gets 3 tries per file/function/branch. Then it reverts to the last working version, records the failure honestly, and moves on. No thrashing, no half-broken leftovers.
- **Mutation testing** (optional but recommended) — coverage says a line was *executed*; a mutation score says a change to it would be *caught*. `/agentic-mutation-check.md` reports and closes the gap.

## Plan files (crash-proofness)

Long generation runs die: rate limits, closed laptops, context overflows. Every skill writes its plan to a markdown file at the repo root (`agentic-test-plan.md`, `agentic-refactor-plan.md`) and updates it after **every** entry — never in batches. Re-running the command resumes from the first unfinished entry. Statuses are a fixed vocabulary: `pending`, `in-progress`, `done (NN%)`, `FAILED (3 attempts): reason`.

## Coverage goals

You choose three things up front, and the skill won't start without them:

- **Metric**: line, branch, function, or statement
- **Target**: a percentage
- **Granularity**: *per-file* (every file in scope must individually hit the target — stricter, better for refactor safety) or *overall* (the aggregate hits the target — faster, allows weak spots)

## Designed for weaker models

The instructions assume nothing: binary yes/no branches instead of judgment calls, fixed report formats, framework detection by "which file exists" tables, copy-paste [templates](../.cline/skills/agentic-unit-test/docs/templates/) per language, and [mocking recipes](../.cline/skills/agentic-unit-test/docs/mocking-recipes.md) for the places small models reliably sink: time/network/filesystem isolation, React + Redux (real store per test — never mock `useSelector`), React Router and Context (probe routes — never mock `useNavigate`), and async rendering.
