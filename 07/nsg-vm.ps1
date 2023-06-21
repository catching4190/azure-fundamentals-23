
$projectName="ao8sadu"
$resourceGroupName = "resourcegroup-$projectName"
$location = "East US"
$vmName = "vm-$projectName"
$nsgName = "nsg-$projectName"
$nsgRuleName = "nsg-deny-rule-$projectName"
$vmSecret=openssl rand -base64 12
$resourceExist = az group exists -n  $resourceGroupName

if ($resourceExist -eq "true") {
    Write-Host "Removing previously created '$resourceGroupName'"
    az group delete --resource-group $resourceGroupName
}

Write-Host "1. Create Resource Group"

az group create -l $location -n $resourceGroupName

Write-Host "2. Create VM"

az vm create `
    --resource-group $resourceGroupName `
    --name $vmName `
    --image UbuntuLTS `
    --admin-username azureuser `
    --admin-password $vmSecret `
    --generate-ssh-keys

Write-Host "3. Setup Apache"

az vm extension set `
    --resource-group $resourceGroupName `
    --vm-name $vmName `
    --name customScript `
    --publisher Microsoft.Azure.Extensions `
    --settings ./nsg-script-config.json
    
Write-Host "4. Open the 80 port"

az vm open-port `
    --port 80 `
    --resource-group $resourceGroupName `
    --name $vmName

Write-Warning -Message "VM with Apache created. Try to look around, verify access to the site - default Apache page should be opened."
Write-Warning -Message "Next, a new Network Security Group will be created with deny access." -WarningAction Inquire
    
Write-Host "5. Create a new Network Security Group"

az network nsg create `
    --resource-group $resourceGroupName `
    --name $nsgName `
    --tags memo=restrict_80

Write-Host "6. Restrict access via 80 and 443"

az network nsg rule create `
    --resource-group $resourceGroupName `
    --nsg-name $nsgName `
    --name $nsgRuleName `
    --priority 100 `
    --access Deny `
    --protocol Tcp `
    --destination-port-ranges 80, 443 `
    --description "Deny from any IP address on 80 and 443"
    
Write-Host "7. Update a network interface to use a different network security group"

# Get Network Interface name
$output = az vm show `
    --resource-group $resourceGroupName `
    --name $vmName `
    --query "networkProfile.networkInterfaces[0].id"

$nicName = $output.Trim('"') | Split-Path -Leaf

# Associate it with new NSG
az network nic update `
    --name $nicName `
    --resource-group $resourceGroupName `
    --network-security-group $nsgName

Write-Host "8. Get the effective security rules for a network interface"

az network nic list-effective-nsg `
    --resource-group $resourceGroupName `
    --name $nicName
