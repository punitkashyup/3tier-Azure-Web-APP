# Root Outputs

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.webapp.name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.networking.vnet_id
}

output "waf_policy_id" {
  description = "ID of the Web Application Firewall policy"
  value       = module.security.waf_policy_id
}

output "firewall_private_ip" {
  description = "Private IP address of the Azure Firewall"
  value       = module.security.firewall_private_ip
}

output "application_gateway_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.webapp_apg.id
}

output "application_gateway_frontend_ip" {
  description = "Frontend IP of the Application Gateway"
  value       = azurerm_public_ip.webapp_pip.ip_address
}

# Database outputs
output "postgresql_flexible_server_admin_password" {
  description = "Admin password for PostgreSQL Flexible Server"
  sensitive   = true
  value       = module.database.administrator_password
}

output "postgresql_server_name" {
  description = "Name of the PostgreSQL Flexible Server"
  value       = module.database.db_name
}

output "postgresql_server_fqdn" {
  description = "FQDN of the PostgreSQL Flexible Server"
  value       = module.database.db_fqdn
}
