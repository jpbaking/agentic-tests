---
name: agentic-coverage-report
description: Read-only report of where the agent-generated tests (*.agentic.spec.ts, *AgenticTest.java, test_agentic_*.py, ...) stand — agent-tests-only coverage, goal MET/NOT MET from agentic-test-plan.md, and any failing agent tests. Use when asked how the agent tests are doing, what coverage the agent tests reach, or whether the recorded goal is met. Never creates, edits, or deletes files.
---

# Agentic Coverage Report

Read-only: do NOT create, edit, or delete any test, source, config, or plan
file. Report and stop.

1. Read the `agentic-unit-test` skill's `SKILL.md` for the agent-test
   definitions, and `docs/coverage-recipes.md` next to it for the
   agent-tests-only coverage command. Both live in the sibling
   `agentic-unit-test` skill directory (`../agentic-unit-test/` relative to
   this file). If that skill is not installed, say so and STOP.
2. If no agent tests exist in the project, report "no agent tests found — use
   the `agentic-unit-test` skill to generate them" and STOP.
3. Run the agent-tests-only coverage command for this project's framework.
4. Print the `agentic-unit-test` skill's Step-5-style report:
   - **Goal**: read it from `agentic-test-plan.md` if that file exists (state
     MET / NOT MET); otherwise write "no goal on record".
   - **Coverage**: overall % and per-file table.
   - **Failing agent tests**: list any (or "none").
