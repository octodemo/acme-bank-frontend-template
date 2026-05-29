# Copilot instructions for Acme frontend services

This repository is a React 19 and TypeScript frontend that joins an existing Acme Bank Azure environment. Keep samples synthetic and never add real banking data, secrets, credentials, or PII.

## Frontend rules

- Use function components and React hooks.
- Keep TypeScript strict and avoid `any`.
- Use Tanstack Query for server data fetching; do not call `fetch` directly from components.
- Put reusable API helpers under `src/api/`.
- Use React Router for page-level routing.
- Prefer semantic HTML and accessible labels, headings, and navigation.
- Keep local component state local; do not add Redux or Zustand unless explicitly requested.

## Delivery rules

- Services consume shared Acme Bank Azure resources instead of creating a new platform environment.
- Do not inline secrets in source, workflow YAML, Dockerfiles, or Bicep.
- Pin GitHub Actions by full commit SHA with a readable version comment.
- Use OIDC for Azure authentication.
- Keep Docker images reproducible with pinned base-image digests.
