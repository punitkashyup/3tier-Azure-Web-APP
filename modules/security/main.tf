# Security Module - Main Configuration

# Web Application Firewall Policy
resource "azurerm_web_application_firewall_policy" "webapp_waf" {
  name                = var.waf_policy_name
  resource_group_name = var.resource_group_name
  location            = var.location

  custom_rules {
    name      = "Rule1"
    priority  = 1
    rule_type = "MatchRule"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }

      operator           = "IPMatch"
      negation_condition = false
      match_values       = var.blocked_ip_addresses
    }

    action = "Block"
  }

  custom_rules {
    name      = "Rule2"
    priority  = 2
    rule_type = "MatchRule"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }

      operator           = "IPMatch"
      negation_condition = false
      match_values       = ["192.168.1.0/24"]
    }

    match_conditions {
      match_variables {
        variable_name = "RequestHeaders"
        selector      = "UserAgent"
      }

      operator           = "Contains"
      negation_condition = false
      match_values       = ["Windows"]
    }

    action = "Block"
  }

  policy_settings {
    enabled                     = true
    mode                        = var.waf_mode
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
      rule_group_override {
        rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
        rule {
          id      = "920330"
          enabled = true
          action  = "Log"
        }

        rule {
          id      = "920190"
          enabled = true
          action  = "Block"
        }
      }
    }
  }
}

# Azure Firewall Policy
resource "azurerm_firewall_policy" "azfw_policy" {
  name                     = var.firewall_policy_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  sku                      = "Premium"
  threat_intelligence_mode = "Alert"
}

# IP Group for workloads
resource "azurerm_ip_group" "workload_ip_group" {
  name                = "workload-ip-group"
  location            = var.location
  resource_group_name = var.resource_group_name
  cidrs               = var.workload_cidrs
}

# Network Rule Collection Group
resource "azurerm_firewall_policy_rule_collection_group" "net_policy_rule_collection_group" {
  name               = "DefaultNetworkRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.azfw_policy.id
  priority           = 200

  network_rule_collection {
    name     = "DefaultNetworkRuleCollection"
    action   = "Allow"
    priority = 200
    rule {
      name                  = "DNS"
      protocols             = ["UDP", "TCP"]
      source_ip_groups      = [azurerm_ip_group.workload_ip_group.id]
      destination_ports     = ["53"]
      destination_addresses = ["0.0.0.0/0"]
    }
  }
}

# Application Rule Collection Group
resource "azurerm_firewall_policy_rule_collection_group" "app_policy_rule_collection_group" {
  name               = "DefaulApplicationtRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.azfw_policy.id
  priority           = 300

  application_rule_collection {
    name     = "WebCategoriesRule"
    action   = "Deny"
    priority = 400
    rule {
      name        = "Block defined URL categories"
      description = "Block known URL categories"

      protocols {
        type = "Http"
        port = 80
      }

      protocols {
        type = "Https"
        port = 443
      }

      source_ip_groups = [azurerm_ip_group.workload_ip_group.id]
      web_categories  = var.blocked_web_categories
    }
  }

  application_rule_collection {
    name     = "Allow Web traffic"
    action   = "Allow"
    priority = 500
    rule {
      name        = "Global Rule"
      description = "Allow Internet Access"

      protocols {
        type = "Https"
        port = 443
      }

      protocols {
        type = "Http"
        port = 80
      }

      destination_fqdns = ["*"]
      terminate_tls     = false
      source_ip_groups  = [azurerm_ip_group.workload_ip_group.id]
    }
  }
}

# Azure Firewall
resource "azurerm_firewall" "fw" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"

  ip_configuration {
    name                 = "azfw-ipconfig"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = var.firewall_public_ip_id
  }

  firewall_policy_id = azurerm_firewall_policy.azfw_policy.id
}