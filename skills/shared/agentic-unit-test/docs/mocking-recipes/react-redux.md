# Testing React + Redux

## Rule zero: NEVER mock Redux itself

Banned in agent tests (these produce tests that pass while proving nothing):

- `jest.mock('react-redux')` / mocking `useSelector` or `useDispatch`
- Mocking the store, a reducer, or a slice
- Importing the app's real store singleton (e.g. `import { store } from '../src/store'`) — shared state across tests causes flaky runs
- Snapshot-only tests of connected components

Instead: build a **small real store per test** with the app's **real reducers**, and mock only the usual boundaries (fetch, time — see `js-ts.md`).

## Decision table — pick the FIRST row that matches, top is easiest

| You are testing | How | React rendering needed? |
|---|---|---|
| Reducer / slice logic | call `reducer(state, action)` directly | no |
| Selector | call it with a hand-built state object | no |
| Thunk / async flow | real store + `store.dispatch(thunk())`, mock `fetch` | no |
| Connected component | render inside `<Provider>` with a real per-test store | yes |

Most coverage of Redux code comes from the first three rows — exhaust them before rendering anything.

## 1. Slice/reducer and selector (plain function tests — no React, no mocks)

```ts
// cartSlice.agentic.spec.ts
import reducer, { addItem, selectItemCount } from './cartSlice';

it('addItem appends the item', () => {
  const next = reducer({ items: [] }, addItem({ id: 1 }));
  expect(next.items).toEqual([{ id: 1 }]);
});

it('selectItemCount counts items', () => {
  expect(selectItemCount({ cart: { items: [{ id: 1 }, { id: 2 }] } })).toBe(2);
});
```

## 2. Thunk (real store, mock only fetch)

```ts
import { configureStore } from '@reduxjs/toolkit';
import cartReducer, { fetchItems } from './cartSlice';

it('fetchItems fills the store on success', async () => {
  jest.spyOn(globalThis, 'fetch').mockResolvedValue(
    new Response(JSON.stringify([{ id: 1 }, { id: 2 }]), { status: 200 })
  );
  const store = configureStore({ reducer: { cart: cartReducer } });

  await store.dispatch(fetchItems());

  expect(store.getState().cart.items).toHaveLength(2);   // assert STATE, not dispatch calls
  expect(store.getState().cart.status).toBe('succeeded');
});
```

## 3. Connected component (real store in a Provider)

Copy this ~8-line helper **into the test file** (do not create a shared helper file):

```tsx
// CartBadge.agentic.spec.tsx  ← note .tsx for files containing JSX
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { configureStore } from '@reduxjs/toolkit';
import { Provider } from 'react-redux';
import cartReducer from './cartSlice';   // the REAL reducer — never a mock
import CartBadge from './CartBadge';

function renderWithStore(ui: React.ReactElement, preloadedState?: object) {
  const store = configureStore({ reducer: { cart: cartReducer }, preloadedState });
  return { store, ...render(<Provider store={store}>{ui}</Provider>) };
}

it('shows the item count from the store', () => {
  renderWithStore(<CartBadge />, { cart: { items: [{ id: 1 }, { id: 2 }] } });
  expect(screen.getByText('2')).toBeInTheDocument();
});

it('clicking Add goes through the real reducer', async () => {
  const { store } = renderWithStore(<CartBadge />, { cart: { items: [] } });
  await userEvent.click(screen.getByRole('button', { name: /add/i }));
  expect(store.getState().cart.items).toHaveLength(1);
});
```

- `preloadedState` puts the store in exactly the state the branch under test needs — no dispatch choreography.
- Include in `reducer: {...}` only the slices the component reads, under their real keys.
- Assert on rendered output (`screen.*`) or resulting state (`store.getState()`) — never on "dispatch was called with action X".

## 4. Variants

- **Legacy Redux (no RTK)**: same patterns; build the per-test store with the project's real root reducer (`configureStore({ reducer: rootReducer, preloadedState })` works for plain reducers too). Adding `@reduxjs/toolkit` as a dev dependency just for tests is allowed test config.
- **RTK Query**: build the per-test store with the real api slice — `reducer: { [api.reducerPath]: api.reducer, ... }` and `middleware: (gDM) => gDM().concat(api.middleware)` — then mock `fetch` as in recipe 2. Do not mock the generated hooks.
- **Component only reads props, Redux is in the parent?** It's not connected — test it without any store.

## Setup (allowed test config)

- Dev deps if missing (ask before installing): `@testing-library/react`, `@testing-library/user-event`, `@testing-library/jest-dom`, `jest-environment-jsdom`.
- Component test files need jsdom: `testEnvironment: 'jsdom'` in jest config, or `/** @jest-environment jsdom */` at the top of the test file (Vitest: `environment: 'jsdom'`, or `// @vitest-environment jsdom`).
- JSX test files are named `*.agentic.spec.tsx` / `*.agentic.spec.jsx` — the coverage recipe's glob already matches them.
