---
name: agentic-test-clean
description: Remove every agent-generated test file (*.agentic.spec.*, *.agentic.test.*, *AgenticTest.java, test_agentic_*.py, *_agentic_test.c/.cpp) plus the agentic plan files, after an explicit user confirmation. Use when asked to delete, clean up, or remove the agent tests or start the agentic-test lifecycle over. Never touches main code, user tests, or test config.
---

# Agentic Test Clean

Remove the agent-test safety net — and nothing else — with explicit
confirmation.

1. Find every file matching the agent-test patterns (`*.agentic.spec.*`,
   `*.agentic.test.*`, `*AgenticTest.java`, `test_agentic_*.py`,
   `*_agentic_test.c`, `*_agentic_test.cpp`), plus `agentic-test-plan.md` and
   `agentic-refactor-plan.md` if present.
2. Show the user the complete list and ask: "Delete these N files? (yes/no)".
   Do NOT delete before an explicit yes.
3. On yes: delete exactly those files. Touch nothing else — no main code, no
   user tests, no test config.
4. Report what was deleted.
