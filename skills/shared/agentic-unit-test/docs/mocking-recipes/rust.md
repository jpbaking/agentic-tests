# Mocking — Rust (traits + integration tests)

Two hard constraints come first, because they shape everything:

1. **Agent tests are integration tests** (`tests/agentic_*.rs`). Unit tests inside
   `#[cfg(test)] mod` would edit main code. So you can only exercise the crate's **public API**.
2. **Never make an item `pub` to reach it.** That edits main code — a Rule 1 violation.
   If a private path can't be driven through the public API, mark the plan entry FAILED.

Golden rule: **mock at a trait the public API already accepts.** No trait seam → not isolatable.

## Dependency / collaborator

Implement the trait the code depends on with a hand-written fake:

```rust
use std::cell::Cell;

struct FakeGateway { charged: Cell<u32> }

impl Gateway for FakeGateway {
    fn charge(&self, _amount: u64) -> Result<Receipt, Error> {
        self.charged.set(self.charged.get() + 1);
        Ok(Receipt::ok())
    }
}

#[test]
fn agentic_checkout_charges_once() {
    let gw = FakeGateway { charged: Cell::new(0) };
    checkout(Cart { total: 100 }, &gw);
    assert_eq!(gw.charged.get(), 1);
}
```

(`mockall` is fine if the trait is public and it's already a dev dependency; hand-written fakes need nothing.)

## Time

Isolatable only if a clock is injected (e.g. the API takes `impl Fn() -> DateTime<Utc>` or a
`Clock` trait). Pass a fixed value. Code calling `Instant::now()` directly with no seam → FAILED.

## Randomness

If the API accepts an `impl Rng`, pass a seeded `rand::rngs::StdRng::seed_from_u64(42)`.

## Network / HTTP

Use a mock HTTP server dev-dependency such as `mockito` or `wiremock`, and point the code's
configurable base URL at it. Not configurable → FAILED.

## Filesystem

Use the `tempfile` dev-dependency: `let dir = tempfile::tempdir().unwrap();` — removed on drop.

## Environment variables

`std::env::set_var` is process-global and racy across parallel tests. Prefer passing config
explicitly through the public API. If you must touch env, keep it in one test and guard ordering
with the `serial_test` dev-dependency (`#[serial]`).
