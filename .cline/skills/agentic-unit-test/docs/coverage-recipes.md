# Coverage recipes — agent tests only

Run coverage so that **only agent tests execute** while coverage is still measured against the main code. Prefer CLI flags over editing config; edit test config only when flags can't express the filter (allowed by the hard rules).

## Which recipe? Check for these files:

| You see | Use |
|---|---|
| `jest.config.*`, or `"jest"` in package.json | Jest |
| `vitest.config.*`, or vitest in package.json | Vitest |
| `pom.xml` | Maven |
| `build.gradle` / `build.gradle.kts` | Gradle |
| `pytest.ini`, `pyproject.toml`, `setup.py` | Pytest |
| `CMakeLists.txt`, `Makefile` (C/C++) | gcov/llvm-cov |

Copy the command as-is; only replace obvious placeholders like `<package>`.

## Jest (JS/TS)

```bash
npx jest --coverage \
  --testMatch '**/*.agentic.@(spec|test).@(ts|tsx|js|jsx)' \
  --coverageReporters text --coverageReporters lcov
```

- Per-file goal: add `coverageThreshold` with a glob per file, or parse `coverage/coverage-summary.json` (add `json-summary` reporter).
- Project-overall goal: `coverageThreshold: { global: { lines: N, branches: N, ... } }`.

## Vitest

```bash
npx vitest run --coverage \
  --include '**/*.agentic.{spec,test}.{ts,js}'
```

## Maven (Java, Surefire + JaCoCo)

Run only agent tests without touching the POM when possible:

```bash
mvn test jacoco:report -Dtest='*AgenticTest'
```

If JaCoCo isn't configured, adding the `jacoco-maven-plugin` to the POM's test setup is permitted (test config). Report lands in `target/site/jacoco/`; parse `jacoco.xml` for per-file numbers.

## Gradle (Java)

```bash
./gradlew test jacocoTestReport --tests '*AgenticTest'
```

## Pytest (Python)

```bash
pytest 'test_agentic_*.py' --cov=<package> --cov-branch \
  --cov-report=term-missing --cov-report=xml
```

Use `-o python_files='test_agentic_*.py'` (or a dedicated `[tool.pytest.ini_options]` block) if collection patterns need overriding. Parse `coverage.xml` for per-file goals.

## C/C++ (gcov/llvm-cov + CTest/GoogleTest)

- Build test targets with `--coverage` (gcc) or `-fprofile-instr-generate -fcoverage-mapping` (clang) — as part of test build config only.
- Run only agent-test binaries/targets: `ctest -R 'agentic'` (name agent-test CMake targets with an `agentic` infix).
- Report: `gcovr --txt --json-summary` or `llvm-cov report`, filtered to main sources (`--filter src/`).

## Reading results

- **Per-file goal**: every in-scope source file must individually meet the target.
- **Project-overall goal**: the aggregate over in-scope sources must meet the target.
- Always exclude user tests, agent tests themselves, and generated code from the coverage denominator.
