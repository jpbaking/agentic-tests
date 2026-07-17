# Template: agent test for mypkg/example.py → save as test_agentic_example.py in the tests dir
# Locks CURRENT behavior. Do not edit main code.
import pytest

from mypkg.example import price_with_tax


def test_agentic_applies_tax_rate_to_normal_price():
    assert price_with_tax(100, 0.2) == 120


def test_agentic_locks_current_behavior_for_zero_price():
    # Assert whatever it ACTUALLY returns today, even if it looks odd.
    assert price_with_tax(0, 0.2) == 0


def test_agentic_raises_on_negative_price():
    with pytest.raises(ValueError):
        price_with_tax(-1, 0.2)
