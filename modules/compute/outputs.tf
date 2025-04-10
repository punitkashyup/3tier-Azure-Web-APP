# Compute Module - Outputs

output "frontend_vmss_id" {
  description = "ID of the frontend virtual machine scale set"
  value       = azurerm_linux_virtual_machine_scale_set.frontend_vmss.id
}

output "backend_vmss_id" {
  description = "ID of the backend virtual machine scale set"
  value       = azurerm_linux_virtual_machine_scale_set.backend_vmss.id
}

output "frontend_vmss_name" {
  description = "Name of the frontend virtual machine scale set"
  value       = azurerm_linux_virtual_machine_scale_set.frontend_vmss.name
}

output "backend_vmss_name" {
  description = "Name of the backend virtual machine scale set"
  value       = azurerm_linux_virtual_machine_scale_set.backend_vmss.name
}