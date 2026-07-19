# Agentic Tests — agent-guided install

You are an AI coding agent installing Agentic Tests into the project at the
current working directory. Follow these steps exactly. This procedure is
merge-aware: it never blindly overwrites files the project already owns, which
is why it is preferred over the script installers.

Source repository: `https://github.com/jpbaking/agentic-tests`. If the user
named a fork or tag, substitute it below.

## 1. Survey before writing

1. Confirm you are at the target project's root.
2. Note whether these exist: `AGENTS.md`, `CLAUDE.md`, `.gitignore`.
3. Check for same-named `agentic-*` skills under `.agents/skills/`,
   `.claude/skills/`, `.cline/skills/`, and the user-global equivalents
   (`~/.agents/skills/`, `~/.claude/skills/`, `~/.cline/skills/`), plus
   legacy `.clinerules/workflows/agentic-*.md` shortcut files. Report
   anything you find; a global or legacy copy with the same name can shadow
   or duplicate the project install.

## 2. Install the skills

Obtain the repository's `skills/shared/` tree — clone with
`git clone --depth 1`, or download the tarball
(`https://codeload.github.com/jpbaking/agentic-tests/tar.gz/main`). For each
skill directory:

- `agentic-unit-test` (includes its `docs/` recipes and templates)
- `agentic-mutation-check`
- `agentic-refactor`
- `agentic-test-update`
- `agentic-coverage-report`
- `agentic-test-clean`

copy the whole directory (replacing any existing same-named directory) to
BOTH `.agents/skills/<name>/` (Codex, Antigravity, current Cline) and
`.claude/skills/<name>/` (Claude Code). The copies must be byte-identical.
Never touch other skills.

## 3. Bridge files — merge, never overwrite

- `AGENTS.md`: if it already mentions `agentic-unit-test`, leave it.
  Otherwise create it (heading `# Project rules`) if missing, then append
  this section once, preserving all existing content:

  > ## Agentic Tests
  >
  > If `.agents/skills/agentic-unit-test/` exists, this project uses the
  > Agentic Tests skill suite (agentic-unit-test, agentic-mutation-check,
  > agentic-refactor, agentic-test-update, agentic-coverage-report,
  > agentic-test-clean): use the matching skill when its description applies,
  > and never edit main code or user-written tests while doing test work. If
  > the skills are missing (fresh clone — they are gitignored), re-run the
  > installer from https://github.com/jpbaking/agentic-tests.

- `CLAUDE.md`: if missing, create it containing only `@AGENTS.md`. If it
  exists and already imports `AGENTS.md` or mentions agentic tests, leave it;
  otherwise prepend the `@AGENTS.md` line once and preserve the rest.
- If the project uses `GEMINI.md`, apply the same merge logic there.

## 4. Gitignore the generated adapters

Add this block to `.gitignore` once (skip if the marker line already exists);
create the file if missing and never delete existing rules:

```gitignore
# Agentic Tests installer-managed agent adapters (generated; do not edit or commit)
.agents/skills/agentic-unit-test/
.claude/skills/agentic-unit-test/
.agents/skills/agentic-mutation-check/
.claude/skills/agentic-mutation-check/
.agents/skills/agentic-refactor/
.claude/skills/agentic-refactor/
.agents/skills/agentic-test-update/
.claude/skills/agentic-test-update/
.agents/skills/agentic-coverage-report/
.claude/skills/agentic-coverage-report/
.agents/skills/agentic-test-clean/
.claude/skills/agentic-test-clean/
```

Do NOT gitignore `AGENTS.md` or `CLAUDE.md`, and do NOT gitignore the
generated agent-test files themselves (`*.agentic.spec.*`, …) — those are the
project's safety net and belong in version control. Because the skill
adapters are gitignored, a fresh clone lacks them; the conditional bridge
text degrades safely, and re-running this procedure (or `install.sh`)
regenerates them.

## 5. Validate and report

1. Verify every `.agents/skills/agentic-*` directory is byte-identical to
   its `.claude` twin, and that each `SKILL.md` frontmatter `name` matches
   its directory.
2. Report every file created, changed, or intentionally left alone, plus
   collisions and legacy workflow files from step 1 (suggest deleting legacy
   `.clinerules/workflows/agentic-*.md` shortcuts only with user approval).
3. Tell the user the entry point: ask their agent to use the
   `agentic-unit-test` skill (then `agentic-mutation-check`,
   `agentic-refactor`, and the rest as needed). Codex: `$` mention;
   Claude Code, Antigravity, Cline: `/agentic-unit-test`.
