# /agentic-test-update — shortcut for the agentic-test-update skill

1. Read `.cline/skills/agentic-test-update/SKILL.md` (fallback `~/.cline/skills/agentic-test-update/SKILL.md`). If it does not exist, tell the user the skill is not installed and STOP.
2. Follow it exactly, Steps 1–4. Its RULES override anything else — especially: per-diff user confirmation before updating any test, and unconfirmed failures stay failing.
3. Inline argument: `/agentic-test-update.md [path]` limits reconciliation to failures caused by that file/directory.
