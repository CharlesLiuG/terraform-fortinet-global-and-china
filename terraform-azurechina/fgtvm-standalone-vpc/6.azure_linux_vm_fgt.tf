locals {
  nameEniFgtPublic    = "eni-fgt-public"
  nameIpAddrPublicFgt = "ip-fgt-public"
  nameInstanceFgtFull = terraform.workspace == "default" ? var.hostnameFgt : "${var.hostnameFgt}-${terraform.workspace}"
  nameInternalSrv     = "WEB-SRV" # <- Modifiable
}


################### FGT port1 ####################
resource "azurerm_network_interface" "eniFgtPublic" {
  name                = local.nameEniFgtPublic
  location            = azurerm_virtual_network.vnetNgfw.location
  resource_group_name = azurerm_resource_group.resourceGrp.name

  enable_ip_forwarding = false

  ip_configuration {
    name                          = local.nameIpAddrPublicFgt
    subnet_id                     = azurerm_subnet.subnetPublic.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ipAddrPublicFgt
    public_ip_address_id          = azurerm_public_ip.eipFgt.id
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_network_interface_security_group_association" "eniFgtPublicSgAssociate" {
  network_interface_id      = azurerm_network_interface.eniFgtPublic.id
  network_security_group_id = azurerm_network_security_group.nsgFgtPublic.id
}

resource "azurerm_managed_disk" "fgtDataDisk" {
  name                 = "${local.nameInstanceFgtFull}-DataDisk"
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


resource "azurerm_linux_virtual_machine" "fgtStandalone" {
  depends_on          = [azurerm_managed_disk.fgtDataDisk]
  name                = local.nameInstanceFgtFull
  resource_group_name = azurerm_resource_group.resourceGrp.name
  location            = azurerm_virtual_network.vnetNgfw.location
  size                = var.instanceType

  disable_password_authentication = false
  admin_username                  = var.adminUsername
  admin_password                  = var.adminPassword
  custom_data = base64encode(templatefile(var.instanceBootstrapFgt,
    {
      licenseType           = var.licenseType
      licenseFile           = var.licenseFile
      adminsPort            = var.adminsPort
      cidrDestination       = var.cidrSubnetPrivate
      ipAddrPublic          = var.ipAddrPublicFgt
      ipMaskPublic          = cidrnetmask(var.cidrSubnetPublic)
      ipAddrPrivate         = var.ipAddrPrivateFgt
      ipMaskPrivate         = cidrnetmask(var.cidrSubnetPrivate)
      fgtConfPort1Gw        = cidrhost(var.cidrSubnetPublic, 1)
      fgtConfPort2Gw        = cidrhost(var.cidrSubnetPrivate, 1)
      fgtConfHostname       = local.nameInstanceFgtFull
      fgtConfVipSrcAddr     = var.fgtConfVipSrcAddr
      fgtConfVipSrvPort     = var.fgtConfVipSrvPort
      fgtConfVipExtPort     = var.fgtConfVipExtPort
      fgtConfVipName        = "VIP-${local.nameInternalSrv}-${var.fgtConfVipSrcAddr}"
      fgtConfPolicyDNATName = "to-vip-${lower(local.nameInternalSrv)}"
    }
  ))

  network_interface_ids = [
    azurerm_network_interface.eniFgtPublic.id,
    azurerm_network_interface.eniFgtPrivate.id,
  ]

  os_disk {
    name                 = "${local.nameInstanceFgtFull}-OS_Disk"
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

resource "azurerm_virtual_machine_data_disk_attachment" "dataDiskWithFgt" {
  managed_disk_id    = azurerm_managed_disk.fgtDataDisk.id
  virtual_machine_id = azurerm_linux_virtual_machine.fgtStandalone.id
  lun                = "10"
  caching            = "ReadWrite"
}
