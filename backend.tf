terraform {
  backend "azurerm" {
    resource_group_name  = "dev-rg-1"
    storage_account_name = "devdigistate"
    container_name       = "tfstatecontainer"
    key                  = "dev-terraform.tfstate"
  }
}