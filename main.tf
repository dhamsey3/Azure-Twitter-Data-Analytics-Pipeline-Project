resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}

resource "azurerm_storage_container" "twitter_data" {
  name                  = "twitterdata"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_function_app" "twitter_processor" {
  name                       = var.function_app_name
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  os_type                    = "linux"
  function_app_version       = "~3"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "node"
  }

  site_config {
    app_command_line = ""
  }

  connection_string {
    name  = "AzureWebJobsStorage"
    type  = "Custom"
    value = azurerm_storage_account.main.primary_connection_string
  }

  tags = {
    environment = "production"
  }
}

### Networking and Security

resource "azurerm_virtual_network" "main" {
  name                = "main-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Groups (NSGs)

resource "azurerm_network_security_group" "function_nsg" {
  name                = "function-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "function_nsg_association" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.function_nsg.id
}

# Data Ingestion and Processing

resource "azurerm_eventhub_namespace" "main" {
  name                = "eventhubnamespace"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "main" {
  name                = "twitterstream"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = var.resource_group_name
  partition_count     = 2
  message_retention   = 1
}

# Integration with Snowflake

resource "azurerm_data_factory" "main" {
  name                = "adf-main"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "main" {
  name                = "blobstorage-linked-service"
  resource_group_name = var.resource_group_name
  data_factory_name   = azurerm_data_factory.main.name
  connection_string   = azurerm_storage_account.main.primary_connection_string
}

# Monitoring and Logging

resource "azurerm_application_insights" "main" {
  name                = "appinsights-main"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "loganalytics-main"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
}
