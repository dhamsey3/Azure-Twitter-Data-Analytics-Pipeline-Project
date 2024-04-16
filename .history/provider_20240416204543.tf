provider "azurerm" {
  features {}
  version = "~> 2.45"  # Use an appropriate provider version
}

terraform {
  required_version = ">= 0.14"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.45"
    }
  }
}

# Configure the Snowflake Provider
provider "snowflake" {
  username   = var.snowflake_user
  password   = var.snowflake_password
  account    = var.snowflake_account
  role       = "your_snowflake_role"
  region     = va
}
