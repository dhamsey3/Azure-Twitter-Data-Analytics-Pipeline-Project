terraform {
  backend "azurerm" {
    storage_account_name = "tfstatestorage"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    access_key           = "storageaccountaccesskey"
  }
}
