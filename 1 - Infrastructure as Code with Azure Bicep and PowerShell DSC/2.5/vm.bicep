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
param automationAccountName string

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
resource VMName_Microsoft_Powershell_DSC 'Microsoft.Compute/virtualMachines/extensions@2018-06-01' = {
  parent: VM
  name: 'Microsoft.Powershell.DSC'
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      Items: {
        registrationKeyPrivate: automationAccount.listKeys().Keys[0].value
      }
    }
    settings: {
      Properties: [
        {
          Name: 'RegistrationKey'
          Value: {
            UserName: 'PLACEHOLDER_DONOTUSE'
            Password: 'PrivateSettingsRef:registrationKeyPrivate'
          }
          TypeName: 'System.Management.Automation.PSCredential'
        }
        {
          Name: 'RegistrationUrl'
          Value: reference(resourceId('Microsoft.Automation/automationAccounts', automationAccountName), '2020-01-13-preview').registrationUrl
          TypeName: 'System.String'
        }
        {
          Name: 'NodeConfigurationName'
          Value: 'ServerConfiguration.${vmName}'
          TypeName: 'System.String'
        }
        {
          Name: 'RefreshFrequencyMins'
          Value: '1440'
          TypeName: 'System.uint32'
        }
        {
          Name: 'RefreshFrequencyMins'
          Value: '60'
          TypeName: 'System.uint32'
        }
        {
          Name: 'RebootNodeIfNeeded'
          Value: 'true'
          TypeName: 'boolean'
        }
      ]
    }
  }
}
resource automationAccount 'Microsoft.Automation/automationAccounts@2019-06-01' existing = {
  name: automationAccountName
}

output vmPrivateIP string = VMNIC.properties.ipConfigurations[0].properties.privateIPAddress
