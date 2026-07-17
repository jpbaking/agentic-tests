# Mocking recipes — index

## General rules (apply in every language)

1. **Never mock the unit under test.** Mock only its boundaries.
2. Mock only these 6 boundary kinds: **time/clock, randomness, network/HTTP, filesystem, database, environment variables**. For pure logic, use real objects and real values.
3. Keep mocks inside the agent-test file. Do not create shared mock helpers in main-code directories (that would break Rule 1 of the skill).
4. Reset/restore all mocks after each test (`afterEach`/teardown), so tests stay order-independent (this is what the 3-run flakiness check catches).
5. If a class is impossible to isolate without editing main code: do NOT edit main code. Mark the plan entry `FAILED` with reason "not isolatable without source change" and move on.

## Per-language recipes

| Language / framework | Open |
|---|---|
| JavaScript / TypeScript (Jest, Vitest) | `mocking-recipes/js-ts.md` |
| React + Redux components/slices/thunks | `mocking-recipes/react-redux.md` (plus `js-ts.md` for boundaries) |
| React Router, Context, custom hooks, async rendering | `mocking-recipes/react-general.md` |
| Java (JUnit 5 + Mockito) | `mocking-recipes/java.md` |
| Groovy (Spock built-in Mock/Stub/Spy) | `mocking-recipes/groovy-spock.md` |
| Python (pytest + unittest.mock) | `mocking-recipes/python.md` |
| C / C++ (GoogleTest/GoogleMock) | `mocking-recipes/c-cpp.md` |
| Go (interfaces + httptest, testing helpers) | `mocking-recipes/go.md` |
| Rust (traits + integration tests) | `mocking-recipes/rust.md` |

Open ONLY the one file for your language.
