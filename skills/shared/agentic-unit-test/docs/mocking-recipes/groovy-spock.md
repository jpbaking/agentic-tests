# Mocking — Groovy (Spock's built-in Mock / Stub / Spy)

Spock has mocking built in — no Mockito needed. `Stub()` returns canned values, `Mock()` also
verifies interactions, `Spy()` wraps a real object. Interaction expectations live in the
`then:` block. Same golden rule as everywhere: **mock only boundaries, never the unit under test.**

## Dependency / collaborator

```groovy
class OrderServiceAgenticSpec extends Specification {

    PaymentGateway gateway = Mock()
    OrderService service = new OrderService(gateway)   // real class, mocked dep

    def "charges exactly once"() {
        when:
        service.checkout(cart())

        then:
        1 * gateway.charge(_) >> Receipt.ok()   // expect one call; stub its return
    }
}
```

Use `Stub()` when you only need canned return values and don't care how often it's called.

## Time

If the class takes a `java.time.Clock`, pass `Clock.fixed(Instant.parse("2026-01-15T10:00:00Z"), ZoneOffset.UTC)`.
For direct `Instant.now()` calls with no seam, use Spock + `mockito-inline`'s `mockStatic`, or mark FAILED.

## Randomness

Inject a seeded `new Random(42)` if the constructor allows; otherwise mark FAILED rather than editing source.

## Filesystem

```groovy
@TempDir Path tmp   // Spock provides a fresh directory per feature method
```

## Network / HTTP

Mock the client interface the class uses (`HttpClient client = Mock()`). For classes hardwired
to real HTTP, use WireMock (test-scope dep) with a configurable base URL; if the URL isn't
configurable, mark FAILED rather than editing main code.

## Environment variables

Do not mutate real env. If the class reads `System.getenv` directly with no override, mark FAILED
with reason "reads System.getenv directly".
