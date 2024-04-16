output "resource_group_id" {
  value = azurerm_resource_group.main.id
}

output "storage_account_primary_connection_string" {
  value = azurerm_storage_account.main.primary_connection_string
}
