# Storage Module - Outputs

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.storage.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.storage.name
}

output "storage_container_id" {
  description = "ID of the storage container"
  value       = azurerm_storage_container.container.id
}

output "storage_container_name" {
  description = "Name of the storage container"
  value       = azurerm_storage_container.container.name
}

output "private_endpoint_id" {
  description = "ID of the private endpoint"
  value       = azurerm_private_endpoint.endpoint.id
}

output "private_endpoint_ip" {
  description = "Private IP of the private endpoint"
  value       = azurerm_private_endpoint.endpoint.private_service_connection.0.private_ip_address
}