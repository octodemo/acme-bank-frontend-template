# Acme Bank frontend template

This template is the Acme Bank paved-road React frontend for IDP demos. It creates a single React 19, TypeScript, Vite, Tanstack Query, and React Router SPA that deploys as an nginx-backed Azure Container App and joins an existing Acme Bank Azure environment.

## Use the template

```bash
azd init -t octodemo/acme-bank-frontend-template
```

## Joining the existing Acme Bank environment

This template provisions only the new frontend Container App, its user-assigned managed identity, and an `AcrPull` role assignment. The Container Apps Environment is looked up by name (`cae-${namePrefix}-${suffix}`) using a Bicep `existing` resource, matching the convention used by [`octodemo/acme-bank`](https://github.com/octodemo/acme-bank).

### One-time bootstrap

```bash
azd env new <existing-acme-env-name>
azd env get-values --cwd ../acme-bank | grep ^ACME_ >> .azure/<existing-acme-env-name>/.env
```

That populates `ACME_CONTAINER_REGISTRY_NAME` and `ACME_BFF_BASE_URL`. `AZURE_LOCATION`, `AZURE_ENV_NAME`, and `SERVICE_WEB_IMAGE_NAME` are set by azd itself.

Then deploy:

```bash
azd up
```

The container starts nginx after substituting `BFF_BASE_URL` (sourced from `ACME_BFF_BASE_URL`) into `nginx.conf`, so browser requests to `/api/*` are reverse-proxied to the existing acme-bank BFF.

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
