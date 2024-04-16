# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "analyticsResourceGroup"
  location = "East US"
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "twstorageacct"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Function App and Application Insights for monitoring
resource "azurerm_function_app" "function_app" {
  name                       = "TwitterIngestionFunction"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  os_type                    = "linux"
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
  }
}

# Snowflake Warehouse
resource "snowflake_warehouse" "warehouse" {
  name           = "COMPUTE_WH"
  warehouse_size = "X-SMALL"
  auto_suspend   = 120
  auto_resume    = true
}

# Snowflake Database
resource "snowflake_database" "database" {
  name = "TWITTER_ANALYTICS_DB"
}

# Snowflake Schema
resource "snowflake_schema" "schema" {
  name      = "TWITTER_DATA"
  database  = snowflake_database.database.name
}

# Example Table
resource "snowflake_table" "table" {
  database = snowflake_database.database.name
  schema   = snowflake_schema.schema.name
  name     = "TWEETS"
  column {
    name = "TWEET_ID"
    type = "VARCHAR(255)"
  }
  column {
    name = "TEXT"
    type = "VARCHAR(255)"
  }
  column {
    name = "CREATED_AT"
    type = "TIMESTAMP"
  }
}
