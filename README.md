# 🔒 Agentic Tests

> **Lock down your code. Refactor without fear.**

A suite of [Cline](https://cline.bot) skills and slash-command workflows that turns any AI model — *even small, cheap ones* — into a disciplined test engineer. It generates unit tests that capture your code's **current behavior**, proves those tests actually hold with **mutation testing**, then lets you **refactor at full speed** with a safety net it never touches.

Your code stays yours. Your tests stay honest. Your coverage number finally means something.

---

## Why this exists

Every AI coding agent can *write tests*. Almost none can be *trusted* with them:

- 🙈 They "fix" your production code to make their tests pass
- 🎭 They pad coverage with `expect(true).toBe(true)`
- 🎲 They write flaky tests that pass today and lie tomorrow
- 🧟 They mock `useSelector` and call it a React test

**Agentic Tests is built around hard rules, not good intentions.** Main code is read-only. User-written tests are read-only. Every generated test must survive a 3-run flakiness gate and a test-quality checklist. Coverage is measured on agent-generated tests *alone* — no credit borrowed from your existing suite.

## What's inside

| Skill | Slash command | What it does |
|---|---|---|
| 🏗️ **agentic-unit-test** | `/agentic-unit-test.md` | Generates tests to hit *your* coverage goal (line/branch/function, per-file or overall) |
| 🧬 **agentic-mutation-check** | `/agentic-mutation-check.md` | Mutation-tests the safety net — proves the tests catch real changes |
| ⚡ **agentic-refactor** | `/agentic-refactor.md` | Refactors/optimizes main code; the frozen test suite is the referee |
| 🔁 **agentic-test-update** | `/agentic-test-update.md` | Re-locks tests after *intentional* behavior changes — one confirmation per diff |
| 📊 — | `/agentic-coverage-report.md` | Where do the agent tests stand? Read-only report |
| 🧹 — | `/agentic-test-clean.md` | Remove every agent test (with confirmation) |

## 30-second start

```
you:   /agentic-unit-test.md src/pricing.ts branch 90 per-file
cline: ✅ preconditions… 📊 baseline 0%… 📝 plan written… 🏗️ generating…
       ─────────────────────────────────────
       Goal: branch ≥ 90% per-file — MET (93.4%)
       Failures: none
```

Then make it bulletproof, and use it:

```
/agentic-mutation-check.md 85        ← prove the tests bite
/agentic-refactor.md src/pricing.ts make it faster   ← refactor with the net up
```

## The guarantees

1. **Your code is never edited.** Not to fix a test, not "just a little", never.
2. **Your tests are never edited.** Agent tests live in clearly-named files (`*.agentic.spec.ts`, `*AgenticTest.java`, `test_agentic_*.py`, …) — everything else is read-only.
3. **The goal is met by agent tests alone**, with assertion-quality rules and a flakiness gate that make gaming the number a rule violation, not a shortcut.

Interrupted mid-run? Every skill writes a crash-proof plan file and resumes exactly where it stopped.

## Built for weaker models, great with strong ones

Every instruction is written so a small model can't wander: numbered steps with binary branches, fixed report formats, copy-paste templates for 6 languages, framework detection by file lookup, and a 3-attempt gate that reverts cleanly instead of thrashing. Recipes cover the classic weak-model tar pits — mocking time/network/filesystem, **React + Redux** (real store, never mock `useSelector`), **React Router & Context** (probe routes, never mock `useNavigate`), and async rendering.

## Language support

| | Tests | Coverage | Mutation |
|---|:-:|:-:|:-:|
| TypeScript / JavaScript (Jest, Vitest) | ✅ | ✅ | ✅ StrykerJS |
| Java (JUnit 5, Maven/Gradle) | ✅ | ✅ JaCoCo | ✅ PIT |
| Python (pytest) | ✅ | ✅ coverage.py | ✅ mutmut |
| C / C++ (GoogleTest, CTest) | ✅ | ✅ gcov/llvm-cov | — |

## Install

Workspace-local (this repo): already done — `.cline/skills/` and `.clinerules/workflows/` are picked up automatically.

Everywhere: copy `.cline/skills/*` → `~/.cline/skills/` and `.clinerules/workflows/*` → `~/Documents/Cline/Workflows/`.

## Learn more

📚 **[User guide](docs/)** — [Getting started](docs/getting-started.md) · [Core concepts](docs/concepts.md) · [Command reference](docs/commands.md) · [The lock-down lifecycle](docs/lifecycle.md) · [Troubleshooting & FAQ](docs/troubleshooting.md)
