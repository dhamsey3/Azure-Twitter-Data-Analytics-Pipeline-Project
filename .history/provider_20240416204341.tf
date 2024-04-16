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
  username   = vyour_snowflake_user"
  password   = "your_snowflake_password"
  account    = "your_snowflake_account"
  role       = "your_snowflake_role"
  region     = "your_snowflake_region"
}
snowflake_user