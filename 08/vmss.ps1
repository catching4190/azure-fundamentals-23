$projectName = Get-Random
$location = "East US"
$rgName = "resourcegroup-$projectName"
$ssName = "scaleset-$projectName"
$asName = "availabilityset-$projectName"
$agName = "appgateway-$projectName"
$vnetName = "vnet-$projectName"
$subnetName = "subnet-$projectName"
$nsgName = "nsg-$projectName"
$pubipName = "pubip-$projectName"

# Create a resource group
az group create --name $rgName --location $location

# Create an Availability Set
az vm availability-set create `
    --resource-group $rgName `
    --name $asName `
    --location $location `
    --platform-fault-domain-count 2 `
    --platform-update-domain-count 2

# Create a Virtual Machine Scale Set
az vmss create `
    --resource-group $rgName `
    --name $ssName `
    --image UbuntuLTS `
    --orchestration-mode Flexible `
    --admin-username "azureuser" `
    --generate-ssh-keys

# Apply the Custom Script Extension
az vmss extension set `
    --publisher Microsoft.Azure.Extensions `
    --version 2.0 `
    --name CustomScript `
    --resource-group $rgName `
    --vmss-name $ssName `
    --settings "customConfig.json"

# Microsoft.Network/loadBalancers/myScaleSetLB
# Microsoft.Network/publicIPAddresses/myScaleSetLBPublicIP

# To allow traffic to reach the web server, create a load balancer rule
az network lb rule create `
    --resource-group $rgName `
    --name "myLoadBalancerRuleWeb" `
    --lb-name "${ssName}LB" `
    --backend-pool-name "${ssName}LBBEPool" `
    --backend-port 80 `
    --frontend-ip-name "loadBalancerFrontEnd" `
    --frontend-port 80 `
    --protocol tcp

# Obtains the IP address for myScaleSetLBPublicIP created as part of the scale set
az network public-ip show `
    --resource-group $rgName `
    --name "${ssName}LBPublicIP" `
    --query [ipAddress] `
    --output table
