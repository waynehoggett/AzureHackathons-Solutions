#/bin/sh ./script.sh
ResourceGroup=wh-rg
Location=eastus2
#az login
#az account set --subscription 63afd83e-1bf0-4187-a021-dc57e6ee6a92
az group create --name $ResourceGroup --location $Location
az deployment group create --resource-group $ResourceGroup --template-file main.bicep

# Assign data plane access
az role assignment create --role "Key Vault Administrator" --assignee "waynehoggett_hotmail.com#EXT#@waynehoggetthotmail935.onmicrosoft.com" --scope "/subscriptions/63afd83e-1bf0-4187-a021-dc57e6ee6a92/resourcegroups/wh-rg/providers/Microsoft.KeyVault/vaults/whkeyvaultn6knv"

# Create a Key Vault Secret
# Linux, use Read-Host on Windows
read -p "Enter your password" myPassword
az keyvault secret set --vault-name "whkeyvaultn6knv" --name "AdminPassword" --value $myPassword