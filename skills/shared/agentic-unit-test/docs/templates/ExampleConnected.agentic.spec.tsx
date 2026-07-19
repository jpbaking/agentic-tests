/** @jest-environment jsdom */
// Template: agent test for a Redux-connected React component (src/ExampleConnected.tsx)
// → save next to it as ExampleConnected.agentic.spec.tsx (.tsx because it contains JSX)
// NEVER: jest.mock('react-redux'), mocking useSelector/useDispatch, importing the app's store singleton.
// ALWAYS: a small real store per test, real reducers, assert on screen output or store state.
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { configureStore } from '@reduxjs/toolkit';
import { Provider } from 'react-redux';
import exampleReducer from './store/exampleSlice'; // the REAL reducer — never a mock
import ExampleConnected from './ExampleConnected';

// Keep this helper inside the test file — do not create shared helper files.
function renderWithStore(ui: React.ReactElement, preloadedState?: object) {
  const store = configureStore({
    reducer: { example: exampleReducer }, // only the slices this component reads, real keys
    preloadedState,
  });
  return { store, ...render(<Provider store={store}>{ui}</Provider>) };
}

describe('ExampleConnected (agentic)', () => {
  it('renders the count from the store (useSelector path)', () => {
    renderWithStore(<ExampleConnected />, {
      example: { items: [{ id: 1 }, { id: 2 }], status: 'idle' },
    });
    expect(screen.getByText('2')).toBeInTheDocument();
  });

  it('clicking Add updates state through the real reducer (useDispatch path)', async () => {
    const { store } = renderWithStore(<ExampleConnected />, {
      example: { items: [], status: 'idle' },
    });
    await userEvent.click(screen.getByRole('button', { name: /add/i }));
    expect(store.getState().example.items).toHaveLength(1);
  });

  it('locks the empty-state branch as-is', () => {
    renderWithStore(<ExampleConnected />, { example: { items: [], status: 'idle' } });
    // Assert whatever it ACTUALLY renders today, even if it looks odd.
    expect(screen.getByText(/no items/i)).toBeInTheDocument();
  });
});
