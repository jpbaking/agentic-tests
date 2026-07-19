---
name: agentic-mutation-check
description: Verify that agent tests (*.agentic.spec.ts, *AgenticTest.java, test_agentic_*.py, ...) truly lock behavior by running mutation testing against them only, then strengthening agent tests to kill surviving mutants. Use after agentic-unit-test, when asked to check test strength or mutation score.
---

# Agentic Mutation Check

Coverage says a line was *executed*; mutation testing says a change to that line would be *caught*. This skill proves the agent-test safety net actually holds.

## RULES

1. **NEVER edit main code or user tests.** You may only edit agent tests, mutation-tool config, and `agentic-test-plan.md`. (Mutation tools mutate main code *temporarily and automatically* — that is fine; YOU never edit it.)
2. Only agent tests run against the mutants.
3. Strengthening an agent test means adding/tightening assertions on real behavior — the test-quality rules from the `agentic-unit-test` skill apply here too.

## Step 1 — Ask the user

1. "Mutation score goal: what %? Or report-only (no fixing)?"
2. Scope: same as the agent tests' scope, unless the user narrows it.

## Step 2 — Preconditions (STOP if any fails)

1. Agent tests exist and ALL pass. If not: tell the user to use the `agentic-unit-test` skill first, and STOP.
2. Git repo must be clean except agent tests / test config / plan files (`git status --porcelain`) — mutation tools rewrite source temporarily; a dirty tree risks losing work. STOP if dirty.
3. A mutation tool is available or installable as a dev/test dependency (ask before installing):

| Stack | Tool | Run against agent tests only |
|---|---|---|
| JS/TS (Jest/Vitest) | StrykerJS | `npx stryker run` with `testRunner` config's test filter set to `**/*.agentic.spec.*` |
| Java (Maven) | PIT | `mvn org.pitest:pitest-maven:mutationCoverage -DtargetTests='*AgenticTest'` |
| Java (Gradle) | PIT plugin | `pitest { targetTests = ['*AgenticTest'] }` |
| Groovy/Spock (Maven/Gradle) | PIT | same as Java — PIT runs on the JUnit platform Spock uses; set the target-tests filter to `*AgenticSpec` |
| Python | mutmut | `mutmut run --runner "python -m pytest -x -o python_files='test_agentic_*.py'"` |
| Go | gremlins | `gremlins unleash ./...` — runs the package's `go test`; keep the tree agent-tests-only (or move user tests aside) so only agent tests judge the mutants |
| Rust | cargo-mutants | `cargo mutants -- --test agentic_<name>` — the args after `--` restrict `cargo test` to the agent integration target(s) |
| C/C++ | (no mature default) | Report "mutation testing not supported for this stack" and STOP |

## Step 3 — Baseline run

Run the tool. Record: mutation score %, killed, survived, timed-out. List every surviving mutant as `file:line — mutation description`.

If report-only was chosen: print the report (Step 5 format) and STOP.

## Step 4 — Kill survivors

For each surviving mutant, strongest-signal first (mutants in core logic before boilerplate):

1. Read the mutated line and the agent test covering it. The mutant survived because no assertion pins that behavior.
2. Strengthen the agent test: add an assertion (or a new test case) that the ORIGINAL code satisfies and the mutant would not.
3. Run the agent test suite — must still fully pass (on original code).
4. **3 attempts per mutant.** After the 3rd failure, revert the test to its last passing form, mark the mutant "unkilled", move on.
5. Re-run mutation testing after each batch of ~5 fixes (full runs are slow). Stop when the goal is met.

Equivalent mutants (mutations that provably cannot change observable behavior, e.g. `<` → `<=` on an unreachable boundary): mark "equivalent — not killable" with one line of justification; they don't count against you.

## Step 5 — Report

- **Goal**: score %, MET / NOT MET.
- **Score**: before → after; killed/survived/timed-out counts.
- **Unkilled mutants**: `file:line — mutation — why` (or "none").
- **Equivalent mutants**: list with justification (or "none").
