$projectName="s0dxcf9"
$resourceGroupName = "resourcegroup-$projectName"
$location = "East US"
$keyVaultName = "keyvault-$projectName"
$vmName = "vm-$projectName"
$secretKey = "vmAdminPassword"
$resourceExist = az group exists -n  $resourceGroupName

if ($resourceExist -eq "true") {
    Write-Host "0. Removing previously created '$resourceGroupName'"
    az group delete --resource-group $resourceGroupName
}

Write-Host "1. Create a resource group and key vault"
az group create -l $location -n $resourceGroupName

Write-Host "2. Create a KeyVault"
az keyvault create --name $keyVaultName --resource-group $resourceGroupName --location $location

Write-Host "3. Populate your KeyVault with a secret"
az keyvault secret set --vault-name $keyVaultName --name $secretKey --value (openssl rand -base64 12)

Write-Host "4. Get the secret from KeyVault"
$secretValue = az keyvault secret show --name $secretKey --vault-name $keyVaultName --query "value"

Write-Host "5. Create VM using secret from KeyVault"
az vm create --resource-group $resourceGroupName --name $vmName --image UbuntuLTS --admin-username azureuser --admin-password $secretValue --generate-ssh-keys
