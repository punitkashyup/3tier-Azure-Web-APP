# Compute Module - Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "vm_sku" {
  description = "SKU for virtual machines"
  type        = string
  default     = "Standard_F2"
}

variable "frontend_instances" {
  description = "Number of instances in the frontend scale set"
  type        = number
  default     = 2
}

variable "backend_instances" {
  description = "Number of instances in the backend scale set"
  type        = number
  default     = 2
}

variable "admin_username" {
  description = "Admin username for virtual machines"
  type        = string
}

variable "admin_password" {
  description = "Admin password for virtual machines"
  type        = string
  sensitive   = true
}

variable "frontend_subnet_id" {
  description = "ID of the frontend subnet"
  type        = string
}

variable "backend_subnet_id" {
  description = "ID of the backend subnet"
  type        = string
}

variable "app_gateway_backend_pool_id" {
  description = "ID of the application gateway backend pool"
  type        = string
}

variable "lb_backend_pool_id" {
  description = "ID of the load balancer backend pool"
  type        = string
}

variable "frontend_identity_id" {
  description = "ID of the frontend user-assigned identity"
  type        = string
}