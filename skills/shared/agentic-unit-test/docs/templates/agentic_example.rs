// Template: agent test for the `example` crate -> save as tests/agentic_example.rs
// Locks CURRENT behavior. Do not edit main code.
//
// IMPORTANT: agent tests are INTEGRATION tests (files under tests/). Idiomatic Rust unit
// tests live in `#[cfg(test)] mod tests` INSIDE the source file — writing those would edit
// main code (Rule 1 violation). Integration tests only see the crate's PUBLIC API; if a
// private function's coverage is unreachable this way, mark the plan entry accordingly and
// move on. Never make a private item `pub` just to test it — that edits main code.

use example::price_with_tax;

#[test]
fn agentic_applies_tax_rate_to_normal_price() {
    assert_eq!(price_with_tax(100.0, 0.2), 120.0);
}

#[test]
fn agentic_locks_current_behavior_for_zero_price() {
    // Assert whatever it ACTUALLY returns today, even if it looks odd.
    assert_eq!(price_with_tax(0.0, 0.2), 0.0);
}

// If the function returns Result instead of panicking, assert on the Err variant instead:
//   assert!(price_with_tax(-1.0, 0.2).is_err());
#[test]
#[should_panic]
fn agentic_panics_on_negative_price() {
    let _ = price_with_tax(-1.0, 0.2);
}
