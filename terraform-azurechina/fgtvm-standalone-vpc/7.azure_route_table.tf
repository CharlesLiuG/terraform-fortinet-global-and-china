locals {
  nameRtbPrivate = "rtb-fgt-private"
}

#################### Route Table Fgt Private (port2) ####################
resource "azurerm_route_table" "rtbFgtPrivate" {
  depends_on          = [azurerm_linux_virtual_machine.fgtStandalone]
  name                = local.nameRtbPrivate
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_subnet_route_table_association" "subnetPrivateAssociate" {
  depends_on     = [azurerm_route_table.rtbFgtPrivate]
  subnet_id      = azurerm_subnet.subnetPrivate.id
  route_table_id = azurerm_route_table.rtbFgtPrivate.id
}

resource "azurerm_route" "internalRoute" {
  name                   = "default"
  resource_group_name    = azurerm_resource_group.resourceGrp.name
  route_table_name       = azurerm_route_table.rtbFgtPrivate.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.eniFgtPrivate.private_ip_address
}


