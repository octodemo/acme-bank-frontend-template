@description('Azure region for the frontend Container App.')
param location string

@description('Azd environment name used to create stable resource names.')
@minLength(1)
@maxLength(32)
param environmentName string

@description('Frontend service name. Rename this from acme-frontend when creating a real service from the template.')
@minLength(2)
@maxLength(32)
param serviceName string = 'acme-frontend'

@description('Fully qualified container image name to run, typically supplied by azd as SERVICE_WEB_IMAGE_NAME.')
param imageName string

@description('Resource ID of the shared user-assigned managed identity used by Container Apps and ACR pulls.')
param managedIdentityResourceId string

@description('Resource ID of the existing Azure Container Apps managed environment to join.')
param containerAppsEnvironmentResourceId string

@description('Login server of the shared Azure Container Registry, for example acme.azurecr.io.')
param containerRegistryLoginServer string

@description('External base URL of the existing Acme Bank BFF. nginx substitutes this into the /api reverse proxy at container startup.')
param bffBaseUrl string

var containerAppName = 'ca-${environmentName}-${serviceName}'
var registryName = split(containerRegistryLoginServer, '.')[0]
var managedIdentityName = last(split(managedIdentityResourceId, '/'))
var managedIdentityResourceGroup = split(managedIdentityResourceId, '/')[4]
var acrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: registryName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName
  scope: resourceGroup(managedIdentityResourceGroup)
}

resource acrPullAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, managedIdentity.properties.principalId, 'acr-pull')
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
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityResourceId}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironmentResourceId
    configuration: {
      activeRevisionsMode: 'Single'
      registries: [
        {
          server: containerRegistryLoginServer
          identity: managedIdentityResourceId
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
              value: bffBaseUrl
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

output webUrl string = 'https://${containerApp.properties.configuration.ingress.fqdn}'
output webFqdn string = containerApp.properties.configuration.ingress.fqdn
