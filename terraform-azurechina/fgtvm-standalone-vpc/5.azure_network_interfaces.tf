locals {
  nameEniFgtPrivate    = "eni-fgt-private"
  nameIpAddrPrivateFgt = "ip-fgt-private"
}

################### FGT port2 ####################
resource "azurerm_network_interface" "eniFgtPrivate" {
  name                = local.nameEniFgtPrivate
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  enable_ip_forwarding = true

  ip_configuration {
    name                          = local.nameIpAddrPrivateFgt
    subnet_id                     = azurerm_subnet.subnetPrivate.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ipAddrPrivateFgt
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_network_interface_security_group_association" "eniFgtPrivateSgAssociate" {
  network_interface_id      = azurerm_network_interface.eniFgtPrivate.id
  network_security_group_id = azurerm_network_security_group.nsgFgtPrivate.id
}
