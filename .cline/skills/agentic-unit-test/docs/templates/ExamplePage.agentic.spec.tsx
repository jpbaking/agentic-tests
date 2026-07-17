/** @jest-environment jsdom */
// Template: agent test for a page component using Router + Context (+ optionally Redux)
// → save next to it as ExamplePage.agentic.spec.tsx
// NEVER mock react-router-dom, useNavigate/useParams, useContext, or your own child components.
// Host the component in small REAL wrappers instead.
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { MemoryRouter, Routes, Route } from 'react-router-dom';
import { ThemeProvider } from './ThemeContext'; // the REAL provider — never a mock
import ExamplePage from './ExamplePage';

// Keep this helper inside the test file — do not create shared helper files.
function renderPage(route: string) {
  return render(
    <ThemeProvider>
      <MemoryRouter initialEntries={[route]}>
        <Routes>
          <Route path="/examples/:id" element={<ExamplePage />} />
          <Route path="/done" element={<div>probe: done page</div>} />
        </Routes>
      </MemoryRouter>
    </ThemeProvider>
  );
}

describe('ExamplePage (agentic)', () => {
  it('renders the id from the URL (useParams path)', () => {
    renderPage('/examples/42');
    expect(screen.getByRole('heading', { name: /example 42/i })).toBeInTheDocument();
  });

  it('navigates to /done on submit (useNavigate path — assert the probe, never mock)', async () => {
    renderPage('/examples/42');
    await userEvent.click(screen.getByRole('button', { name: /submit/i }));
    expect(screen.getByText('probe: done page')).toBeInTheDocument();
  });

  it('shows fetched data (async path — findBy, never assert immediately)', async () => {
    jest.spyOn(globalThis, 'fetch').mockResolvedValue(
      new Response(JSON.stringify({ name: 'Widget' }), { status: 200 })
    );
    renderPage('/examples/42');
    expect(await screen.findByText(/widget/i)).toBeInTheDocument();
    jest.restoreAllMocks();
  });
});
