// Template: agent test for example.go (package example) -> save as example_agentic_test.go beside it.
// Locks CURRENT behavior. Do not edit main code.
// Agent test funcs are ALL named TestAgentic* so `go test -run '^TestAgentic'` runs ours only.
package example

import "testing"

// Table-driven is the idiomatic Go shape. Assume: PriceWithTax(price, rate float64) (float64, error)
func TestAgenticPriceWithTax(t *testing.T) {
	tests := []struct {
		name    string
		price   float64
		rate    float64
		want    float64
		wantErr bool
	}{
		{"normal price", 100, 0.2, 120, false},
		{"zero price locks current behavior", 0, 0.2, 0, false}, // assert what it ACTUALLY returns today
		{"negative price errors", -1, 0.2, 0, true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := PriceWithTax(tt.price, tt.rate)
			if (err != nil) != tt.wantErr {
				t.Fatalf("PriceWithTax(%v, %v) err = %v, wantErr %v", tt.price, tt.rate, err, tt.wantErr)
			}
			if !tt.wantErr && got != tt.want {
				t.Fatalf("PriceWithTax(%v, %v) = %v, want %v", tt.price, tt.rate, got, tt.want)
			}
		})
	}
}
