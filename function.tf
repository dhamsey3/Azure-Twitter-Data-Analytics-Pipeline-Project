resource "azurerm_app_service_plan" "function_app_plan" {
  name                = "${var.function_app_name}-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "FunctionApp"
  reserved            = true  # Required for Linux

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

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


# Integrate Azure Key Vault

resource "azurerm_key_vault" "main" {
  name                = "kv-${var.function_app_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "standard"

  tenant_id = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled = true
  purge_protection_enabled = true
}

resource "azurerm_key_vault_secret" "snowflake_user" {
  name         = "SnowflakeUser"
  value        = var.snowflake_user
  key_vault_id = azurerm_key_vault.main.id
}


