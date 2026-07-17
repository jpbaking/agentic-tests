# /agentic-unit-test — shortcut for the agentic-unit-test skill

You have been invoked as a shortcut. Do exactly this:

1. Read the file `.cline/skills/agentic-unit-test/SKILL.md` in this workspace (fall back to `~/.cline/skills/agentic-unit-test/SKILL.md` if the workspace copy does not exist). If neither exists, tell the user the agentic-unit-test skill is not installed and STOP.
2. Follow that skill's instructions exactly, from Step 1 to Step 5. Its 3 RULES override anything else.
3. Inline arguments: the user may pass answers after the command, in this fixed order:

   `/agentic-unit-test.md [path] [metric] [goal%] [per-file|overall]`

   Examples:
   - `/agentic-unit-test.md src/foo.ts` → scope known; ask metric, goal, granularity.
   - `/agentic-unit-test.md src/foo.ts branch 90 per-file` → nothing to ask; start at Step 2.
   - `/agentic-unit-test.md . line 80 overall` → `.` means whole project.

   For each argument provided, skip that question in the skill's Step 1; ask only the missing ones.
