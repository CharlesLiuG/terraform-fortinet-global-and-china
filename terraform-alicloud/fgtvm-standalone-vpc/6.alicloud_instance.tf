locals {
  amiFgtvm64          = var.imageVersion == "fgtvm64" ? var.licenseType == "byol" ? var.amiFgtBYOL64[var.regionName] : var.amiFgtPAYG64[var.regionName] : ""
  amiFgtvm70          = var.imageVersion == "fgtvm70" ? var.licenseType == "byol" ? var.amiFgtBYOL70[var.regionName] : var.amiFgtPAYG70[var.regionName] : ""
  amiFgtvm72          = var.imageVersion == "fgtvm72" ? var.licenseType == "byol" ? var.amiFgtBYOL72[var.regionName] : var.amiFgtPAYG72[var.regionName] : ""
  nameInstanceFgtFull = terraform.workspace == "default" ? var.hostnameFgt : "${var.hostnameFgt}-${terraform.workspace}"
  nameInternalSrv     = "WEB-SRV" # <- Modifiable
}

data "alicloud_instance_types" "instanceTypeFgt" {
  network_type         = "Vpc"
  system_disk_category = var.regionName == "cn-qingdao" ? "cloud_ssd" : "cloud_essd"
  instance_type_family = var.regionName == "cn-qingdao" ? "ecs.c6" : "ecs.c6e"
  instance_charge_type = "PostPaid"
  cpu_core_count       = 2        # <- Modifiable [c6.2xlarge = 8 | c6e.xlarge = 4]
  memory_size          = 4        # <- Modifiable [c6.2xlarge = 16 | c6e.xlarge = 8]
  eni_amount           = 2        # <- Modifiable [4: c6.2xlarge | c6e.xlarge]
  spot_strategy        = "NoSpot" # <- Modifiable [NoSpot | SpotAsPriceGo]
}

resource "alicloud_instance" "fgtStandalone" {
  depends_on           = [alicloud_ecs_network_interface.eniFgtPrivate]
  instance_name        = local.nameInstanceFgtFull
  security_groups      = alicloud_security_group.sgFgtPublic.*.id
  image_id             = local.amiFgtvm64 == "" ? local.amiFgtvm70 == "" ? local.amiFgtvm72 : local.amiFgtvm70 : local.amiFgtvm64
  instance_type        = var.instanceTypeFgtDesignated != "" ? var.instanceTypeFgtDesignated : data.alicloud_instance_types.instanceTypeFgt.instance_types.0.id
  system_disk_category = data.alicloud_instance_types.instanceTypeFgt.system_disk_category
  system_disk_size     = 40
  vswitch_id           = alicloud_vswitch.vswPublic.id
  private_ip           = var.ipAddrPublicFgt
  instance_charge_type = data.alicloud_instance_types.instanceTypeFgt.instance_charge_type

  user_data = templatefile(var.instanceBootstrapFgt,
    {
      licenseType           = var.licenseType
      licenseFile           = var.licenseFile
      adminsPort            = var.adminsPort
      cidrDestination       = var.cidrVswPrivate
      ipAddrPublic          = var.ipAddrPublicFgt
      ipAddrPrivate         = var.ipAddrPrivateFgt
      fgtConfPort1Gw        = cidrhost(var.cidrVswPublic, -3)
      fgtConfPort2Gw        = cidrhost(var.cidrVswPrivate, -3)
      fgtConfHostname       = local.nameInstanceFgtFull
      fgtConfPort1Mask      = cidrnetmask(var.cidrVswPublic)
      fgtConfPort2Mask      = cidrnetmask(var.cidrVswPrivate)
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
