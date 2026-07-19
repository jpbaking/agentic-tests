// Template: agent spec for Example.java/Example.groovy -> src/test/groovy, same package, named ExampleAgenticSpec.groovy
// Locks CURRENT behavior. Do not edit main code.
package com.example

import spock.lang.Specification

class ExampleAgenticSpec extends Specification {

    def "applies tax rate to normal price"() {
        expect:
        Example.priceWithTax(100.0, 0.2) == 120.0
    }

    def "locks current behavior for zero price"() {
        // Assert whatever it ACTUALLY returns today, even if it looks odd.
        expect:
        Example.priceWithTax(0.0, 0.2) == 0.0
    }

    def "throws on negative price"() {
        when:
        Example.priceWithTax(-1.0, 0.2)

        then:
        thrown(IllegalArgumentException)
    }

    // Spock's data-driven `where:` block locks a whole table of cases in one spec.
    def "applies tax across a table of prices"() {
        expect:
        Example.priceWithTax(price, rate) == expected

        where:
        price | rate || expected
        100.0 | 0.2  || 120.0
        50.0  | 0.1  || 55.0
        0.0   | 0.2  || 0.0
    }
}
