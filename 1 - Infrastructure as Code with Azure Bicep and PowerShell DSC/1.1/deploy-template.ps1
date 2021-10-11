Connect-AzAccount -Tenant "xxx-xxx-xxx-xxxx"
$ResourceGroupName = "wh-rg"
$Region = "eastus2"
New-AzResourceGroup -Name $ResourceGroupName -Location $Region
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile ./main.bicep