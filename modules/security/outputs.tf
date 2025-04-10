# Security Module - Outputs

output "waf_policy_id" {
  description = "ID of the Web Application Firewall policy"
  value       = azurerm_web_application_firewall_policy.webapp_waf.id
}

output "firewall_policy_id" {
  description = "ID of the Azure Firewall policy"
  value       = azurerm_firewall_policy.azfw_policy.id
}

output "firewall_id" {
  description = "ID of the Azure Firewall"
  value       = azurerm_firewall.fw.id
}

output "firewall_private_ip" {
  description = "Private IP address of the Azure Firewall"
  value       = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}