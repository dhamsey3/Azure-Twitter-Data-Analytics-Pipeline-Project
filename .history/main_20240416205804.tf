

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
    "TWITTER_API_KEY"          = var.twitter_api_key
    "TWITTER_API_SECRET_KEY"   = var.twitter_api_secret_key
    "TWITTER_BEARER_TOKEN"     = var.twitter_bearer_token
  }
  identity {
    type = "SystemAssigned"
  }
  service_plan_id = azurerm_app_service_plan.app_service_plan.id
  subnet_id       = azurerm_subnet.subnet.id
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "analyticsServicePlan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Standard"
    size = "S1"
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


# Network Security 
resource "azurerm_virtual_network" "vnet" {
  name                = "analyticsVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "analyticsSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "analyticsNSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
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
