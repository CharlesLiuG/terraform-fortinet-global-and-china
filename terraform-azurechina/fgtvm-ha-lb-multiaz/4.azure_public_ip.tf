locals {
  eipFgt1MgmtName   = "eip-fgt1-mgmt"
  eipFgt2MgmtName   = "eip-fgt2-mgmt"
  eipFgt1PublicName = "eip-fgt1"
  eipFgt2PublicName = "eip-fgt2"
}

resource "azurerm_public_ip" "eipFgt1Mgmt" {
  name                = local.eipFgt1MgmtName
  resource_group_name = azurerm_resource_group.resourceGrp.name
  location            = azurerm_virtual_network.vnetNgfw.location
  allocation_method   = "Static"
  sku                 = "Standard"
  # https://docs.microsoft.com/en-us/azure/availability-zones/az-overview
  # zones = azurerm_virtual_network.vnetNgfw.location == "chinanorth3" ? [var.azPrimary] : []
}

resource "azurerm_public_ip" "eipFgt2Mgmt" {
  name                = local.eipFgt2MgmtName
  resource_group_name = azurerm_resource_group.resourceGrp.name
  location            = azurerm_virtual_network.vnetNgfw.location
  allocation_method   = "Static"
  sku                 = "Standard"
  # https://docs.microsoft.com/en-us/azure/availability-zones/az-overview
  # zones = azurerm_virtual_network.vnetNgfw.location == "chinanorth3" ? [var.azSecondary] : []
}

resource "azurerm_public_ip" "eipFgt1Public" {
  name                = local.eipFgt1PublicName
  resource_group_name = azurerm_resource_group.resourceGrp.name
  location            = azurerm_virtual_network.vnetNgfw.location
  allocation_method   = "Static"
  sku                 = "Standard"
  # https://docs.microsoft.com/en-us/azure/availability-zones/az-overview
  # zones = azurerm_virtual_network.vnetNgfw.location == "chinanorth3" ? [var.azPrimary] : []
}

resource "azurerm_public_ip" "eipFgt2Public" {
  name                = local.eipFgt2PublicName
  resource_group_name = azurerm_resource_group.resourceGrp.name
  location            = azurerm_virtual_network.vnetNgfw.location
  allocation_method   = "Static"
  sku                 = "Standard"
  # https://docs.microsoft.com/en-us/azure/availability-zones/az-overview
  # zones = azurerm_virtual_network.vnetNgfw.location == "chinanorth3" ? [var.azSecondary] : []
}
