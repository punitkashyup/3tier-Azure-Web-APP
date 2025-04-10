# Compute Module - Main Configuration

# Frontend Virtual Machine Scale Set
resource "azurerm_linux_virtual_machine_scale_set" "frontend_vmss" {
  name                = "Front-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.vm_sku
  instances           = var.frontend_instances
  zones               = ["1", "2"]
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  custom_data         = filebase64("${path.module}/../../scripts/cloud-init.txt")

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "Frontend-Interface"
    primary = true
    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.frontend_subnet_id
      application_gateway_backend_address_pool_ids = [var.app_gateway_backend_pool_id]
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.frontend_identity_id]
  }
}

# Backend Virtual Machine Scale Set
resource "azurerm_linux_virtual_machine_scale_set" "backend_vmss" {
  name                = "Backend-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.vm_sku
  instances           = var.backend_instances
  zones               = ["1", "2"]
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  custom_data         = filebase64("${path.module}/../../scripts/cloud-init.txt")

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "Backend-Interface"
    primary = true
    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.backend_subnet_id
      load_balancer_backend_address_pool_ids = [var.lb_backend_pool_id]
    }
  }
}