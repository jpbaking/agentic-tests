// Template: agent test for Example.java → same package under src/test/java, named ExampleAgenticTest.java
// Locks CURRENT behavior. Do not edit main code.
package com.example;

import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;

class ExampleAgenticTest {

    @Test
    void appliesTaxRateToNormalPrice() {
        assertEquals(120.0, Example.priceWithTax(100.0, 0.2), 1e-9);
    }

    @Test
    void locksCurrentBehaviorForZeroPrice() {
        // Assert whatever it ACTUALLY returns today, even if it looks odd.
        assertEquals(0.0, Example.priceWithTax(0.0, 0.2), 1e-9);
    }

    @Test
    void throwsOnNegativePrice() {
        assertThrows(IllegalArgumentException.class,
                () -> Example.priceWithTax(-1.0, 0.2));
    }
}
