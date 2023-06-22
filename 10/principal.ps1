$subscriptionId = (Get-AzSubscription).Id

Write-Host "1. Create Resource group as usual"

az group create --name testRG --location westus

Write-Host "2. Create service account with reader role"

$serviceAccount = az ad sp create-for-rbac `
    --role reader `
    --scopes "subscriptions/$subscriptionId" `
    | ConvertFrom-Json

Write-Host "3. Authenticate with service account"

az login --service-principal `
    -u $serviceAccount."appId" `
    -p $serviceAccount."password" `
    --tenant $serviceAccount."tenant"

Write-Host "4. Expect fail, when trying to create other Resource group with service account"

az group create --name failRG --location westus

Write-Host "5. Expect no error when trying to list resource groups."

az group list
