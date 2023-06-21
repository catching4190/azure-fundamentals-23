$projectName = Get-Random
$location = "East US"
$rgName = "resourcegroup-$projectName"
$registryName = "whoahub"
$image = "ngdemo"
$containerName = "strange-quark"

Write-Host "1. Create resource group"

az group create --name $rgName --location westus2

Write-Host "2. Create a container registry and allow anonymous pull"

az acr create `
    --resource-group $rgName `
    --name $registryName `
    --sku Standard 

az acr update --name $registryName --anonymous-pull-enabled

# az acr delete `
#     --resource-group $rgName `
#     --name $registryName

Write-Host "3. Build and push image from a Dockerfile"

az acr build `
    --image ${image}:v1 `
    --registry $registryName `
    --file Dockerfile . 

Write-Warning -Message "Change index.html and hit Enter to build image v2" -WarningAction Inquire

az acr build `
    --image ${image}:v2 `
    --registry $registryName `
    --file Dockerfile . 

Write-Host "4. Create and run the container"

# az container create `
#     --resource-group $rgName `
#     --name $containerName `
#     --image "${registryName}.azurecr.io/${image}:v1" `
#     --dns-name-label mxn-demo --ports 80
    
az container create `
    --resource-group $rgName `
    --name $containerName `
    --image "${registryName}.azurecr.io/mxnsample:v1" `
    --dns-name-label mxn-demo `
    --ports 80 `
    --registry-login-server ${registryName}.azurecr.io `
    --registry-password anonymous `
    --registry-username anonymous
    
Write-Host "5. Get info"

az container show `
    --resource-group $rgName `
    --name $containerName `
    --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}" `
    --out table
    
Write-Host "6. See logs"

az container logs --resource-group $rgName --name $containerName