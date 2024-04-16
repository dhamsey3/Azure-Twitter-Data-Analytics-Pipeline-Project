variable "resource_group_name" {
  type    = string
  description = "Specifies the name of the resource group"
}

variable "location" {
  type    = string
  description = "Specifies the Azure Region"
}

variable "storage_account_name" {
  type    = string
  description = "Specifies the name of the storage account"
}

variable "function_app_name" {
  type    = string
  description = "Specifies the name of the function app"
}
