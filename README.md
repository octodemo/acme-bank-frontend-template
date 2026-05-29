# Acme Bank frontend template

This template is the Acme Bank paved-road React frontend for IDP demos. It creates a single React 19, TypeScript, Vite, Tanstack Query, and React Router SPA that deploys as an nginx-backed Azure Container App and joins an existing Acme Bank Azure environment.

## Use the template

```bash
mkdir <your-frontend> && cd <your-frontend>
azd init -t octodemo/acme-bank-frontend-template . -e dev
azd up
```

That's it. `azd up` packages the image, provisions infra into the existing Acme Bank resource group, and deploys the new Container App. azd will prompt for an Azure subscription on first run.

## How it joins the existing Acme Bank environment

This template provisions only the new frontend Container App, its user-assigned managed identity, and an `AcrPull` role assignment. The Container Apps Environment is looked up by name (`cae-${namePrefix}-${suffix}`) using a Bicep `existing` resource, matching the convention used by [`octodemo/acme-bank`](https://github.com/octodemo/acme-bank). The shared ACR name and the BFF Container App name are likewise resolved from the same environment — so no environment variables need to be set up front.

The target resource group is set in [`azure.yaml`](./azure.yaml) (`resourceGroup: rg-acmebank`).

The container starts nginx after substituting `BFF_BASE_URL` (resolved from the BFF Container App's FQDN) into `nginx.conf`, so browser requests to `/api/*` are reverse-proxied to the existing acme-bank BFF.

### Reusing this template against a different platform

Override the demo defaults to point at a different shared environment:

- `azure.yaml` → change `resourceGroup` to your platform's resource group.
- `infra/main.bicep` → change the `containerRegistryName` parameter default.
- Pass `--parameters bffBaseUrl=https://your-bff` (or set `ACME_BFF_BASE_URL`) if the BFF doesn't follow the `ca-${env}-bff` naming convention.

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
