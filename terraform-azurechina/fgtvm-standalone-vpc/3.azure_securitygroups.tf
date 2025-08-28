locals {
  nameSgFgtPublic  = "nsg-fgt-public"
  nameSgFgtPrivate = "nsg-fgt-private"
}

#################### Security Group of FortiGate Public Interface [port1] ####################
resource "azurerm_network_security_group" "nsgFgtPublic" {
  name                = local.nameSgFgtPublic
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  security_rule {
    name                       = "ICMP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "FGTHTTPS"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.adminsPort
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "FGTVIP"
    priority                   = 210
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.fgtConfVipExtPort
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "VPNIKE"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "VPNNATT"
    priority                   = 410
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "4500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}


#################### Security Group of FortiGate Private Interface [port2] ####################
resource "azurerm_network_security_group" "nsgFgtPrivate" {
  name                = local.nameSgFgtPrivate
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}
