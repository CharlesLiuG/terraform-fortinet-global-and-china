locals {
  eniFgt1PublicName    = "eni-fgt1-public"
  ipAddrPublicFgt1Name = "ip-fgt1-public"
}


################### FGT-1 port1 ####################
resource "azurerm_network_interface" "eniFgt1Public" {
  name                = local.eniFgt1PublicName
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  enable_ip_forwarding = false

  ip_configuration {
    name                          = local.ipAddrPublicFgt1Name
    subnet_id                     = azurerm_subnet.subnetPublic.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ipAddrPublicFgt1
    public_ip_address_id          = azurerm_public_ip.eipFgt1Public.id
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_network_interface_security_group_association" "eniFgt1PublicSgAssociate" {
  network_interface_id      = azurerm_network_interface.eniFgt1Public.id
  network_security_group_id = azurerm_network_security_group.nsgFgtPublic.id
}

resource "azurerm_managed_disk" "fgt1DataDisk" {
  name                 = "${azurerm_linux_virtual_machine.fgt1.name}-DataDisk"
  resource_group_name  = azurerm_resource_group.resourceGrp.name
  location             = azurerm_virtual_network.vnetNgfw.location
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

locals {
  azureCloud = var.isAzureChinaCloud == true ? "china" : var.imageVersion == "fgtvm72" ? "global72" : "global"
}

resource "azurerm_linux_virtual_machine" "fgt1" {
  name                = var.instanceNameFGT1
  resource_group_name = azurerm_resource_group.resourceGrp.name
  location            = azurerm_virtual_network.vnetNgfw.location
  size                = var.instanceType

  disable_password_authentication = false
  admin_username                  = var.adminUsername
  admin_password                  = var.adminPassword
  custom_data = base64encode(templatefile(var.instanceBootstrapFgt1,
    {
      licenseType      = var.licenseType
      licenseFile      = var.licenseFileFgt1
      adminsPort       = var.adminsPort
      cidrDestination  = var.cidrVpcNgfw
      ipAddrPublic     = var.ipAddrPublicFgt1
      ipMaskPublic     = cidrnetmask(var.cidrSubnetPublic)
      ipAddrPrivate    = var.ipAddrPrivateFgt1
      ipMaskPrivate    = cidrnetmask(var.cidrSubnetPrivate)
      ipAddrHAsync     = var.ipAddrHAsyncFgt1
      ipMaskHAsync     = cidrnetmask(var.cidrSubnetHAsync)
      ipAddrHAsyncPeer = var.ipAddrHAsyncFgt2
      ipAddrMgmt       = var.ipAddrMgmtFgt1
      ipMaskMgmt       = cidrnetmask(var.cidrSubnetMgmt)
      fgtConfPort1Gw   = cidrhost(var.cidrSubnetPublic, 1)
      fgtConfPort2Gw   = cidrhost(var.cidrSubnetPrivate, 1)
      fgtConfPort3Gw   = cidrhost(var.cidrSubnetHAsync, 1)
      fgtConfPort4Gw   = cidrhost(var.cidrSubnetMgmt, 1)
      fgtConfHostname  = var.instanceNameFGT1
    }
  ))

  network_interface_ids = [
    azurerm_network_interface.eniFgt1Public.id,
    azurerm_network_interface.eniPrivateFgt1.id,
    azurerm_network_interface.eniHAsyncFgt1.id,
    azurerm_network_interface.eniMgmtFgt1.id
  ]

  os_disk {
    name                 = "${var.instanceNameFGT1}-OS_Disk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = var.imagePublisher[local.azureCloud]
    offer     = var.imageOffer[local.azureCloud]
    sku       = var.licenseType == "byol" ? var.skuFgtBYOL[local.azureCloud] : var.skuFgtPAYG[local.azureCloud]
    version   = var.isAzureChinaCloud == true ? var.imageVersionChina[var.imageVersion] : var.imageVersionGlobal[var.imageVersion]
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}



resource "azurerm_virtual_machine_data_disk_attachment" "dataDiskWithFgt1" {
  managed_disk_id    = azurerm_managed_disk.fgt1DataDisk.id
  virtual_machine_id = azurerm_linux_virtual_machine.fgt1.id
  lun                = "10"
  caching            = "ReadWrite"
}
