#/bin/sh ./script.sh
ResourceGroup=wh-rg
Location=eastus2
#az login
#az account set --subscription 63afd83e-1bf0-4187-a021-dc57e6ee6a92
az group create --name $ResourceGroup --location $Location
az deployment group create --resource-group $ResourceGroup --template-file main.bicep --parameters @azuredeploy.parameters.json