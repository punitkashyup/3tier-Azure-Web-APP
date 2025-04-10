# Networking Module - Outputs

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "frontend_subnet_id" {
  description = "ID of the frontend subnet"
  value       = azurerm_subnet.frontend.id
}

output "backend_subnet_id" {
  description = "ID of the backend subnet"
  value       = azurerm_subnet.backend.id
}

output "apg_subnet_id" {
  description = "ID of the application gateway subnet"
  value       = azurerm_subnet.apg.id
}

output "azfw_subnet_id" {
  description = "ID of the Azure Firewall subnet"
  value       = azurerm_subnet.azfw_subnet.id
}

output "bastion_subnet_id" {
  description = "ID of the Azure Bastion subnet"
  value       = azurerm_subnet.bastion_subnet.id
}

output "postgresql_subnet_id" {
  description = "ID of the PostgreSQL subnet"
  value       = azurerm_subnet.postgrel_subnet.id
}

output "bastion_public_ip_id" {
  description = "ID of the Bastion public IP"
  value       = azurerm_public_ip.bastion_ip.id
}

output "firewall_public_ip_id" {
  description = "ID of the Azure Firewall public IP"
  value       = azurerm_public_ip.pip_azfw.id
}