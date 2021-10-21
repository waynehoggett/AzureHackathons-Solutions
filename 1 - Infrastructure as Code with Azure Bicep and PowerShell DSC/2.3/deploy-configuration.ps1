#Connect-AzAccount -Tenant "xxx-xxx-xxx-xxxx"
$ResourceGroupName = "wh-rg"
$AutomationAccountName = "whautomationaccount"
if (-not (Get-AzResourceGroup -Name $ResourceGroupName)) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $Region
}

# Import the Configuration
Import-AzAutomationDscConfiguration -SourcePath .\ServerConfiguration.ps1 -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Published -Force

# Start the Configuration Compilation Job
Start-AzAutomationDscCompilationJob -AutomationAccountName $AutomationAccountName -ConfigurationName ServerConfiguration -ResourceGroupName $ResourceGroupName