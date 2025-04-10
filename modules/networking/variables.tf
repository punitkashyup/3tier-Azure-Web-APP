# Networking Module - Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "Webapp-Vnet"
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "frontend_subnet_prefix" {
  description = "Address prefix for the frontend subnet"
  type        = string
  default     = "10.1.0.0/24"
}

variable "backend_subnet_prefix" {
  description = "Address prefix for the backend subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "apg_subnet_prefix" {
  description = "Address prefix for the application gateway subnet"
  type        = string
  default     = "10.1.2.0/24"
}

variable "firewall_subnet_prefix" {
  description = "Address prefix for the Azure Firewall subnet"
  type        = string
  default     = "10.1.3.0/24"
}

variable "bastion_subnet_prefix" {
  description = "Address prefix for the Azure Bastion subnet"
  type        = string
  default     = "10.1.9.0/27"
}

variable "postgresql_subnet_prefix" {
  description = "Address prefix for the PostgreSQL subnet"
  type        = string
  default     = "10.1.10.0/24"
}

variable "firewall_private_ip" {
  description = "Private IP address of the Azure Firewall"
  type        = string
  default     = "10.1.3.4"
}