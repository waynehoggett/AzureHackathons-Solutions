param VMName string
param location string
param automationAccountName string
param nodeConfigurationName string

resource VMName_Microsoft_Powershell_DSC 'Microsoft.Compute/virtualMachines/extensions@2018-06-01' = {
  name: '${VMName}/Microsoft.Powershell.DSC'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      Items: {
        registrationKeyPrivate: listKeys(resourceId('Microsoft.Automation/automationAccounts/', automationAccountName), '2018-06-30').Keys[0].value
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
          Value: reference('Microsoft.Automation/automationAccounts/${automationAccountName}').registrationUrl
          TypeName: 'System.String'
        }
        {
          Name: 'NodeConfigurationName'
          Value: nodeConfigurationName
          TypeName: 'System.String'
        }
      ]
    }
  }
  dependsOn: [
    'Microsoft.Compute/virtualMachines/${VMName}'
  ]
}