param location string
param applicationGatewayName string
param tier string
param skuSize string
param capacity int = 2
param subnetName string
param zones array
param publicIpAddressName string
param sku string
param allocationMethod string
param publicIpZones array

var vnetId = '/subscriptions/63afd83e-1bf0-4187-a021-dc57e6ee6a92/resourceGroups/wh-rg/providers/Microsoft.Network/virtualNetworks/Vnet1'
var publicIPRef = publicIpAddressName_resource.id
var subnetRef = '${vnetId}/subnets/${subnetName}'
var applicationGatewayId = applicationGatewayName_resource.id

resource applicationGatewayName_resource 'Microsoft.Network/applicationGateways@2019-09-01' = {
  name: applicationGatewayName
  location: location
  zones: zones
  tags: {}
  properties: {
    sku: {
      name: skuSize
      tier: tier
      capacity: capacity
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          publicIPAddress: {
            id: publicIPRef
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
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'AppGW1-HTTPSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'AppGW1Listener'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGatewayId}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${applicationGatewayId}/frontendPorts/port_80'
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
            id: '${applicationGatewayId}/httpListeners/AppGW1Listener'
          }
          priority: null
          backendAddressPool: {
            id: '${applicationGatewayId}/backendAddressPools/AppGW1-BEPool1'
          }
          backendHttpSettings: {
            id: '${applicationGatewayId}/backendHttpSettingsCollection/AppGW1-HTTPSettings'
          }
        }
      }
    ]
    enableHttp2: false
    sslCertificates: []
    probes: []
  }
}

resource publicIpAddressName_resource 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: sku
  }
  zones: publicIpZones
  properties: {
    publicIPAllocationMethod: allocationMethod
  }
}