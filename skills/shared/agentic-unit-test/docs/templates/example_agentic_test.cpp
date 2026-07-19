// Template: agent test for example.cpp → separate CMake target named example_agentic_test
// Locks CURRENT behavior. Do not edit main code.
#include <gtest/gtest.h>
#include "example.h"

TEST(ExampleAgenticTest, AppliesTaxRateToNormalPrice) {
    EXPECT_DOUBLE_EQ(priceWithTax(100.0, 0.2), 120.0);
}

TEST(ExampleAgenticTest, LocksCurrentBehaviorForZeroPrice) {
    // Assert whatever it ACTUALLY returns today, even if it looks odd.
    EXPECT_DOUBLE_EQ(priceWithTax(0.0, 0.2), 0.0);
}

TEST(ExampleAgenticTest, RejectsNegativePrice) {
    EXPECT_THROW(priceWithTax(-1.0, 0.2), std::invalid_argument);
}
