locals {
  eniFgt2PublicName    = "eni-fgt2-public"
  ipAddrPublicFgt2Name = "ip-fgt2-public"
}


################### FGT-2 port1 ####################
resource "azurerm_network_interface" "eniFgt2Public" {
  name                = local.eniFgt2PublicName
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  enable_ip_forwarding = false

  ip_configuration {
    name                          = local.ipAddrPublicFgt2Name
    subnet_id                     = azurerm_subnet.subnetPublic.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ipAddrPublicFgt2
    public_ip_address_id          = azurerm_public_ip.eipFgt2Public.id
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_network_interface_security_group_association" "eniFgt2PublicSgAssociate" {
  network_interface_id      = azurerm_network_interface.eniFgt2Public.id
  network_security_group_id = azurerm_network_security_group.nsgFgtPublic.id
}

resource "azurerm_managed_disk" "fgt2DataDisk" {
  name                 = "${azurerm_linux_virtual_machine.fgt2.name}-DataDisk"
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

resource "azurerm_linux_virtual_machine" "fgt2" {
  name                = var.instanceNameFGT2
  resource_group_name = azurerm_resource_group.resourceGrp.name
  location            = azurerm_virtual_network.vnetNgfw.location
  size                = var.instanceType

  disable_password_authentication = false
  admin_username                  = var.adminUsername
  admin_password                  = var.adminPassword
  custom_data = base64encode(templatefile(var.instanceBootstrapFgt2,
    {
      licenseType      = var.licenseType
      licenseFile      = var.licenseFileFgt2
      adminsPort       = var.adminsPort
      cidrDestination  = var.cidrVpcNgfw
      ipAddrPublic     = var.ipAddrPublicFgt2
      ipMaskPublic     = cidrnetmask(var.cidrSubnetPublic)
      ipAddrPrivate    = var.ipAddrPrivateFgt2
      ipMaskPrivate    = cidrnetmask(var.cidrSubnetPrivate)
      ipAddrHAsync     = var.ipAddrHAsyncFgt2
      ipMaskHAsync     = cidrnetmask(var.cidrSubnetHAsync)
      ipAddrHAsyncPeer = var.ipAddrHAsyncFgt1
      ipAddrMgmt       = var.ipAddrMgmtFgt2
      ipMaskMgmt       = cidrnetmask(var.cidrSubnetMgmt)
      fgtConfPort1Gw   = cidrhost(var.cidrSubnetPublic, 1)
      fgtConfPort2Gw   = cidrhost(var.cidrSubnetPrivate, 1)
      fgtConfPort3Gw   = cidrhost(var.cidrSubnetHAsync, 1)
      fgtConfPort4Gw   = cidrhost(var.cidrSubnetMgmt, 1)
      fgtConfHostname  = var.instanceNameFGT2
    }
  ))

  network_interface_ids = [
    azurerm_network_interface.eniFgt2Public.id,
    azurerm_network_interface.eniPrivateFgt2.id,
    azurerm_network_interface.eniHAsyncFgt2.id,
    azurerm_network_interface.eniMgmtFgt2.id
  ]

  os_disk {
    name                 = "${var.instanceNameFGT2}-OS_Disk"
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



resource "azurerm_virtual_machine_data_disk_attachment" "dataDiskWithFgt2" {
  managed_disk_id    = azurerm_managed_disk.fgt2DataDisk.id
  virtual_machine_id = azurerm_linux_virtual_machine.fgt2.id
  lun                = "10"
  caching            = "ReadWrite"
}
