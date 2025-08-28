resource "azurerm_virtual_network" "vnetNgfw" {
  name                = var.vnetName
  location            = var.vnetLocation
  resource_group_name = azurerm_resource_group.resourceGrp.name
  address_space       = [var.cidrVpcNgfw]

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_subnet" "subnetPublic" {
  name                 = var.nameSubnetPublic
  resource_group_name  = azurerm_resource_group.resourceGrp.name
  virtual_network_name = azurerm_virtual_network.vnetNgfw.name
  address_prefixes     = [var.cidrSubnetPublic]
}

resource "azurerm_subnet" "subnetPrivate" {
  name                 = var.nameSubnetPrivate
  resource_group_name  = azurerm_resource_group.resourceGrp.name
  virtual_network_name = azurerm_virtual_network.vnetNgfw.name
  address_prefixes     = [var.cidrSubnetPrivate]
}
