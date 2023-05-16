# 05 - Azure App Service and Azure Functions and Terraform Azure

## Homework

- Deploy web app
- Deploy smth via terraform

### Deploy Web App

Deployed Web App:
![Deployed web app](./deploy_webapp/deployed-webapp.png)

Azure Portal screenshot:
![Azure Portal screenshot](./deploy_webapp/azure-portal-webapp.png)

Bash CLI output:
[bash-az-cli.txt](./deploy_webapp/bash-az-cli.txt)

## Web app

1. Init npm project
2. Add index.js file
3. Write simple http server
4. Add start script to package.json
5. Deploy
6. Wait 5-7 min
7. Verify

```bash
# Deploy
az webapp up --location westeurope --name testwebapp-$RANDOM --sku FREE
```

> Resource group, AppServicePlan, etc. will be created automatically
> Type of deployment (in our case zip) will be recognized by content
> Git init inside the app maybe necessary

- `az webapp up`: webapp up is a feature of the az command-line interface that packages your app and deploys it. Unlike other deployment methods, az webapp up can create a new App Service web app for you if you haven't already created one.

- ZIP deploy: You can use `az webapp deployment source config-zip` to send a ZIP of your application files to App Service. You can also access ZIP deploy via basic HTTP utilities such as curl.

```bash
# Redeploy
az webapp up --resource-group {rg_name} --name {app_name}

# List
az webapp list --output table

# Clean up
az group delete --resource-group {rg_name}
```
