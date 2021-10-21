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
