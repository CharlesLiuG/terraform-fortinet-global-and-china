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

resource "azurerm_subnet" "subnetInternal" {
  name                 = var.nameSubnetPrivate
  resource_group_name  = azurerm_resource_group.resourceGrp.name
  virtual_network_name = azurerm_virtual_network.vnetNgfw.name
  address_prefixes     = [var.cidrSubnetPrivate]
}

resource "azurerm_subnet" "subnetHAsync" {
  name                 = var.nameSubnetHAsync
  resource_group_name  = azurerm_resource_group.resourceGrp.name
  virtual_network_name = azurerm_virtual_network.vnetNgfw.name
  address_prefixes     = [var.cidrSubnetHAsync]
}

resource "azurerm_subnet" "subnetMgmt" {
  name                 = var.nameSubnetMgmt
  resource_group_name  = azurerm_resource_group.resourceGrp.name
  virtual_network_name = azurerm_virtual_network.vnetNgfw.name
  address_prefixes     = [var.cidrSubnetMgmt]
}

resource "azurerm_subnet" "subnetApp" {
  name                 = var.nameSubnetFTest
  resource_group_name  = azurerm_resource_group.resourceGrp.name
  virtual_network_name = azurerm_virtual_network.vnetNgfw.name
  address_prefixes     = [var.cidrSubnetApp]
}
