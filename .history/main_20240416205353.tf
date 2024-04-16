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
resource "azurerm_function_app" "twitter_processor" {
  name                = var.function_app_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.function_app_plan.id
  storage_account_name= azurerm_storage_account.main.name
  os_type             = "linux"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"           = "python"
    "AzureWebJobsStorage"                = azurerm_storage_account.main.primary_connection_string
    "FUNCTIONS_EXTENSION_VERSION"        = "~3"
    "SNOWFLAKE_USER"                     = var.snowflake_user
    "SNOWFLAKE_PASSWORD"                 = var.snowflake_password
    "SNOWFLAKE_ACCOUNT"                  = var.snowflake_account
  }

  identity {
    type = "SystemAssigned"
  }

  connection_strings {
    name  = "SNOWFLAKE_DB_CONNECTION"
    type  = "SQLAzure"
    value = "Server=${var.snowflake_account};Database=<database_name>;User Id=${var.snowflake_user};Password=${var.snowflake_password};"
  }

  tags = {
    environment = "production"
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


# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "functionapp-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Application Insights for monitoring Function App
resource "azurerm_application_insights" "appinsights" {
  name                = "funcappai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# Assigning an identity to Function App
resource "azurerm_user_assigned_identity" "identity" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = "funcapp-identity"
}

resource "azurerm_function_app" "function_app" {
  ...
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }
  ...
}

# Azure Data Factory
resource "azurerm_data_factory" "data_factory" {
  name                = "adf-twitteranalytics"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Link to Snowflake
resource "azurerm_data_factory_linked_service_snowflake" "snowflake" {
  name                = "SnowflakeLinkedService"
  resource_group_name = azurerm_resource_group.rg.name
  data_factory_name   = azurerm_data_factory.data_factory.name
  ...
}

# Example usage in Azure Function for Twitter API integration
resource "azurerm_function_app" "function_app" {
  ...
  app_settings = {
    "TWITTER_API_KEY"       = var.twitter_api_key
    "TWITTER_API_SECRET_KEY" = var.twitter_api_secret_key
    "TWITTER_BEARER_TOKEN"  = var.twitter_bearer_token
  }
  ...
}

# Azure Key Vault
resource "azurerm_key_vault" "example" {
  name                        = "example-vault"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  tenant_id                   = "your-tenant-id"
  soft_delete_enabled         = true
  purge_protection_enabled    = true
}

resource "azurerm_key_vault_secret" "snowflake_user" {
  name         = "snowflake-user"
  value        = "actual_user_name"
  key_vault_id = azurerm_key_vault.example.id
}

# Fetching secret in provider configuration
provider "snowflake" {
  username = data.azurerm_key_vault_secret.snowflake_user.value
  ...
}
