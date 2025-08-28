locals {
  nameRtb = "rtb-fgt"
}

#################### Route Table DEFINITION ####################
resource "azurerm_route_table" "rtbFgt" {
  depends_on          = [azurerm_lb.ilb]
  name                = local.nameRtb
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}


#################### Route Table Association DEFINITION ####################
resource "azurerm_subnet_route_table_association" "subnetInternalAssociate" {
  depends_on     = [azurerm_route_table.rtbFgt]
  subnet_id      = azurerm_subnet.subnetApp.id
  route_table_id = azurerm_route_table.rtbFgt.id
}


#################### UDR(User Defined Routes) DEFINITION ####################
resource "azurerm_route" "internalRoute" {
  name                   = "default"
  resource_group_name    = azurerm_resource_group.resourceGrp.name
  route_table_name       = azurerm_route_table.rtbFgt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_lb.ilb.frontend_ip_configuration[0].private_ip_address
}

