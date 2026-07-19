/* Template: agent test for example.c → separate test target named example_agentic_test
 * Locks CURRENT behavior. Do not edit main code.
 * Plain assert-based; swap for the project's harness (Unity, CMocka, ...) if one exists. */
#include <assert.h>
#include <stdio.h>
#include "example.h"

static void test_applies_tax_rate_to_normal_price(void) {
    assert(price_with_tax(100, 20) == 120);
}

static void test_locks_current_behavior_for_zero_price(void) {
    /* Assert whatever it ACTUALLY returns today, even if it looks odd. */
    assert(price_with_tax(0, 20) == 0);
}

int main(void) {
    test_applies_tax_rate_to_normal_price();
    test_locks_current_behavior_for_zero_price();
    printf("example_agentic_test: all tests passed\n");
    return 0;
}
