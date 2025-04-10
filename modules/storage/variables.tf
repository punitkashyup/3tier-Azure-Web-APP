# Storage Module - Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
  default     = "webappstrge"
}

variable "account_tier" {
  description = "Tier of the storage account"
  type        = string
  default     = "Standard"
}

variable "account_kind" {
  description = "Kind of the storage account"
  type        = string
  default     = "StorageV2"
}

variable "account_replication_type" {
  description = "Replication type of the storage account"
  type        = string
  default     = "ZRS"
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled"
  type        = bool
  default     = false
}

variable "container_name" {
  description = "Name of the storage container"
  type        = string
  default     = "webappmedia"
}

variable "container_access_type" {
  description = "Access type of the storage container"
  type        = string
  default     = "private"
}

variable "subnet_id" {
  description = "ID of the subnet for private endpoint"
  type        = string
}

variable "dns_a_record_name" {
  description = "Name of the DNS A record"
  type        = string
  default     = "webapp-fronend"
}

variable "private_dns_zone_name" {
  description = "Name of the private DNS zone"
  type        = string
}

variable "dns_ttl" {
  description = "TTL for DNS records"
  type        = number
  default     = 300
}