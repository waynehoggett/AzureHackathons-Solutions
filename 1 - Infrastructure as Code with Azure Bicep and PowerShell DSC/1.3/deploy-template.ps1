Connect-AzAccount -Tenant "xxx-xxx-xxx-xxxx"
$ResourceGroupName = "wh-rg"
$Region = "eastus2"
if (-not (Get-AzResourceGroup -Name $ResourceGroupName)) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $Region
}
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile ./main.bicep

# Assign data plane access
New-AzRoleAssignment -RoleDefinitionName "Key Vault Administrator" -SignInName 'waynehoggett_hotmail.com#EXT#@waynehoggetthotmail935.onmicrosoft.com' -Scope '/subscriptions/63afd83e-1bf0-4187-a021-dc57e6ee6a92/resourcegroups/wh-rg/providers/Microsoft.KeyVault/vaults/whkeyvaultn6knv'

# Create a Key Vault Secret
$SecretValue = Read-Host -Prompt "Enter your password" | ConvertTo-SecureString -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName "whkeyvaultn6knv" -Name "AdminPassword" -SecretValue $secretvalue
#Remove Secrets from memory and screen
Remove-Variable -Name SecretValue
Clear-Host