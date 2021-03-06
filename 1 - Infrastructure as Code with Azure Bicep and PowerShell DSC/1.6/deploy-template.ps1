#Connect-AzAccount -Tenant "<tenant id>"
Set-AzContext -Subscription "4473dee2-2e85-4849-b421-5cc5baf520b5"
$ResourceGroupName = "whtest-rg"
$Region = "eastus"
if (-not (Get-AzResourceGroup -Name $ResourceGroupName)) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $Region
}
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile ./main.bicep -TemplateParameterFile ./azuredeploy.parameters.json