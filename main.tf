# Main Terraform Configuration

# Resource Group
resource "azurerm_resource_group" "webapp" {
  name     = var.resource_group_name
  location = var.location
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.webapp.name
  location            = azurerm_resource_group.webapp.location
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  # Other networking variables are using defaults defined in the module

  # This is a circular dependency that will be resolved after the first apply
  # For the first apply, we use a default value defined in the module
  # firewall_private_ip = module.security.firewall_private_ip
}

# Security Module
module "security" {
  source = "./modules/security"

  resource_group_name    = azurerm_resource_group.webapp.name
  location               = azurerm_resource_group.webapp.location
  waf_policy_name        = var.waf_policy_name
  firewall_policy_name   = var.firewall_policy_name
  firewall_name          = var.firewall_name
  waf_mode               = var.waf_mode
  blocked_ip_addresses   = var.blocked_ip_addresses
  workload_cidrs         = var.workload_cidrs
  blocked_web_categories = var.blocked_web_categories
  firewall_subnet_id     = module.networking.azfw_subnet_id
  firewall_public_ip_id  = module.networking.firewall_public_ip_id

  depends_on = [module.networking]
}

# Private DNS Zones
resource "azurerm_private_dns_zone" "webapp_dns_zone" {
  name                = "webapp.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.webapp.name
}

resource "azurerm_private_dns_zone" "storage_dns_zone" {
  name                = "webapp.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.webapp.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_vnet_association" {
  name                  = "webapp-private_dns_vnet_association"
  private_dns_zone_name = azurerm_private_dns_zone.webapp_dns_zone.name
  resource_group_name   = azurerm_resource_group.webapp.name
  virtual_network_id    = module.networking.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_dns_vnet_association" {
  name                  = "webapp-storage-dns-vnet-association"
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns_zone.name
  resource_group_name   = azurerm_resource_group.webapp.name
  virtual_network_id    = module.networking.vnet_id
}

# Storage Module
module "storage" {
  source = "./modules/storage"

  resource_group_name    = azurerm_resource_group.webapp.name
  location               = azurerm_resource_group.webapp.location
  storage_account_name   = "webappstrge${random_string.storage_suffix.result}"
  subnet_id              = module.networking.frontend_subnet_id
  private_dns_zone_name  = azurerm_private_dns_zone.storage_dns_zone.name

  depends_on = [azurerm_private_dns_zone_virtual_network_link.storage_dns_vnet_association]
}

# Random string for storage account name uniqueness
resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Database Module
module "database" {
  source = "./modules/database"

  resource_group_name     = azurerm_resource_group.webapp.name
  location                = azurerm_resource_group.webapp.location
  postgresql_subnet_id    = module.networking.postgresql_subnet_id
  private_dns_zone_id     = azurerm_private_dns_zone.webapp_dns_zone.id
  private_dns_zone_link_id = azurerm_private_dns_zone_virtual_network_link.private_dns_vnet_association.id

  depends_on = [azurerm_private_dns_zone_virtual_network_link.private_dns_vnet_association]
}

# User-assigned Identity for Frontend VMSS
resource "azurerm_user_assigned_identity" "frontend_identity" {
  name                = "Frontend-identity"
  resource_group_name = azurerm_resource_group.webapp.name
  location            = azurerm_resource_group.webapp.location
}

# Role Definition for Storage Access
resource "azurerm_role_definition" "frontend_storage" {
  name        = "StorageContainerReadWrite"
  scope       = azurerm_resource_group.webapp.id
  description = "Role for read and write access to a storage container"

  permissions {
    actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/write",
    ]
  }

  assignable_scopes = [azurerm_resource_group.webapp.id]
}

# Role Assignment for Frontend Identity
resource "azurerm_role_assignment" "storage_role_assignment" {
  principal_id         = azurerm_user_assigned_identity.frontend_identity.principal_id
  role_definition_name = azurerm_role_definition.frontend_storage.name
  scope                = module.storage.storage_account_id
}

# Public IP for Application Gateway
resource "azurerm_public_ip" "webapp_pip" {
  name                = "Webapp-PIP"
  resource_group_name = azurerm_resource_group.webapp.name
  location            = azurerm_resource_group.webapp.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Application Gateway
resource "azurerm_application_gateway" "webapp_apg" {
  name                = "Webapp-APG"
  resource_group_name = azurerm_resource_group.webapp.name
  location            = azurerm_resource_group.webapp.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  zones               = ["1", "2"]
  firewall_policy_id  = module.security.waf_policy_id

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = module.networking.apg_subnet_id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.webapp_pip.id
  }

  backend_address_pool {
    name = "my-backend-pool"
  }

  backend_http_settings {
    name                  = "my-backend-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "my-https-listener"
    frontend_ip_configuration_name = "PublicIPAddress"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "my-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "my-https-listener"
    backend_address_pool_name  = "my-backend-pool"
    backend_http_settings_name = "my-backend-http-settings"
    priority                   = 1
  }

  depends_on = [module.security, azurerm_public_ip.webapp_pip]
}

# Load Balancer for Backend
resource "azurerm_lb" "backend_lb" {
  name                = "Backend-LB"
  resource_group_name = azurerm_resource_group.webapp.name
  location            = azurerm_resource_group.webapp.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "backendlbip"
    subnet_id                     = module.networking.backend_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.backend_lb.id
  name            = "backendpool"
}

resource "azurerm_lb_probe" "backend_probe" {
  loadbalancer_id = azurerm_lb.backend_lb.id
  name            = "http-probe"
  protocol        = "Http"
  request_path    = "/"
  port            = 80
}

resource "azurerm_lb_rule" "backend_rule" {
  loadbalancer_id                = azurerm_lb.backend_lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "backendlbip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.backend_probe.id
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  resource_group_name        = azurerm_resource_group.webapp.name
  location                   = azurerm_resource_group.webapp.location
  vm_sku                     = var.vm_sku
  admin_username             = var.admin_username
  admin_password             = var.admin_password
  frontend_subnet_id         = module.networking.frontend_subnet_id
  backend_subnet_id          = module.networking.backend_subnet_id
  app_gateway_backend_pool_id = "${azurerm_application_gateway.webapp_apg.id}/backendAddressPools/my-backend-pool"
  lb_backend_pool_id         = azurerm_lb_backend_address_pool.backend_pool.id
  frontend_identity_id       = azurerm_user_assigned_identity.frontend_identity.id

  depends_on = [
    module.networking,
    azurerm_application_gateway.webapp_apg,
    azurerm_lb_backend_address_pool.backend_pool,
    module.security,
    module.storage,
    module.database
  ]
}

# Auto-scaling for Frontend VMSS
resource "azurerm_monitor_autoscale_setting" "frontend_autoscale" {
  name                = "Frontend-autoscale"
  resource_group_name = azurerm_resource_group.webapp.name
  location            = azurerm_resource_group.webapp.location
  target_resource_id  = module.compute.frontend_vmss_id

  profile {
    name = "defaultProfile"

    capacity {
      default = 2
      minimum = 2
      maximum = 6
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = module.compute.frontend_vmss_id
        time_grain         = "PT2M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT3M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = module.compute.frontend_vmss_id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
    }
  }
}

# Auto-scaling for Backend VMSS
resource "azurerm_monitor_autoscale_setting" "backend_autoscale" {
  name                = "Backend-autoscale"
  resource_group_name = azurerm_resource_group.webapp.name
  location            = azurerm_resource_group.webapp.location
  target_resource_id  = module.compute.backend_vmss_id

  profile {
    name = "defaultProfile"

    capacity {
      default = 2
      minimum = 2
      maximum = 6
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = module.compute.backend_vmss_id
        time_grain         = "PT2M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT3M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = module.compute.backend_vmss_id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
    }
  }
}

# Bastion Host
resource "azurerm_bastion_host" "webapp_bastion" {
  name                = "webapp-Bastion"
  location            = azurerm_resource_group.webapp.location
  resource_group_name = azurerm_resource_group.webapp.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = module.networking.bastion_subnet_id
    public_ip_address_id = module.networking.bastion_public_ip_id
  }

  depends_on = [module.networking]
}