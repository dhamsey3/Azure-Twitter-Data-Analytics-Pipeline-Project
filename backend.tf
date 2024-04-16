terraform {
  backend "azurerm" {
    storage_account_name = "yourstorageaccount"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    access_key           = "storageaccountaccesskey"
  }
}
