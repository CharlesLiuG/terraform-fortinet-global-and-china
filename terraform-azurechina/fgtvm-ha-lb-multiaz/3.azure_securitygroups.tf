resource "azurerm_network_security_group" "nsgFgtPublic" {
  name                = "nsg-fgt-public"
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
    name                       = "HTTPS"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_network_security_group" "nsgFgtInternal" {
  name                = "nsg-fgt-internal"
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_network_security_group" "nsgFgtHAsync" {
  name                = "nsg-fgt-hasync"
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_network_security_group" "nsgFgtMgmt" {
  name                = "nsg-fgt-mgmt"
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
    name                       = "HTTPS"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
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

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}
