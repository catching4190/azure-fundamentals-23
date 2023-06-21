$projectName = "ao8sadu"
$resourceGroupName = "resourcegroup-$projectName"
$location = "East US"
$vmName = "vm-$projectName"
$nsgName = "nsg-$projectName"
$nsgRuleName = "nsg-deny-rule-$projectName"
$vmSecret = openssl rand -base64 12

# az vm open-port --port 80 --resource-group $resourceGroupName --name $vmName

# az network nsg rule create `
#     --resource-group $resourceGroupName `
#     --nsg-name $nsgName `
#     --name $nsgRuleName `
#     --priority 100 `
#     --access Deny `
#     --protocol Tcp `
#     --destination-port-ranges [80,443] `
#     --description "Deny from any IP address on 80 and 443"


$output = az vm show `
    --resource-group $resourceGroupName `
    --name $vmName `
    --query "networkProfile.networkInterfaces[0].id"

$nicName = $output.Trim('"') | Split-Path -Leaf

az network nic update `
    --name $nicName `
    --resource-group $resourceGroupName `
    --network-security-group $nsgName

az network nic list-effective-nsg `
    --resource-group $resourceGroupName `
    --name $nicName
