# Storage Module - Main Configuration

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                         = var.storage_account_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  account_tier                 = var.account_tier
  account_kind                 = var.account_kind
  account_replication_type     = var.account_replication_type
  public_network_access_enabled = var.public_network_access_enabled
}

# Storage Container
resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = var.container_access_type
}

# Private Endpoint
resource "azurerm_private_endpoint" "endpoint" {
  name                = "${var.storage_account_name}-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.storage_account_name}-endpoint"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

# DNS A Record
resource "azurerm_private_dns_a_record" "dns_a" {
  name                = var.dns_a_record_name
  zone_name           = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = var.dns_ttl
  records             = [azurerm_private_endpoint.endpoint.private_service_connection.0.private_ip_address]
}