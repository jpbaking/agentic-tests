// Template: agent test for src/example.ts → save next to it as example.agentic.spec.ts
// Locks CURRENT behavior. Do not edit main code.
import { priceWithTax } from './example';

describe('priceWithTax (agentic)', () => {
  afterEach(() => {
    jest.restoreAllMocks();
    jest.useRealTimers();
  });

  it('applies the tax rate to a normal price', () => {
    expect(priceWithTax(100, 0.2)).toBe(120);
  });

  it('locks current behavior for the zero-price edge case', () => {
    // Assert whatever it ACTUALLY returns today, even if it looks odd.
    expect(priceWithTax(0, 0.2)).toBe(0);
  });

  it('throws on negative price (branch coverage)', () => {
    expect(() => priceWithTax(-1, 0.2)).toThrow(RangeError);
  });
});
