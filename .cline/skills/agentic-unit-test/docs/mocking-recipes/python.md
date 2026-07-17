# Mocking — Python (pytest + unittest.mock)

Golden rule: **patch where it is looked up, not where it is defined** — `patch("mypkg.orders.requests.get")`, not `patch("requests.get")`.

## Dependency / function

```python
from unittest.mock import patch, MagicMock

def test_agentic_checkout_charges_once():
    with patch("mypkg.orders.gateway") as gw:
        gw.charge.return_value = {"ok": True}
        checkout(cart())
        gw.charge.assert_called_once()
```

Or the pytest-native way:

```python
def test_agentic_lookup(monkeypatch):
    monkeypatch.setattr("mypkg.orders.lookup_rate", lambda cur: 1.25)
```

## Time

```python
with patch("mypkg.orders.datetime") as dt:
    dt.now.return_value = datetime(2026, 1, 15, 10, 0, 0)
```

(`freezegun`'s `@freeze_time("2026-01-15")` is cleaner if it's already a dev dependency; installing it as a test dep is allowed.)

## Randomness

```python
monkeypatch.setattr("mypkg.orders.random.random", lambda: 0.42)
# or seed: random.seed(42) at test start if the code uses the global RNG
```

## Network / HTTP

```python
with patch("mypkg.orders.requests.get") as get:
    get.return_value.status_code = 200
    get.return_value.json.return_value = {"ok": 1}
```

## Filesystem

```python
def test_agentic_writes_report(tmp_path):   # pytest built-in fixture
    out = tmp_path / "report.txt"
    write_report(out)
    assert out.read_text() == "expected"
```

## Environment variables

```python
monkeypatch.setenv("API_KEY", "test")
monkeypatch.delenv("DEBUG", raising=False)
```
