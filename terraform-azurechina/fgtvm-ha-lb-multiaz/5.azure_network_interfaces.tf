locals {
  eniPrivateFgt1Name = "eni-fgt1-private"
  eniHAsyncFgt1Name  = "eni-fgt1-hasync"
  eniMgmtFgt1Name    = "eni-fgt1-mgmt"
  eniPrivateFgt2Name = "eni-fgt2-private"
  eniHAsyncFgt2Name  = "eni-fgt2-hasync"
  eniMgmtFgt2Name    = "eni-fgt2-mgmt"

  ipAddrPrivateFgt1Name = "ip-fgt1-private"
  ipAddrHAsyncFgt1Name  = "ip-fgt1-hasync"
  ipAddrMgmtFgt1Name    = "ip-fgt1-mgmt"
  ipAddrPrivateFgt2Name = "ip-fgt2-private"
  ipAddrHAsyncFgt2Name  = "ip-fgt2-hasync"
  ipAddrMgmtFgt2Name    = "ip-fgt2-mgmt"
}

################### FGT-1 port2 ####################
resource "azurerm_network_interface" "eniPrivateFgt1" {
  name                = local.eniPrivateFgt1Name
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  enable_ip_forwarding = true

  ip_configuration {
    name                          = local.ipAddrPrivateFgt1Name
    subnet_id                     = azurerm_subnet.subnetInternal.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ipAddrPrivateFgt1
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_network_interface_security_group_association" "eniPrivateFgt1SgAssociate" {
  network_interface_id      = azurerm_network_interface.eniPrivateFgt1.id
  network_security_group_id = azurerm_network_security_group.nsgFgtInternal.id
}


################### FGT-Priamry port3 ####################
resource "azurerm_network_interface" "eniHAsyncFgt1" {
  name                = local.eniHAsyncFgt1Name
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  enable_ip_forwarding = false

  ip_configuration {
    name                          = local.ipAddrHAsyncFgt1Name
    subnet_id                     = azurerm_subnet.subnetHAsync.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ipAddrHAsyncFgt1
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_network_interface_security_group_association" "eniHAsyncFgt1SgAssociate" {
  network_interface_id      = azurerm_network_interface.eniHAsyncFgt1.id
  network_security_group_id = azurerm_network_security_group.nsgFgtHAsync.id
}


################### FGT-Priamry port4 ####################
resource "azurerm_network_interface" "eniMgmtFgt1" {
  name                = local.eniMgmtFgt1Name
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  enable_ip_forwarding = false

  ip_configuration {
    name                          = local.ipAddrMgmtFgt1Name
    subnet_id                     = azurerm_subnet.subnetMgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ipAddrMgmtFgt1
    public_ip_address_id          = azurerm_public_ip.eipFgt1Mgmt.id
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_network_interface_security_group_association" "eniMgmtFgt1SgAssociate" {
  network_interface_id      = azurerm_network_interface.eniMgmtFgt1.id
  network_security_group_id = azurerm_network_security_group.nsgFgtMgmt.id
}



################### FGT-2 port2 ####################
resource "azurerm_network_interface" "eniPrivateFgt2" {
  name                = local.eniPrivateFgt2Name
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  enable_ip_forwarding = true

  ip_configuration {
    name                          = local.ipAddrPrivateFgt2Name
    subnet_id                     = azurerm_subnet.subnetInternal.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ipAddrPrivateFgt2
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_network_interface_security_group_association" "eniPrivateFgt2SgAssociate" {
  network_interface_id      = azurerm_network_interface.eniPrivateFgt2.id
  network_security_group_id = azurerm_network_security_group.nsgFgtInternal.id
}


################### FGT-2 port3 ####################
resource "azurerm_network_interface" "eniHAsyncFgt2" {
  name                = local.eniHAsyncFgt2Name
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  enable_ip_forwarding = false

  ip_configuration {
    name                          = local.ipAddrHAsyncFgt2Name
    subnet_id                     = azurerm_subnet.subnetHAsync.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ipAddrHAsyncFgt2
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_network_interface_security_group_association" "eniHAsyncFgt2SgAssociate" {
  network_interface_id      = azurerm_network_interface.eniHAsyncFgt2.id
  network_security_group_id = azurerm_network_security_group.nsgFgtHAsync.id
}


################### FGT-2 port4 ####################
resource "azurerm_network_interface" "eniMgmtFgt2" {
  name                = local.eniMgmtFgt2Name
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  enable_ip_forwarding = false

  ip_configuration {
    name                          = local.ipAddrMgmtFgt2Name
    subnet_id                     = azurerm_subnet.subnetMgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ipAddrMgmtFgt2
    public_ip_address_id          = azurerm_public_ip.eipFgt2Mgmt.id
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_network_interface_security_group_association" "eniMgmtFgt2SgAssociate" {
  network_interface_id      = azurerm_network_interface.eniMgmtFgt2.id
  network_security_group_id = azurerm_network_security_group.nsgFgtMgmt.id
}
