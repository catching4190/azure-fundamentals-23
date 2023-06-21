$projectName = Get-Random
$location = "East US"
$rgName = "resourcegroup-$projectName"
$asName = "availabilityset-$projectName"
$vmName = "vm-$projectName"
$vmUser = "azureuser"
$vmSecret = openssl rand -base64 12 | ConvertTo-SecureString -AsPlainText
$vmCredentials = New-Object System.Management.Automation.PSCredential ($vmUser, $vmSecret);
$vnetName = "vnet-$projectName"
$subnetName = "subnet-$projectName"
$gatewayName = "appGateway"
$nsgName = "nsg-$projectName"
$dnsName = "myapp-$projectName"
$customScript = "{
    'fileUris': ['https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/automate_nginx.sh'],
    'commandToExecute': './automate_nginx.sh'
}"

Write-Host "1. Create Resource Group"

New-AzResourceGroup `
    -Name $rgName `
    -Location $location
    
Write-Host "2. Create Availability Set"

New-AzAvailabilitySet `
    -Name $asName `
    -Location $location `
    -ResourceGroupName $rgName `
    -Sku aligned `
    -PlatformFaultDomainCount 2 `
    -PlatformUpdateDomainCount 2

Write-Host "3. Create Virtual Network"

$vmSubnet = New-AzVirtualNetworkSubnetConfig `
    -Name $subnetName `
    -AddressPrefix "10.0.1.0/24"

New-AzVirtualNetwork `
    -Name $vnetName `
    -ResourceGroupName $rgName `
    -Location $location `
    -Subnet $vmSubnet `
    -AddressPrefix "10.0.0.0/16"
        
Write-Host "4. Create Network Security Group"

New-AzNetworkSecurityGroup `
    -Name $nsgName `
    -Location $location `
    -ResourceGroupName $rgName `

az network nsg rule create `
    --resource-group $rgName `
    --nsg-name $nsgName `
    --name "nsg-rule-allow-vnet" `
    --access Allow `
    --protocol Tcp `
    --direction Inbound `
    --priority 100 `
    --source-address-prefixes VirtualNetwork `
    --source-port-range "*" `
    --destination-port-range 80 443

Write-Host "5. Create 2 VMs and add nginx to each"

for ($i = 1; $i -le 2; $i++) {
    $vmNameCurrent = "$vmName-$i"

    New-AzVm `
        -Name $vmNameCurrent `
        -Location $location `
        -ResourceGroupName $rgName `
        -VirtualNetworkName $vnetName `
        -SubnetName $subnetName `
        -SecurityGroupName $nsgName `
        -Image Ubuntu2204 `
        -Size Standard_DS1_v2 `
        -AvailabilitySetName $asName `
        -Credential $vmCredentials `
        -GenerateSshKey `
        -SshKeyName "ssh-for-$vmNameCurrent"

    az vm extension set `
        --name CustomScript `
        --resource-group $rgName `
        --vm-name $vmNameCurrent `
        --publisher Microsoft.Azure.Extensions `
        --version 2.0 `
        --settings $customScript `
        --no-wait
    
    az vm open-port `
        --port 80 `
        --resource-group $rgName `
        --name $vmNameCurrent
}

Write-Host "6. Create the private subnet required by Application Gateway"

New-AzVirtualNetworkSubnetConfig `
    -Name "appGatewaySubnet" `
    -AddressPrefix "10.0.0.0/24"

Write-Host "7. Create a public IP address and DNS label for Application Gateway"

New-AzPublicIpAddress `
    -Name "appGatewayPublicIpAddress" `
    -ResourceGroupName $rgName `
    -Location $location `
    -Sku Standard `
    -DomainNameLabel $dnsName `
    -AllocationMethod Static

Write-Host "8. Create a Firewall Policy Application Gateway"

az network application-gateway waf-policy create `
    --name "appGatewayWafPolicy" `
    --resource-group $rgName `
    --type OWASP `
    --version 3.2

Write-Host "9. Create an Application Gateway"

az network application-gateway create `
    --resource-group $rgName `
    --name $gatewayName `
    --sku WAF_v2 `
    --capacity 2 `
    --vnet-name "appGatewayVNet" `
    --subnet "appGatewaySubnet" `
    --public-ip-address "appGatewayPublicIpAddress" `
    --http-settings-protocol Http `
    --http-settings-port 8080 `
    --private-ip-address 10.0.0.4 `
    --frontend-port 8080 `
    --waf-policy "appGatewayWafPolicy" `
    --priority 100

Write-Host "10. Add the back-end pools"

az network application-gateway address-pool create `
    --gateway-name $gatewayName `
    --resource-group $rgName `
    --name "appGatewayBackendPool" `
    --servers 10.0.1.4 10.0.1.5

Write-Host "11. Create a front-end port for 80"

az network application-gateway frontend-port create `
    --name "appGatewayFrontendPort" `
    --resource-group $rgName `
    --gateway-name $gatewayName `
    --port 80

Write-Host "12. To handle requests on port 80, create the listener"

az network application-gateway http-listener create `
    --resource-group $rgName `
    --name "appGatewayHttpListener" `
    --frontend-ip "appGatewayFrontendIP" `
    --frontend-port "appGatewayFrontendPort" `
    --gateway-name $gatewayName

Write-Host "13. Create a health probe that tests the availability of a web server"

az network application-gateway probe create `
    --resource-group $rgName `
    --gateway-name $gatewayName `
    --name "appGatewayProbe" `
    --path / `
    --interval 15 `
    --threshold 3 `
    --timeout 10 `
    --protocol Http `
    --host-name-from-http-settings true

Write-Host "14. To use the health probe recently, create the HTTP Settings for the gateway"

az network application-gateway http-settings create `
    --resource-group $rgName `
    --gateway-name $gatewayName `
    --name "appGatewayBackendHttpSettings" `
    --host-name-from-backend-pool true `
    --port 80 `
    --probe "appGatewayProbe"

Write-Host "15. Configure routing"

az network application-gateway url-path-map create `
    --resource-group $rgName `
    --gateway-name $gatewayName `
    --name "appGatewayUrlPathMap" `
    --paths /* `
    --http-settings "appGatewayBackendHttpSettings" `
    --default-http-settings "appGatewayBackendHttpSettings" `
    --address-pool "appGatewayBackendPool" `
    --default-address-pool "appGatewayBackendPool"
