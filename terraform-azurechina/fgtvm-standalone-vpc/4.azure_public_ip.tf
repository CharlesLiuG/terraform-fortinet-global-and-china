locals {
  nameEipFgt = "eip-fgt"
}

resource "azurerm_public_ip" "eipFgt" {
  name                = terraform.workspace == "default" ? local.nameEipFgt : "${local.nameEipFgt}-${terraform.workspace}"
  resource_group_name = azurerm_resource_group.resourceGrp.name
  location            = azurerm_virtual_network.vnetNgfw.location
  allocation_method   = "Static"
  sku                 = "Standard"
}
