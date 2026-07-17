# Mocking — Go (interfaces + standard-library test helpers)

Golden rule: **mock at an interface the code already accepts.** Go has no monkey-patching;
if a function reaches for a concrete dependency with no seam, you cannot isolate it without
editing main code — mark the plan entry FAILED ("no interface seam") rather than editing source.

## Dependency / collaborator

Define a tiny fake that satisfies the interface the code under test depends on:

```go
type fakeGateway struct{ charged int }

func (f *fakeGateway) Charge(amount int) (Receipt, error) {
	f.charged++
	return Receipt{OK: true}, nil
}

func TestAgenticCheckoutChargesOnce(t *testing.T) {
	gw := &fakeGateway{}
	Checkout(Cart{Total: 100}, gw)
	if gw.charged != 1 {
		t.Fatalf("charged %d times, want 1", gw.charged)
	}
}
```

(`gomock` or `testify/mock` are fine if already a dev dependency; hand-written fakes need none.)

## Time

Only isolatable if the code takes a clock. If it accepts a `func() time.Time` or a `Clock`
interface, pass a fixed one: `func() time.Time { return time.Date(2026,1,15,10,0,0,0,time.UTC) }`.
If it calls `time.Now()` directly with no seam, mark FAILED.

## Randomness

If the code accepts a `*rand.Rand`, pass `rand.New(rand.NewSource(42))` for deterministic output.

## Network / HTTP

Use the stdlib `httptest.Server` and point the code's base URL at it (only if the URL is configurable):

```go
srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(200)
	_, _ = w.Write([]byte(`{"ok":1}`))
}))
defer srv.Close()
client := NewClient(srv.URL)
```

## Filesystem

```go
dir := t.TempDir() // auto-removed after the test
path := filepath.Join(dir, "report.txt")
```

## Environment variables

```go
t.Setenv("API_KEY", "test") // auto-restored after the test; also forces the test to run non-parallel
```
