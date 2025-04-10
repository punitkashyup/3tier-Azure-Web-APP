# Database Module - Outputs

output "db_id" {
  description = "ID of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.db.id
}

output "db_name" {
  description = "Name of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.db.name
}

output "db_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.db.fqdn
}

output "administrator_login" {
  description = "Administrator login for PostgreSQL"
  value       = azurerm_postgresql_flexible_server.db.administrator_login
}

output "administrator_password" {
  description = "Administrator password for PostgreSQL"
  value       = azurerm_postgresql_flexible_server.db.administrator_password
  sensitive   = true
}