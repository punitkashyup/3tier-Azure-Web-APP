# Networking Module - Main Configuration

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}

# Frontend Subnet
resource "azurerm_subnet" "frontend" {
  name                 = "Frontend"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.frontend_subnet_prefix]
}

# Backend Subnet
resource "azurerm_subnet" "backend" {
  name                 = "Backend"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.backend_subnet_prefix]
}

# Application Gateway Subnet
resource "azurerm_subnet" "apg" {
  name                 = "APG"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.apg_subnet_prefix]
}

# Azure Firewall Subnet
resource "azurerm_subnet" "azfw_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.firewall_subnet_prefix]
}

# Azure Bastion Subnet
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.bastion_subnet_prefix]
}

# PostgreSQL Subnet
resource "azurerm_subnet" "postgrel_subnet" {
  name                 = "postgrel-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.postgresql_subnet_prefix]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# Public IP for Bastion
resource "azurerm_public_ip" "bastion_ip" {
  name                = "Bastion_ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Public IP for Azure Firewall
resource "azurerm_public_ip" "pip_azfw" {
  name                = "web-azfw"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Security Group for Application Gateway
resource "azurerm_network_security_group" "apg_nsg" {
  name                = "APG-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "APG"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "onprem"
  }
}

# Associate NSG with Application Gateway Subnet
resource "azurerm_subnet_network_security_group_association" "apg_nsg_association" {
  subnet_id                 = azurerm_subnet.apg.id
  network_security_group_id = azurerm_network_security_group.apg_nsg.id
}

# Route Table for Firewall
resource "azurerm_route_table" "firewall_route_table" {
  depends_on          = [azurerm_subnet.azfw_subnet]
  name                = "Firewall-route-table"
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name                   = "Firewall-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }
}

# Associate Route Table with Frontend Subnet
resource "azurerm_subnet_route_table_association" "frontend_route_table" {
  subnet_id      = azurerm_subnet.frontend.id
  route_table_id = azurerm_route_table.firewall_route_table.id
}

# Associate Route Table with Backend Subnet
resource "azurerm_subnet_route_table_association" "backend_route_table" {
  subnet_id      = azurerm_subnet.backend.id
  route_table_id = azurerm_route_table.firewall_route_table.id
}