param virtualMachines array

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
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.3.0/24'
        }
      }
      
    ]
  }
}
resource keyVault1 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'whkeyvault${substring(uniqueString(resourceGroup().id), 0, 6)}'
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
module vmModule 'vm.bicep' = [ for virtualMachine in virtualMachines: {
  name: virtualMachine.vmName
  params: {
    vmName: virtualMachine.vmName
    vmPassword: keyVault1.getSecret(virtualMachine.vmPassword)
    vmSubnetId: vnet1.properties.subnets[0].id
    vmapplicationGatewayBackendAddressPools: applicationGateway.properties.backendAddressPools[0].id
    automationAccountName: automationAccount.name
  }
}]

resource automationAccount 'Microsoft.Automation/automationAccounts@2019-06-01' = {
  name: 'whautomationaccount'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'Free'
    }
  }
}
resource automationAccountModule 'Microsoft.Automation/automationAccounts/modules@2015-10-31' = {
  parent: automationAccount
  name: 'xPSDesiredStateConfiguration'
  properties: {
    contentLink: {
      uri: 'https://psg-prod-eastus.azureedge.net/packages/xpsdesiredstateconfiguration.9.1.0.nupkg'
    }
  }
}
resource appGW1PIP 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'AppGW1-PIP'
  location: resourceGroup().location
  sku: {
    name:'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: 'whtestwebsite'
    }
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2020-11-01' = {
  name: 'appGW1'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: vnet1.properties.subnets[1].id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          publicIPAddress: {
            id: appGW1PIP.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'AppGW1-BEPool1'
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'AppGW1-HTTPSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
        }
      }
    ]
    httpListeners: [
      {
        name: 'AppGW1Listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', 'appGW1', 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', 'appGW1', 'port_80')
          }
          protocol: 'Http'
          sslCertificate: null
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'AppGW1-DefaultRoute'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', 'appGW1', 'AppGW1Listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', 'appGW1', 'AppGW1-BEPool1')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', 'appGW1', 'AppGW1-HTTPSettings')
          }
        }
      }
    ]
  }
}

resource BastionPIP 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'Bastion1PIP'
  location: resourceGroup().location
  sku: {
    name:'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: 'whbastionhost'
    }
  }
}

resource Bastion 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: 'Bastion1'
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'IpConfiguration'
        properties: {
          publicIPAddress: {
            id: BastionPIP.id
          }
          subnet: {
            id: vnet1.properties.subnets[2].id
          }
        }
      }
    ]
  }
}
