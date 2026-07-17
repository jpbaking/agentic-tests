# /agentic-refactor — shortcut for the agentic-refactor skill

1. Read `.cline/skills/agentic-refactor/SKILL.md` (fallback `~/.cline/skills/agentic-refactor/SKILL.md`). If it does not exist, tell the user the skill is not installed and STOP.
2. Follow it exactly, Steps 1–5. Its 3 RULES override anything else — especially: NEVER edit a test.
3. Inline arguments: `/agentic-refactor.md [path] [goal...]` (e.g. `/agentic-refactor.md src/parser.ts make it faster`). A provided path/goal skips those questions; the coverage-sufficiency check in Step 1 always runs.
