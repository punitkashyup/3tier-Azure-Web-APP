# Security Module - Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

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

variable "firewall_subnet_id" {
  description = "ID of the subnet for Azure Firewall"
  type        = string
}

variable "firewall_public_ip_id" {
  description = "ID of the public IP for Azure Firewall"
  type        = string
}