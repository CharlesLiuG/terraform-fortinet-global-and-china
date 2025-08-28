locals {
  eniFTestLinuxName   = "eni-FTestLinux-internal"
  eniIpFTestLinuxName = "ip-FTestLinux-internal"
}


################### FTest port1 ####################
resource "azurerm_network_interface" "eniFTestLinux" {
  name                = local.eniFTestLinuxName
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  enable_ip_forwarding = false

  ip_configuration {
    name                          = local.eniIpFTestLinuxName
    subnet_id                     = azurerm_subnet.subnetApp.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.eniIpFTestLinux
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_network_interface_security_group_association" "eniFTestLinuxSgAssociate" {
  network_interface_id      = azurerm_network_interface.eniFTestLinux.id
  network_security_group_id = azurerm_network_security_group.nsgFgtInternal.id
}


resource "azurerm_linux_virtual_machine" "ftestLinux" {
  name                = var.instanceFTestLinux
  resource_group_name = azurerm_resource_group.resourceGrp.name
  location            = azurerm_virtual_network.vnetNgfw.location
  size                = var.instanceTypeFTestLinux

  disable_password_authentication = false
  admin_username                  = var.adminUsername
  admin_password                  = var.adminPassword

  network_interface_ids = [
    azurerm_network_interface.eniFTestLinux.id,
  ]

  os_disk {
    name                 = "${var.instanceFTestLinux}-OS_Disk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal-daily"
    sku       = "20_04-daily-lts"
    version   = "20.04.202002230"
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

