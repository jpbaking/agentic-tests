# Mocking — Java (JUnit 5 + Mockito)

If Mockito is missing, adding `mockito-core` (and `mockito-junit-jupiter`) as **test-scope** dependencies is allowed test config.

## Dependency injection (the standard pattern)

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceAgenticTest {
    @Mock PaymentGateway gateway;
    @InjectMocks OrderService service;    // real class under test, mocked deps

    @Test void chargesOnce() {
        when(gateway.charge(any())).thenReturn(Receipt.ok());
        service.checkout(cart());
        verify(gateway, times(1)).charge(any());
    }
}
```

## Time

If the class takes a `java.time.Clock`, pass `Clock.fixed(Instant.parse("2026-01-15T10:00:00Z"), ZoneOffset.UTC)`.
If it calls `Instant.now()` directly, use static mocking (needs `mockito-inline` on the test classpath):

```java
try (MockedStatic<Instant> t = mockStatic(Instant.class)) {
    t.when(Instant::now).thenReturn(Instant.parse("2026-01-15T10:00:00Z"));
    // ... call code under test inside this block
}
```

## Randomness

Inject a seeded `new Random(42)` if the constructor allows; otherwise `mockStatic` as above.

## Filesystem

```java
@TempDir Path tmp;   // JUnit 5 gives a fresh directory per test
```

## Network / HTTP

Mock the client interface the class uses (preferred). For classes hardwired to real HTTP, use WireMock (test-scope dep) and point the base URL at `wireMockServer.baseUrl()` — only possible if the URL is configurable; if not, mark the entry FAILED rather than editing main code.

## Environment variables

Do not mutate real env. If the class reads `System.getenv` directly and offers no override, mark FAILED with reason "reads System.getenv directly".
