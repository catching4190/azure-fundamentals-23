terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
  
  subscription_id   = "43aa0595-8fda-44a4-b227-f3733785e5c2"
  tenant_id         = "8d3eeb6d-4534-4933-a2f1-019d9e341771"
  client_id         = "appId"
  client_secret     = "password"
}