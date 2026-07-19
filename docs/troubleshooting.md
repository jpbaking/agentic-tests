# Troubleshooting & FAQ

## The skill stops immediately

**"Working tree not clean"** — the suite refuses to mix its output with your pending changes (and mutation testing rewrites source temporarily — a dirty tree risks your work). Commit or stash; agent tests, test config, and plan files are exempt.

**"Main code does not build"** — by design. The suite characterizes working code; it will not paper over compile errors. Fix the build first.

**"No test framework"** — the skill asks before installing one as a dev/test dependency. Answer, or install your preferred framework yourself and re-run.

## Mid-run problems

**The session died / hit a rate limit / lost context.**
Re-run the same command. The plan file (`agentic-test-plan.md`) is updated after every entry, so the skill re-runs the baseline and resumes from the first non-`done` entry. Nothing is lost.

**A file is marked `FAILED (3 attempts)`.**
Working as intended — after 3 failed tries the agent reverts to the last working test and moves on rather than thrashing. Common causes and fixes:

| Reason logged | What it means | Your options |
|---|---|---|
| `not isolatable without source change` | no seam: hardwired `new Database()`, direct `System.getenv`, non-virtual C++ dep | accept the gap, or add a seam yourself (your edit, not the agent's) and re-run |
| deep/unreachable branch | needs state the public API can't produce | accept, or reconsider whether the branch is dead code |
| flaky | test passed some of 3 runs | usually real time/randomness/shared state — point the agent at the [mocking recipes](../skills/shared/agentic-unit-test/docs/mocking-recipes.md) |

**Coverage goal NOT MET at the end.**
The report says by how much and which files fell short. Options: re-run scoped to the weak files, lower the goal, or accept — the report never rounds up on your behalf.

## Quality worries

**Are the tests real, or coverage padding?**
Two gates make padding a rule violation: quality rules (every test must call the code under test and assert on its result; `assertTrue(true)`-style tests count as *failed attempts*) and the 3-run flakiness gate. For hard proof, run `/agentic-mutation-check report-only` — surviving mutants pinpoint any weak assertions.

**A test locked in behavior that looks like a bug.**
Also working as intended — the suite locks *current* behavior and flags surprises in its report's **Notes** section. Decide yourself: if it's a bug, fix your code, then run `/agentic-test-update` and confirm the diff.

**My weak/cheap model still writes bad React tests.**
Make sure it's actually reading the recipes — they're loaded on demand from the skill's `docs/`. The recipes exist precisely for this: [react-redux.md](../skills/shared/agentic-unit-test/docs/mocking-recipes/react-redux.md) (real store per test, never mock `useSelector`) and [react-general.md](../skills/shared/agentic-unit-test/docs/mocking-recipes/react-general.md) (probe routes, real providers, `findBy` for async). If it keeps mocking `react-redux`, quote Rule zero back at it in your prompt.

## FAQ

**Do agent tests replace my tests?** No. They coexist; yours are never touched. Agent tests are a *refactoring* net — your tests encode intent, agent tests encode current behavior.

**Should I commit agent tests?** Yes, if you want the net in CI and for teammates. They're normal test files. (`/agentic-test-clean` can always remove them wholesale.)

**Can I run this in CI?** The suite itself is interactive-by-design (it asks for goals, confirmations). But the *generated* tests run anywhere your normal suite runs — see the [coverage recipes](../skills/shared/agentic-unit-test/docs/coverage-recipes.md) for agent-tests-only commands you can wire into CI.

**Why can't the agent just fix my code when a test fails?** Because then the test proves nothing. One-directional trust — code is the spec, tests conform — is the entire safety model. The single exception flow is `/agentic-test-update`, where *you* confirm each behavior change explicitly.

**Which model should I use?** Any. The suite was explicitly hardened for weaker models (binary steps, templates, fixed vocabularies); stronger models just finish faster with fewer `FAILED` entries.
