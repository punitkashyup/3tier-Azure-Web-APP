# Database Module - Main Configuration

# Generate random password for PostgreSQL admin
resource "random_password" "db_password" {
  length  = 20
  special = true
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "db" {
  name                   = var.db_server_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.postgresql_version
  delegated_subnet_id    = var.postgresql_subnet_id
  private_dns_zone_id    = var.private_dns_zone_id
  administrator_login    = var.administrator_login
  administrator_password = random_password.db_password.result

  high_availability {
    mode = "ZoneRedundant"
  }

  zone                  = "1"
  storage_mb            = var.storage_mb
  sku_name              = var.sku_name
  backup_retention_days = var.backup_retention_days

  depends_on = [var.private_dns_zone_link_id]
}