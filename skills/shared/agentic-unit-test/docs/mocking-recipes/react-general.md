# Testing React — Router, Context, hooks, async rendering

Same disease, same cure as `react-redux.md`: **never mock the framework — host the component in a tiny real environment.**

## Banned in agent tests

- `jest.mock('react-router-dom')` / mocking `useNavigate`, `useParams`, `useLocation`
- Mocking `useContext` or a context's hook (e.g. `jest.mock('../src/ThemeContext')`)
- Shallow rendering / Enzyme-style testing of internal state or instance methods
- Asserting on implementation details (state variables, handler names) instead of rendered output
- Mocking child components — EXCEPT a heavy third-party boundary widget (map, chart, video player); mocking your own components hides the behavior you're locking

## Decision table

| Component uses | Host it in |
|---|---|
| `useParams` / `useLocation` / `<Link>` | `<MemoryRouter initialEntries={[...]}>` + `<Routes>` |
| `useNavigate` | same, plus a probe route to assert where it went |
| a Context (`useTheme()`, `useAuth()`, ...) | the REAL `<XProvider>` with test values |
| a custom hook you want to test alone | `renderHook` from `@testing-library/react` |
| several of the above | one inline `renderWithProviders` stacking the real wrappers |

## 1. React Router — route params

```tsx
// UserPage.agentic.spec.tsx
import { render, screen } from '@testing-library/react';
import { MemoryRouter, Routes, Route } from 'react-router-dom';
import UserPage from './UserPage';

it('renders the user id from the URL', () => {
  render(
    <MemoryRouter initialEntries={['/users/42']}>
      <Routes><Route path="/users/:id" element={<UserPage />} /></Routes>
    </MemoryRouter>
  );
  expect(screen.getByRole('heading', { name: /user 42/i })).toBeInTheDocument();
});
```

## 2. React Router — navigation (do NOT mock useNavigate)

Add a probe route and assert the app really navigated:

```tsx
it('navigates to the detail page on click', async () => {
  render(
    <MemoryRouter initialEntries={['/list']}>
      <Routes>
        <Route path="/list" element={<ItemList />} />
        <Route path="/items/:id" element={<div>probe: detail page</div>} />
      </Routes>
    </MemoryRouter>
  );
  await userEvent.click(screen.getByRole('link', { name: /first item/i }));
  expect(screen.getByText('probe: detail page')).toBeInTheDocument();
});
```

Data routers (v6.4+ `createBrowserRouter`): use `createMemoryRouter(routes, { initialEntries })` + `<RouterProvider router={router} />`; assert via `router.state.location.pathname`.

## 3. Context — wrap in the real provider

```tsx
import { ThemeProvider } from './ThemeContext';   // the REAL provider — never a mock

it('renders dark styles when the theme context says dark', () => {
  render(<ThemeProvider initialTheme="dark"><Toolbar /></ThemeProvider>);
  expect(screen.getByRole('toolbar')).toHaveClass('toolbar--dark');
});
```

- Provider has no way to inject test values (no props/args)? Drive it through its public API (render a button that flips the theme, click it) — do NOT edit the provider (main code).
- Provider fetches on mount? Keep the real provider, mock `fetch` (see `js-ts.md`).

## 4. Custom hooks alone

```tsx
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

it('increments', () => {
  const { result } = renderHook(() => useCounter(5));
  act(() => result.current.increment());
  expect(result.current.count).toBe(6);
});
```

Hook needs a store/router/context? Pass the real wrappers: `renderHook(() => useCart(), { wrapper })` where `wrapper` stacks the real providers.

## 5. Stacking wrappers (Redux + Router + Context)

Copy inline into the test file (do not create shared helper files):

```tsx
function renderWithProviders(ui: React.ReactElement, { route = '/', preloadedState = {} } = {}) {
  const store = configureStore({ reducer: { example: exampleReducer }, preloadedState });
  return {
    store,
    ...render(
      <Provider store={store}>
        <ThemeProvider>
          <MemoryRouter initialEntries={[route]}>{ui}</MemoryRouter>
        </ThemeProvider>
      </Provider>
    ),
  };
}
```

## 6. Async rendering — the #1 source of flaky React tests

- Anything after a fetch/effect/state update: `await screen.findByText(...)` (find*, not get*) or `await waitFor(() => expect(...))`. Never assert immediately after triggering async work.
- Interactions: always `await userEvent.click(...)` (userEvent wraps `act` for you). Do not use `fireEvent` unless the project already does.
- An "not wrapped in act(...)" warning = a real bug in the TEST (unawaited update). Fix it with `findBy`/`waitFor`; never silence the warning.
- Component uses timers? `jest.useFakeTimers()` + `jest.advanceTimersByTime(...)`, and `jest.useRealTimers()` in `afterEach` (see `js-ts.md`).
- Never use arbitrary sleeps (`setTimeout` waits) in tests — that is what the 3-run flakiness gate exists to catch.

## Setup

Same allowed test deps as `react-redux.md` (`@testing-library/react`, `@testing-library/user-event`, `@testing-library/jest-dom`, jsdom environment), plus nothing extra — `MemoryRouter`, `renderHook`, and real providers all come from packages the app already uses.
