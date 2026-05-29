# Acme Bank frontend template

This template is the Acme Bank paved-road React frontend for IDP demos. It creates a single React 19, TypeScript, Vite, Tanstack Query, and React Router SPA that deploys as an nginx-backed Azure Container App and joins an existing Acme Bank Azure environment.

## Use the template

```bash
azd init -t octodemo/acme-bank-frontend-template
```

After initialization, rename the literal `acme-frontend` placeholder, set the shared environment values, configure the pipeline, and push your repository:

```bash
azd env set BFF_BASE_URL https://<your-bff-fqdn>
azd pipeline config
git push
```

## Shared-environment model

This template provisions only the new frontend Container App and role assignments. The shared Acme Bank environment must already provide these `azd` or GitHub Actions variables:

- `AZURE_LOCATION` — Azure region for the Container App.
- `AZURE_ENV_NAME` — environment name used in resource naming.
- `SHARED_MANAGED_IDENTITY_ID` — user-assigned managed identity resource ID used by Container Apps.
- `SHARED_CONTAINER_APPS_ENV_ID` — existing Container Apps managed environment resource ID.
- `SHARED_ACR_LOGIN_SERVER` — existing Azure Container Registry login server.
- `BFF_BASE_URL` — external base URL of the existing Acme Bank BFF, without a trailing `/api`.
- `SERVICE_WEB_IMAGE_NAME` — full image reference produced by the image build workflow.

The container starts nginx after substituting `BFF_BASE_URL` into `nginx.conf`. When `BFF_BASE_URL` points at the existing BFF, browser requests to `/api/*` are reverse-proxied to that BFF. For a frontend that does not call a BFF yet, leave the sample query in place as a friendly placeholder until you add a real API integration.

## Rename `acme-frontend`

The starter intentionally uses `acme-frontend` everywhere so Copilot or a developer can rename it after `azd init`. Replace it with your service name in:

- `package.json`
- `azure.yaml`
- `infra/main.bicep` default `serviceName`
- `.github/workflows/build-image.yml` `IMAGE_NAME`

## Local development

```bash
npm install
npm run dev
```

Vite proxies `/api` to `http://localhost:5080`, which matches the local Acme Bank BFF default. Start the BFF locally before exercising API-backed features, or expect the sample endpoint to show the friendly no-backend placeholder.

## Bundled guardrails

- PR validation with `npm ci`, ESLint, TypeScript, and Vitest.
- CodeQL analysis for JavaScript and TypeScript.
- Dependency review with license guardrails.
- Docker image build with SBOM generation using `microsoft/sbom-tool`.
- Build provenance and SBOM attestations on `main`.
- OIDC-based Azure login for image push and `azd provision`.
