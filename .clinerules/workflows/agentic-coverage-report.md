# /agentic-coverage-report — where do the agent tests stand?

Read-only: do NOT create, edit, or delete any test or source file.

1. Read `.cline/skills/agentic-unit-test/SKILL.md` (fallback `~/.cline/skills/agentic-unit-test/SKILL.md`) for the agent-test definitions, and `docs/coverage-recipes.md` next to it for the coverage command. If the skill is not installed, say so and STOP.
2. If no agent tests exist in the project, report "no agent tests found — run /agentic-unit-test.md" and STOP.
3. Run the agent-tests-only coverage command for this project's framework.
4. Print the skill's Step-5-style report:
   - **Goal**: read it from `agentic-test-plan.md` if that file exists (state MET / NOT MET); otherwise write "no goal on record".
   - **Coverage**: overall % and per-file table.
   - **Failing agent tests**: list any (or "none").
