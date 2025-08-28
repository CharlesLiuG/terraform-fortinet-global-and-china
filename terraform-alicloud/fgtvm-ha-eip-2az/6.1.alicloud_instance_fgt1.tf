locals {
  amiFgtvm64           = var.imageVersion == "fgtvm64" ? var.licenseType == "byol" ? var.amiFgtBYOL64[var.region1Name] : var.amiFgtPAYG64[var.region1Name] : ""
  amiFgtvm70           = var.imageVersion == "fgtvm70" ? var.licenseType == "byol" ? var.amiFgtBYOL70[var.region1Name] : var.amiFgtPAYG70[var.region1Name] : ""
  amiFgtvm72           = var.imageVersion == "fgtvm72" ? var.licenseType == "byol" ? var.amiFgtBYOL72[var.region1Name] : var.amiFgtPAYG72[var.region1Name] : ""
  nameInstanceFgt1Full = terraform.workspace == "default" ? var.hostnameFgt1 : "${var.hostnameFgt1}-${terraform.workspace}"
  nameInstanceFgt2Full = terraform.workspace == "default" ? var.hostnameFgt2 : "${var.hostnameFgt2}-${terraform.workspace}"
  nameInternalSrv      = "WEB-SRV" # <- Modifiable
}

data "alicloud_instance_types" "instanceTypeFgt" {
  network_type         = "Vpc"
  system_disk_category = var.region1Name == "cn-qingdao" ? "cloud_ssd" : "cloud_essd"
  instance_type_family = var.region1Name == "cn-qingdao" ? "ecs.c6" : "ecs.c6e"
  instance_charge_type = "PostPaid"
  cpu_core_count       = 4        # <- Modifiable [c6.2xlarge = 8  | c6e.xlarge = 4]
  memory_size          = 8        # <- Modifiable [c6.2xlarge = 16 | c6e.xlarge = 8]
  eni_amount           = 4        # <- Modifiable [4: c6.2xlarge   | c6e.xlarge]
  spot_strategy        = "NoSpot" # <- Modifiable [NoSpot | SpotAsPriceGo]
}

resource "alicloud_instance" "fgt1" {
  depends_on           = [alicloud_ecs_network_interface.eniPrivateFgt1, alicloud_ecs_network_interface.eniHAsyncFgt1, alicloud_ecs_network_interface.eniMgmtFgt1]
  instance_name        = local.nameInstanceFgt1Full
  security_groups      = alicloud_security_group.sgFgtPublic.*.id
  image_id             = local.amiFgtvm64 == "" ? local.amiFgtvm70 == "" ? local.amiFgtvm72 : local.amiFgtvm70 : local.amiFgtvm64
  instance_type        = var.instanceTypeFgtDesignated != "" ? var.instanceTypeFgtDesignated : data.alicloud_instance_types.instanceTypeFgt.instance_types.0.id
  system_disk_category = data.alicloud_instance_types.instanceTypeFgt.system_disk_category
  system_disk_size     = 40
  vswitch_id           = alicloud_vswitch.vswPublicFgt1.id
  private_ip           = var.ipAddrPublicFgt1
  instance_charge_type = data.alicloud_instance_types.instanceTypeFgt.instance_charge_type

  user_data = templatefile(var.instanceBootstrapFgt1,
    {
      licenseType           = var.licenseType
      licenseFile           = var.license1File
      adminsPort            = var.adminsPort
      cidrDestination       = var.cidrVswPrivateFgt1
      ipAddrPublic          = var.ipAddrPublicFgt1
      ipMaskPublic          = cidrnetmask(var.cidrVswPublicFgt1)
      ipAddrPrivate         = var.ipAddrPrivateFgt1
      ipMaskPrivate         = cidrnetmask(var.cidrVswPrivateFgt1)
      ipAddrHAsync          = var.ipAddrHAsyncFgt1
      ipMaskHAsync          = cidrnetmask(var.cidrVswHAsyncFgt1)
      ipAddrHAsyncPeer      = var.ipAddrHAsyncFgt2
      ipAddrMgmt            = var.ipAddrMgmtFgt1
      ipMaskMgmt            = cidrnetmask(var.cidrVswMgmtFgt1)
      fgtConfPort1Gw        = cidrhost(var.cidrVswPublicFgt1, -3)
      fgtConfPort2Gw        = cidrhost(var.cidrVswPrivateFgt1, -3)
      fgtConfPort4Gw        = cidrhost(var.cidrVswMgmtFgt1, -3)
      fgtConfHostname       = local.nameInstanceFgt1Full
      fgtConfVipSrcAddr     = var.fgtConfVipSrcAddr
      fgtConfVipSrvPort     = var.fgtConfVipSrvPort
      fgtConfVipExtPort     = var.fgtConfVipExtPort
      fgtConfVipName        = "VIP-${local.nameInternalSrv}-${var.fgtConfVipSrcAddr}"
      fgtConfPolicyDNATName = "to-vip-${lower(local.nameInternalSrv)}"
    }
  )

  data_disks {
    size                 = 30
    category             = data.alicloud_instance_types.instanceTypeFgt.system_disk_category
    delete_with_instance = true
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}
