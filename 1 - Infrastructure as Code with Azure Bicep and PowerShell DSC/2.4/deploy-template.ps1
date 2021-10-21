#Connect-AzAccount -Tenant "xxx-xxx-xxx-xxxx"
$ResourceGroupName = "wh-rg"
$Region = "eastus"
if (-not (Get-AzResourceGroup -Name $ResourceGroupName)) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $Region
}
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile ./main.bicep -TemplateParameterFile ./azuredeploy.parameters.json