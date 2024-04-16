variable "resource_group_name" {
  description = "Specifies the name of the resource group"
  type        = string
}

variable "location" {
  description = "Specifies the Azure Region"
  type        = string
}

variable "storage_account_name" {
  description = "Specifies the name of the storage account"
  type        = string
}

variable "function_app_name" {
  description = "Specifies the name of the function app"
  type        = string
}

variable "snowflake_user" {
  description = "Snowflake user name"
  type        = string
}

variable "snowflake_password" {
  description = "Snowflake password"
  type        = string
}

variable "snowflake_account" {
  description = "Snowflake account identifier"
  type        = string
}
