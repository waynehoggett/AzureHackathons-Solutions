param vmSubnetId string
param location string = resourceGroup().location
param vmName string
@secure()
param vmPassword string
param vmSize string  = 'Standard_A2_v2'
param vmUsername string = 'AzureAdmin'
param vmPublisher string = 'MicrosoftWindowsServer'
param vmOffer string = 'WindowsServer'
param vmSku string = '2016-Datacenter'
param vmVersion string = 'latest'
param vmapplicationGatewayBackendAddressPools string

resource VMNIC 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${vmName}-NIC1'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${vmName}-NIC1-IPConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vmSubnetId
          }
          applicationGatewayBackendAddressPools: [
            {
              id: vmapplicationGatewayBackendAddressPools
            }
          ]
        }
      }
    ]
  }
}
resource VM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: vmUsername
      adminPassword:  vmPassword
    }
    storageProfile: {
      imageReference: {
        publisher: vmPublisher
        offer: vmOffer
        sku: vmSku
        version: vmVersion
      }
      osDisk: {
        name: '${vmName}-Disk1'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: VMNIC.id
        }
      ]
    }
  }
}

output vmPrivateIP string = VMNIC.properties.ipConfigurations[0].properties.privateIPAddress
