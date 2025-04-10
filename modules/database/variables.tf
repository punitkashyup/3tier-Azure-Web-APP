# Database Module - Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "db_server_name" {
  description = "Name of the PostgreSQL server"
  type        = string
  default     = "webapp-db-server"
}

variable "postgresql_version" {
  description = "Version of PostgreSQL"
  type        = string
  default     = "13"
}

variable "postgresql_subnet_id" {
  description = "ID of the subnet for PostgreSQL"
  type        = string
}

variable "private_dns_zone_id" {
  description = "ID of the private DNS zone"
  type        = string
}

variable "administrator_login" {
  description = "Administrator login for PostgreSQL"
  type        = string
  default     = "adminpsql"
}

variable "storage_mb" {
  description = "Storage in MB for PostgreSQL"
  type        = number
  default     = 32768
}

variable "sku_name" {
  description = "SKU name for PostgreSQL"
  type        = string
  default     = "GP_Standard_D2s_v3"
}

variable "backup_retention_days" {
  description = "Backup retention days for PostgreSQL"
  type        = number
  default     = 7
}

variable "private_dns_zone_link_id" {
  description = "ID of the private DNS zone link"
  type        = string
}