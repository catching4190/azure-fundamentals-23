$rgName = "resourcegroup-22249219"
$containerName = "strange-quark"
$registryName = "whoahub"
$image = "ngdemo"


az container create `
    --resource-group $rgName `
    --name $containerName `
    --image "${registryName}.azurecr.io/${image}:v1" `
    --dns-name-label mxn-demo `
    --ports 80 `
    --registry-login-server "${registryName}.azurecr.io" `
    --registry-password anonymous `
    --registry-username anonymous

# az container show `
#     --resource-group $rgName `
#     --name $containerName `
#     --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}" `
#     --out table