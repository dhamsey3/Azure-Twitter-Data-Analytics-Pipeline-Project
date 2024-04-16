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
