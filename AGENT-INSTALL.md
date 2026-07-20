# Agentic Tests — agent-guided install

You are an AI coding agent installing Agentic Tests. Follow these steps
exactly. This procedure is merge-aware — it never blindly overwrites files
the user already owns — and it is the only install path; there are no
install scripts.

Agentic Tests is a **user-global** toolkit: its skills install once per user
into each harness's global discovery paths. Nothing is installed into
projects — the per-project footprint is the generated agent-test files the
skills produce during use (`*.agentic.spec.*`, …), which are the project's
safety net and **belong in version control** (never gitignore them).
Project-level adapter install is an explicit opt-in (see the last section).

Source repository: `https://github.com/jpbaking/agentic-tests`. If the user
named a fork or tag, substitute it below.

## 1. Acquire the sources

Obtain the sources in a temporary directory (never inside a project):

- `git clone --depth 1 https://github.com/jpbaking/agentic-tests <tmp>/agentic-tests`
  (add `--branch <tag>` for a pinned tag), or
- download and extract `https://github.com/jpbaking/agentic-tests/archive/refs/heads/main.zip`
  (or the tarball `https://codeload.github.com/jpbaking/agentic-tests/tar.gz/main`), or
- `gh repo clone jpbaking/agentic-tests <tmp>/agentic-tests`.

Copy from this staging directory below; delete it when done.

## 2. Survey before writing

Check for same-named `agentic-*` skills in the global directories listed
below and, if you are inside a project, under its `.agents/skills/`,
`.claude/skills/`, `.cline/skills/`, plus legacy
`.clinerules/workflows/agentic-*.md` shortcut files. Report anything you
find; a project-level or legacy copy with the same name can shadow or
duplicate the global install.

## 3. Install the skills (byte-identical copies)

For each skill directory:

- `agentic-unit-test` (includes its `docs/` recipes and templates)
- `agentic-mutation-check`
- `agentic-refactor`
- `agentic-test-update`
- `agentic-coverage-report`
- `agentic-test-clean`

copy the whole directory from `skills/shared/<name>/` (replacing any
existing same-named directory so retired resources cannot linger) to each
selected harness's global skills directory (ask which harnesses if unclear;
all four is a safe default):

| Harness | Destination |
| --- | --- |
| Codex | `~/.agents/skills/<name>/` |
| Claude Code | `~/.claude/skills/<name>/` |
| Antigravity | `~/.gemini/config/skills/<name>/` |
| Cline | `~/.cline/skills/<name>/` |

Cursor needs **no separate copy**: it natively discovers `~/.agents/skills/`
(and `~/.claude/skills/` / `~/.codex/skills/` as compatibility paths). Do
not install to `~/.cursor/skills/` — that would create a duplicate.

All copies must be byte-identical across harnesses. Never touch other
skills.

## 4. Validate and report

1. Verify every installed `agentic-*` directory is byte-identical across the
   selected destinations and to the canonical source, and that each
   `SKILL.md` frontmatter `name` matches its directory.
2. Remove the temporary staging directory.
3. Report every file created, changed, or intentionally left alone, plus
   collisions and legacy workflow files from step 2 (suggest deleting legacy
   `.clinerules/workflows/agentic-*.md` shortcuts or old gitignored
   project-level adapters only with user approval).
4. Tell the user the entry point: ask their agent to use the
   `agentic-unit-test` skill (then `agentic-mutation-check`,
   `agentic-refactor`, and the rest as needed). Codex: `$` mention;
   Claude Code, Antigravity, Cline: `/agentic-unit-test`. Remind them the
   generated agent-test files are committed project files.

## Project-level adapter install (opt-in only)

Only on explicit user request: copy the six skill directories to the
project's `.agents/skills/` and `.claude/skills/` (byte-identical), and
optionally merge this section into the project's `AGENTS.md` (create it with
a `# Project rules` heading if missing; leave it if it already mentions
`agentic-unit-test`; preserve all existing content):

> ## Agentic Tests
>
> This project uses the Agentic Tests skill suite (agentic-unit-test,
> agentic-mutation-check, agentic-refactor, agentic-test-update,
> agentic-coverage-report, agentic-test-clean): use the matching skill when
> its description applies, and never edit main code or user-written tests
> while doing test work. If the skills are not available, they are an
> optional user-global install — offer to install them from
> https://github.com/jpbaking/agentic-tests and proceed only if the user
> agrees.

For `CLAUDE.md`: if missing, create it containing only `@AGENTS.md`; if it
exists and already imports `AGENTS.md` or mentions agentic tests, leave it;
otherwise prepend the `@AGENTS.md` line once and preserve the rest. Apply
the same merge logic to `GEMINI.md` if the project uses it. Whether the
team commits or gitignores the adapters is the project's own policy — never
touch the project's `.gitignore` yourself. Never gitignore the generated
agent-test files; if existing ignore rules hide the adapters from a harness,
report the exact pattern instead of changing it.
