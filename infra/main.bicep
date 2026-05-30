@description('Azure region for the frontend Container App. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Acme Bank azd environment name. Must match the existing environment you are joining (for example, dev).')
@minLength(1)
@maxLength(32)
param environmentName string

@description('Frontend service name. Used for the Container App name, managed identity name, and image name. Rename from acme-frontend when adopting the template.')
@minLength(2)
@maxLength(32)
param serviceName string = 'acme-frontend'

@description('Full container image reference including tag or digest. Set automatically by azd during the package phase as SERVICE_<NAME>_IMAGE_NAME. The default placeholder lets the first `azd up` provision succeed before the real image is built.')
param imageName string = 'mcr.microsoft.com/k8se/quickstart:latest'

@description('Name of the shared Azure Container Registry. Defaulted to the demo registry; override when reusing the template against a different platform.')
param containerRegistryName string = 'acmebanke40394e9'

@description('External base URL of the existing Acme Bank BFF. Defaults to the BFF Container App in the same environment; override to point at a different backend.')
param bffBaseUrl string = ''

// Shared resource names follow the convention used by the Acme Bank platform
// repo so this template can locate them with `existing` lookups.
var namePrefix = take(replace(toLower(environmentName), '-', ''), 12)
var suffix = uniqueString(resourceGroup().id, environmentName)
var containerAppsEnvironmentName = 'cae-${namePrefix}-${suffix}'
var containerAppName = 'ca-${environmentName}-${serviceName}'
var managedIdentityName = 'id-${environmentName}-${serviceName}'
var bffContainerAppName = 'ca-${environmentName}-bff'

resource bffContainerApp 'Microsoft.App/containerApps@2024-03-01' existing = {
  name: bffContainerAppName
}

var resolvedBffBaseUrl = empty(bffBaseUrl) ? 'https://${bffContainerApp.properties.configuration.ingress.fqdn}' : bffBaseUrl

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: containerAppsEnvironmentName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: containerRegistryName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
}

var acrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

resource acrPullAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, managedIdentity.id, 'acr-pull')
  scope: containerRegistry
  properties: {
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: acrPullRoleDefinitionId
  }
}

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerAppName
  location: location
  tags: {
    'azd-service-name': 'web'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      activeRevisionsMode: 'Single'
      registries: [
        {
          server: containerRegistry.properties.loginServer
          identity: managedIdentity.id
        }
      ]
      ingress: {
        external: true
        targetPort: 8080
        transport: 'auto'
        allowInsecure: false
      }
    }
    template: {
      containers: [
        {
          name: serviceName
          image: imageName
          env: [
            {
              name: 'BFF_BASE_URL'
              value: resolvedBffBaseUrl
            }
          ]
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 3
      }
    }
  }
  dependsOn: [
    acrPullAssignment
  ]
}

output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.properties.loginServer
output webUrl string = 'https://${containerApp.properties.configuration.ingress.fqdn}'
output webFqdn string = containerApp.properties.configuration.ingress.fqdn
