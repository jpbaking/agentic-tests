// Template: agent test for src/example.js → save next to it as example.agentic.spec.js
// Locks CURRENT behavior. Do not edit main code.
const { priceWithTax } = require('./example');

describe('priceWithTax (agentic)', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('applies the tax rate to a normal price', () => {
    expect(priceWithTax(100, 0.2)).toBe(120);
  });

  it('locks current behavior for the zero-price edge case', () => {
    // Assert whatever it ACTUALLY returns today, even if it looks odd.
    expect(priceWithTax(0, 0.2)).toBe(0);
  });
});
