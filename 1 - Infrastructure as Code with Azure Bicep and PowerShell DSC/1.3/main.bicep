resource vnet1 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'Vnet1'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet1'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'Subnet2'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}
resource keyVault1 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'whkeyvault${substring(uniqueString(resourceGroup().id), 0, 5)}'
  location: resourceGroup().location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableRbacAuthorization: true
    tenantId: '8940c948-d605-4e9a-b426-91153d1275f9'
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}
