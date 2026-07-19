// Template: agent test for a Redux slice (src/store/exampleSlice.ts)
// → save next to it as exampleSlice.agentic.spec.ts
// Reducers, selectors, thunks are plain functions — no React, no react-redux, no store mocks.
import { configureStore } from '@reduxjs/toolkit';
import reducer, { addItem, selectItemCount, fetchItems } from './exampleSlice';

afterEach(() => jest.restoreAllMocks());

describe('exampleSlice (agentic)', () => {
  it('addItem appends the item (reducer as plain function)', () => {
    const next = reducer({ items: [], status: 'idle' }, addItem({ id: 1 }));
    expect(next.items).toEqual([{ id: 1 }]);
  });

  it('selectItemCount counts items (selector as plain function)', () => {
    const state = { example: { items: [{ id: 1 }, { id: 2 }], status: 'idle' } };
    expect(selectItemCount(state)).toBe(2);
  });

  it('fetchItems fills the store on success (thunk: real store, mock only fetch)', async () => {
    jest.spyOn(globalThis, 'fetch').mockResolvedValue(
      new Response(JSON.stringify([{ id: 1 }]), { status: 200 })
    );
    const store = configureStore({ reducer: { example: reducer } });

    await store.dispatch(fetchItems());

    // Assert resulting STATE — never "dispatch was called with action X".
    expect(store.getState().example.items).toHaveLength(1);
    expect(store.getState().example.status).toBe('succeeded');
  });
});
