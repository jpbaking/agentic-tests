# Getting started

## Prerequisites

- An agent harness with Agent Skills support: [Codex](https://learn.chatgpt.com/docs/build-skills), [Claude Code](https://code.claude.com/docs/en/slash-commands), [Google Antigravity](https://antigravity.google/docs/skills), or [Cline](https://docs.cline.bot/customization/skills) (v3.48+)
- A project that **builds cleanly** — the suite refuses to test broken code
- A test framework (Jest/Vitest, JUnit, pytest, GoogleTest, …). If missing, the skill will ask before installing one as a dev dependency
- Recommended: a git repository with a **clean working tree** — required by `agentic-refactor` and `agentic-mutation-check`, and checked by `agentic-unit-test`

## Installation

**Preferred — agent-guided.** Paste this into your coding agent from the target project's root; it merges with existing `AGENTS.md` / `CLAUDE.md` / ignore files instead of colliding with them:

```
Fetch https://raw.githubusercontent.com/jpbaking/agentic-tests/main/AGENT-INSTALL.md and follow its instructions exactly to install Agentic Tests into this project. Merge with — never blindly overwrite — any existing AGENTS.md, CLAUDE.md, or ignore files, and report every file you created or changed.
```

**Script alternative**, from the target project's root:

```bash
curl -fsSL https://raw.githubusercontent.com/jpbaking/agentic-tests/main/install.sh | sh
# Windows: irm https://raw.githubusercontent.com/jpbaking/agentic-tests/main/install.ps1 | iex
```

Both paths copy the six skills from the repo's canonical `skills/shared/` into `.agents/skills/` (Codex, Antigravity, current Cline) and `.claude/skills/` (Claude Code), add conditional `AGENTS.md` / `CLAUDE.md` pointers, and gitignore the installed skill copies. On a fresh clone the skills are therefore absent — re-run either path to regenerate them. Claude Code, Antigravity, and Cline then expose each skill as a `/agentic-*` slash command; Codex uses a `$` skill mention; and every harness can activate a skill implicitly when your request matches its description.

## Your first run

1. Commit or stash any pending changes (`git status` should be clean).
2. Ask your agent (slash form shown; "use the agentic-unit-test skill on src/pricing.ts" works everywhere):

   ```
   /agentic-unit-test src/pricing.ts
   ```

3. Answer the two questions (coverage metric, goal % + per-file/overall) — or skip them by passing everything inline:

   ```
   /agentic-unit-test src/pricing.ts branch 90 per-file
   ```

4. Watch the plan file `agentic-test-plan.md` appear at the repo root and tick over as each file completes. If the session dies, just re-run the command — it resumes from the plan.
5. Read the final report: goal MET/NOT MET, per-file coverage table, and anything the agent failed to test (with reasons).

Whole project instead of one file? Use `.` as the path, or just omit it and answer "whole project" when asked.

## What you'll have afterwards

- New test files next to your code (or in your test dir), clearly named: `pricing.agentic.spec.ts`, `PricingAgenticTest.java`, `test_agentic_pricing.py`, …
- `agentic-test-plan.md` — the run's plan/progress log. Keep it (it records the goal for `/agentic-coverage-report`) or delete it; it regenerates.
- **Zero changes** to your source code or your own tests. Verify: `git diff --stat` shows only new agent-test files and (possibly) test config.

## Next steps

- Prove the tests actually bite → [`/agentic-mutation-check`](commands.md#agentic-mutation-check)
- Refactor with the net up → [`/agentic-refactor`](commands.md#agentic-refactor)
- Understand the rules of the game → [Core concepts](concepts.md)
