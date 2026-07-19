# Coverage recipes — agent tests only

Run coverage so that **only agent tests execute** while coverage is still measured against the main code. Prefer CLI flags over editing config; edit test config only when flags can't express the filter (allowed by the hard rules).

## Which recipe? Check for these files:

| You see | Use |
|---|---|
| `jest.config.*`, or `"jest"` in package.json | Jest |
| `vitest.config.*`, or vitest in package.json | Vitest |
| `pom.xml` | Maven (JUnit **or** Spock) |
| `build.gradle` / `build.gradle.kts` | Gradle (JUnit **or** Spock) |
| `pytest.ini`, `pyproject.toml`, `setup.py` | Pytest |
| `CMakeLists.txt`, `Makefile` (C/C++) | gcov/llvm-cov |
| `go.mod` | Go (`go test -cover`) |
| `Cargo.toml` | Rust (`cargo-llvm-cov`) |

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

## Spock (Groovy, on Maven/Gradle)

Spock runs on the JUnit platform and reports through JaCoCo exactly like JUnit — only the
filter changes to the `*AgenticSpec` naming. Needs `spock-core` + the Groovy plugin on the
test classpath (adding them as test config is allowed if absent).

```bash
mvn test jacoco:report -Dtest='*AgenticSpec'          # Maven
./gradlew test jacocoTestReport --tests '*AgenticSpec' # Gradle
```

## Go (`go test -cover`)

`go test` compiles every `*_test.go` in the package, so filter to agent tests by their
`TestAgentic…` prefix:

```bash
go test ./... -run '^TestAgentic' -coverpkg=./... -coverprofile=coverage.out
go tool cover -func=coverage.out   # per-func/per-file %, and total on the last line
```

- Per-file goal: read the per-function rows of `go tool cover -func`; every in-scope file must meet it.
- `-coverpkg=./...` measures coverage against all main packages, not just the one under test.

## Rust (`cargo-llvm-cov`)

Agent tests are integration tests in `tests/agentic_*.rs`. Install once with
`cargo install cargo-llvm-cov` (dev tooling). Run coverage over agent tests only by naming
each integration target, and exclude unit tests in `src` with `--ignore-filename-regex`:

```bash
cargo llvm-cov --test agentic_<name> --summary-only          # one target
cargo llvm-cov --test agentic_a --test agentic_b --summary-only   # several
```

- Private functions are unreachable from integration tests by design — if their coverage
  can't be hit without editing main code, note it in the plan entry and move on.
- Add `--lcov --output-path lcov.info` (or `--json`) for machine-readable per-file numbers.

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
