# Root Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-webapp"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "Canadacentral"
}

# Networking Variables
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

# Security Variables
variable "waf_policy_name" {
  description = "Name of the Web Application Firewall policy"
  type        = string
  default     = "webapp-waf"
}

variable "firewall_policy_name" {
  description = "Name of the Azure Firewall policy"
  type        = string
  default     = "azfw-policy"
}

variable "firewall_name" {
  description = "Name of the Azure Firewall"
  type        = string
  default     = "azfw"
}

variable "waf_mode" {
  description = "Mode of the Web Application Firewall (Detection or Prevention)"
  type        = string
  default     = "Prevention"
}

variable "blocked_ip_addresses" {
  description = "List of IP addresses to block"
  type        = list(string)
  default     = ["24.225.142.138/32"]
}

variable "workload_cidrs" {
  description = "List of CIDRs for workload IP groups"
  type        = list(string)
  default     = ["10.1.0.0/24", "10.1.1.0/24"]
}

variable "blocked_web_categories" {
  description = "List of web categories to block"
  type        = list(string)
  default     = [
    "ChildAbuseImages",
    "Gambling",
    "HateAndIntolerance",
    "IllegalDrug",
    "IllegalSoftware",
    "Nudity",
    "pornographyandsexuallyexplicit",
    "Violence",
    "Weapons"
  ]
}

# Compute Variables
variable "admin_username" {
  description = "Admin username for virtual machines"
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "Admin password for virtual machines"
  type        = string
  default     = "P@ssw0rd1234!"
  sensitive   = true
}

variable "vm_sku" {
  description = "SKU for virtual machines"
  type        = string
  default     = "Standard_F2"
}

# Original variables kept for backward compatibility
variable "heading_one" {
  type    = string
  default = "Azure Linux VM with Web Server"
}

variable "subnets" {
  default = [
    "Frontend",
    "Backend",
  ]
}