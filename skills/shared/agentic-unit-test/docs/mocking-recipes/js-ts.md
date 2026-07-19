# Mocking — JavaScript / TypeScript

Jest shown; Vitest is identical with `vi.` instead of `jest.` (e.g. `vi.mock`, `vi.useFakeTimers`).

Always restore in teardown:

```ts
afterEach(() => { jest.restoreAllMocks(); jest.useRealTimers(); });
```

## Time

```ts
jest.useFakeTimers().setSystemTime(new Date('2026-01-15T10:00:00Z'));
jest.advanceTimersByTime(1000);              // fire pending timeouts/intervals
```

## Randomness

```ts
jest.spyOn(Math, 'random').mockReturnValue(0.42);
```

## Network / HTTP

```ts
jest.spyOn(globalThis, 'fetch').mockResolvedValue(
  new Response(JSON.stringify({ ok: 1 }), { status: 200 })
);
// axios: jest.mock('axios') then (axios.get as jest.Mock).mockResolvedValue({ data: ... })
```

## Module / dependency

```ts
jest.mock('../src/mailer');                   // path as imported by the code under test
import { send } from '../src/mailer';
(send as jest.Mock).mockResolvedValue(true);
```

## Filesystem

```ts
jest.mock('fs');                              // or 'node:fs/promises'
import * as fs from 'fs';
(fs.readFileSync as jest.Mock).mockReturnValue('file-content');
```

## Environment variables

```ts
const OLD = process.env;
beforeEach(() => { process.env = { ...OLD, API_KEY: 'test' }; });
afterEach(() => { process.env = OLD; });
```
