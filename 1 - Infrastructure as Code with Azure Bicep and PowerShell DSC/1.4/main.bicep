@secure()
param vmPassword string

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
    tenantId: '<tenant id>'
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}
resource VMNIC1 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'VM1-NIC1'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'VM1-NIC1-IPConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet1.properties.subnets[0].id
          }
        }
      }
    ]
  }
}
resource VM1 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'VM1'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    osProfile: {
      computerName: 'VM1'
      adminUsername: 'AzureAdmin'
      adminPassword:  vmPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2016-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: 'VM1-Disk1'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: VMNIC1.id
        }
      ]
    }
  }
}
