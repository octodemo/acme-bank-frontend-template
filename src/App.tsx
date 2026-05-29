import { NavLink, Route, Routes } from 'react-router-dom';
import { AboutPage } from './pages/AboutPage';
import { HomePage } from './pages/HomePage';
import './App.css';

export default function App() {
  return (
    <div className="app-shell">
      <header className="app-header">
        <a className="brand" href="/" aria-label="Acme Frontend home">
          Acme Frontend
        </a>
        <nav className="app-nav" aria-label="Primary navigation">
          <NavLink to="/" end>
            Home
          </NavLink>
          <NavLink to="/about">About</NavLink>
        </nav>
      </header>
      <main className="app-main">
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/about" element={<AboutPage />} />
        </Routes>
      </main>
    </div>
  );
}
