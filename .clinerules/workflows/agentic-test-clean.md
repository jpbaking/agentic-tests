# /agentic-test-clean — remove all agent tests

1. Find every file matching the agent-test patterns (`*.agentic.spec.*`, `*.agentic.test.*`, `*AgenticTest.java`, `test_agentic_*.py`, `*_agentic_test.c`, `*_agentic_test.cpp`), plus `agentic-test-plan.md` and `agentic-refactor-plan.md` if present.
2. Show the user the complete list and ask: "Delete these N files? (yes/no)". Do NOT delete before an explicit yes.
3. On yes: delete exactly those files. Touch nothing else — no main code, no user tests, no test config.
4. Report what was deleted.
