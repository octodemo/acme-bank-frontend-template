export function AboutPage() {
  return (
    <section className="card" aria-labelledby="about-title">
      <p className="eyebrow">acme-bank-frontend-template@0.0.1</p>
      <h1 id="about-title">About this template</h1>
      <p>This repository is a golden-path React 19 frontend for Acme Bank demos. It gives teams a small, deployable starting point that uses TypeScript, Vite, Tanstack Query, React Router, Container Apps, CodeQL, dependency review, SBOM generation, and OIDC-based Azure deployment.</p>
      <p>Rename the literal <code>acme-frontend</code> placeholders after initialization, then point the container at an existing Acme Bank BFF with <code>BFF_BASE_URL</code>.</p>
    </section>
  );
}
